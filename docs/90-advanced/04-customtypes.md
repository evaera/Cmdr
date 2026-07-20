# Creating custom types

Custom types give your arguments validation, autocompletion, and transformations. You can register custom types just like you would hooks, using the central `Registry` module.

---

## Writing Type Definition Files

When a type is contained in a `ModuleScript`, it shouldn't return a plain table. Instead, it **must return a function** that accepts the `Registry` as its sole argument. From there, you register the custom type dictionary using `registry:RegisterType("typeName", typeTable)`.

:::warning Client-Side Registration

While missing a client-side registration won't inherently break execution on the server, skipping it means autocomplete functionality and live client validation will not exist for that type. To ensure a seamless user experience, register custom types across both environments.

:::

Here is the template for a custom type module:

```lua
local myCustomType = {
	Transform = function(text)
		-- Step 1: Receive the raw input string
		return string.lower(text)
	end,

	Validate = function(transformedValue)
		-- Step 2: Validates the output from Transform
		local isValid = #transformedValue > 3
		return isValid, "The value must be longer than 3 characters."
	end,

	Parse = function(transformedValue)
		-- Step 3: Returns the final value to the command implementation
		return { value = transformedValue }
	end,
}

return function(registry)
	registry:RegisterType("myCustomType", myCustomType)
end
```

---

## The Type Execution Pipeline

When a user executes a command, their argument inputs run sequentially through a distinct execution pipeline. If any step fails or yields an error, the pipeline halts immediately.

1. **`Transform()`**
   - **Input:** Raw user string, calling `Player`.
   - **Description:** Receives raw string text and the calling player.
2. **`Validate()`**
   - **Input:** Output of `Transform()`.
   - **Returns:** `true` or `(false, errorText)`.
   - **Description:** Validates the transformed input before proceeding.
3. **`Autocomplete()`** _(Client-side)_
   - **Input:** Output of `Transform()`.
   - **Description:** Runs on the client to display dynamic dropdown suggestions.
4. **`Parse()`**
   - **Input:** Output of `Transform()`.
   - **Returns:** Final Luau type.
   - **Description:** Converts the string into the target Luau type.

---

## Structure of a TypeDefinition

> **Important:** Of all the lifecycle methods listed below, **`Parse` is the only strictly required method**. All other methods (`Transform`, `Validate`, `Autocomplete`, etc.) are entirely optional and can be omitted if your type doesn't need them.

Your type definition dictionary can implement several unique lifecycle methods:

### Transform

```lua
Transform = function(text: string, player: Player) -> any
```

An optional function that accepts the raw text argument input and the player who executed the command. Whatever value this returns will be automatically passed down to `Validate`, `Autocomplete`, and `Parse`. If omitted, the raw string text is passed along instead.

### Validate

```lua
Validate = function(transformedValue: any) -> (boolean, string?)
```

Evaluates whether the value matches your requirements. It receives the output returned from your `Transform` function. If valid, it must return `true`. If invalid, it should return `false` followed by a user-facing string explaining the validation failure. If omitted, all input is assumed valid.

### ValidateOnce

```lua
ValidateOnce = function(transformedValue: any) -> (boolean, string?)
```

Works identically to `Validate`, but **only executes after the user presses Enter**. Use this exclusively for slow or yielding network calls (such as checking `GetUserIdFromNameAsync` via `Players`). For normal operations, stick to standard `Validate` blocks.

### Autocomplete

```lua
Autocomplete = function(transformedValue: any) -> ({ string }, { IsPartial: boolean? }?)
```

Populates Cmdr's dropdown menu as users type. It must return an array of strings representing match options. You can optionally return a second dictionary parameter containing configuration options (e.g., set `{ IsPartial = true }` to prevent pressing Tab from immediately proceeding to the next command argument).

### Parse

```lua
Parse = function(transformedValue: any) -> any
```

**[REQUIRED]** The final stage of the lifecycle pipeline before the value is marked complete. This transforms the processed text tokens into the final Luau type object (e.g., an Instance, a Color3, or a table) which will be fed directly into your final command implementation module.

---

## Specialized Type Options

Beyond basic processing, `TypeDefinition` objects can include metadata fields that dramatically alter how Cmdr interacts with them.

### Listable Types (`Listable`)

Setting `Listable = true` instructs Cmdr that comma-separated values are allowed (e.g., `kill player1,player2,player3`).

When enabled, you do not need to update your parsing or validation architecture. Cmdr automatically splits the values by their commas and processes each individual segment through your `Transform`, `Validate`, and `Parse` pipeline independently.

- **Requirement:** Your `Parse` function **must return a table**. The values returned by each segment's `Parse` step are automatically flattened and merged into a single unique table before being passed to your command.

### Default Overrides (`Default`)

You can provide fallback string options if an argument is skipped or if a user passes a period (`.`) literal token.

```lua
Default = function(player: Player) -> string
```

The `Default` function must always return a **string**. This string value is inserted and treated exactly as raw user text **before** any parsing or `Transform` operations are evaluated.

---

## Type Helper Functions

Cmdr provides a few standard factory functions within `Util` to quickly spin up custom types without writing complex validation loops.

### Enum Types (`Util.MakeEnumType`)

For basic collections of discrete string choices, use `Util.MakeEnumType(name, choices)`. This automatically provides full fuzzy-matching autocomplete suggestions and ensures the parsed output explicitly matches a key within your options array.

```lua
return function(registry)
	local customEnum = registry.Cmdr.Util.MakeEnumType("rarity", { "Common", "Rare", "Epic", "Legendary" })
	registry:RegisterType("rarity", customEnum)
end
```

### Sequence Types (`Util.MakeSequenceType`)

For multi-value structural types like positions, vectors, or colors, use `Util.MakeSequenceType`. It splits a space- or comma-delimited string sequence and runs validation logic on each piece.

```lua
local vector2Type = registry.Cmdr.Util.MakeSequenceType({
	Length = 2,
	TransformEach = tonumber,
	ValidateEach = function(value, index)
		return value ~= nil, `Component {index} must be a valid number.`
	end,
	Constructor = Vector2.new
})
```
