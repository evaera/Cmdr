# Types

By default, these types are available:

:::info Possibly outdated

We've not reviewed this section for a while, it's possible that this information may be out of date.

:::

| **Type name** | Luau type                                | **Type name**  | Luau type                                  |
| ------------- | ---------------------------------------- | -------------- | ------------------------------------------ |
| `string`      | `string`                                 | `strings`      | `{string}`                                 |
| `number`      | `number`                                 | `numbers`      | `{number}`                                 |
| `integer`     | `number`                                 | `integers`     | `{number}`                                 |
| `boolean`     | `boolean`                                | `booleans`     | `{boolean}`                                |
| `player`      | `Player`                                 | `players`      | `{Player}`                                 |
| `playerId`    | `number`                                 | `playerIds`    | `{number}`                                 |
| `team`        | `Team`                                   | `teams`        | `{Team}`                                   |
|               |                                          | `teamPlayers`  | `{Player}`                                 |
| `command`     | `string`                                 | `commands`     | `{string}`                                 |
| `userInput`   | `Enum.UserInputType &#124; Enum.KeyCode` | `userInputs`   | `{Enum.UserInputType &#124; Enum.KeyCode}` |
| `brickColor`  | `BrickColor`                             | `brickColors`  | `{BrickColor}`                             |
| `teamColor`   | `BrickColor`                             | `teamColors`   | `{BrickColor}`                             |
| `color3`      | `Color3`                                 | `color3s`      | `{Color3}`                                 |
| `hexColor3`   | `Color3`                                 | `hexColor3s`   | `{Color3}`                                 |
| `brickColor3` | `Color3`                                 | `brickColor3s` | `{Color3}`                                 |
| `vector3`     | `Vector3`                                | `vector3s`     | `{Vector3}`                                |
| `vector2`     | `Vector2`                                | `vector2s`     | `{Vector2}`                                |
| `duration`    | `number`                                 | `durations`    | `{number}`                                 |
| `storedKey`   | `string`                                 | `storedKeys`   | `{strings}`                                |
| `url`         | `string`                                 | `urls`         | `{strings}`                                |

The `type name` is what you'd include in your command definition, while the `Luau type` is what your command implementation would get (this is also called the 'transformed value').

Plural types (types that return a table) are listable, so you can provide a comma-separated list of values.

Custom types are defined as tables that implement specific named functions. When Types are in a ModuleScript, the ModuleScript should not return the table directly; instead it should return a function, which accepts the Registry as a parameter. You should then call [`registry:RegisterType("typeName", yourTable)`](/api/Registry#RegisterType) to register it. This is important because if a type is only registered on one realm (the client but not the server, or vice versa) then it may cause unexpected bugs and errors.

Check out the [API reference](/api/Registry#TypeDefinition) for a full reference of all available options.

```lua
local intType = {
	Transform = function(text)
		return tonumber(text)
	end,

	Validate = function(value)
		return value ~= nil and value == math.floor(value), "Only whole numbers are valid."
	end,

	Parse = function(value)
		return value
	end,
}

return function(registry)
	registry:RegisterType("integer", intType)
end
```

Take a gander at the [built-in types](https://github.com/evaera/Cmdr/tree/master/Cmdr/BuiltInTypes) for more examples.

## Default value

You can specify a "default value" for your type by adding a `Default` function to it. For example, the default value for the `players` type is the name of the player who ran the command. The `Default` function should always return a `string`, as this is inserted **before** parsing.

For any argument whose type has a default value, you can simply input `.` and the default value will automatically be used in its place. E.g. `kill .`

## Enum types

Because Enum types are so common, there is a special function that easily lets you create an Enum type. When a command has an argument of this type, it'll always be a string matching exactly one of the strings in the array you define (see below).

```lua
return function (registry)
	registry:RegisterType("place", registry.Cmdr.Util.MakeEnumType("Place", {"World 1", "World 2", "World 3", "Final World"}))
end
```
