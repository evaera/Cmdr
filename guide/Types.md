---
title: Types
---

# Types

By default, these types are available:

| Type name | Data type | Type name | Data type
| --------- | --------- | --------- | ---------
| `string` | `string` | `strings` | `array<string>`
| `number` | `number` | `numbers` | `array<number>`
| `integer` | `number` | `integers` | `array<number>`
| `boolean` | `boolean` | `booleans` | `array<boolean>`
| `player` | `Player` | `players` | `array<Player>`
| `playerId` | `number` | `playerIds` | `array<number>`
| `team` | `Team` | `teams` | `array<Team>`
| || `teamPlayers` | `array<Player>`
| `command` | `string` | `commands` | `array<string>`
| `userInput` | `Enum.UserInputType \| Enum.KeyCode` | `userInputs` | `array<Enum.UserInputType \| Enum.KeyCode>`
| `brickColor` | `BrickColor` | `brickColors` | `array<BrickColor>`
| `teamColor` | `BrickColor` | `teamColors` | `array<BrickColor>`
| `color3` | `Color3` | `color3s` | `array<Color3>`
| `hexColor3` | `Color3` | `hexColor3s` | `array<Color3>`
| `brickColor3` | `Color3` | `brickColor3s` | `array<Color3>`
| `vector3` | `Vector3` | `vector3s` | `array<Vector3>`
| `vector2` | `Vector2` | `vector2s` | `array<Vector2>`
| `duration` | `number` | `durations` | `array<number>`
| `storedKey` | `string` | `storedKeys` | `array<strings>`
| `url` | `string` | `urls` | `array<strings>`

Plural types (types that return a table) are listable, so you can provide a comma-separated list of values.

Custom types are defined as tables that implement specific named functions. When Types are in a ModuleScript, the ModuleScript should not return the table directly; instead it should return a function, which accepts the Registry as a parameter. You should then call `registry:RegisterType("typeName", yourTable)` to register it.

Check out the <api-link to="Registry.TypeDefinition">API reference</api-link> for a full reference of all available options.

```lua
local intType = {
	Transform = function (text)
		return tonumber(text)
	end;

	Validate = function (value)
		return value ~= nil and value == math.floor(value), "Only whole numbers are valid."
	end;

	Parse = function (value)
		return value
	end
}

return function (registry)
	registry:RegisterType("integer", intType)
end
```

Take a gander at the [built-in types](https://github.com/evaera/Cmdr/tree/master/Cmdr/BuiltInTypes) for more examples.

## Default value

You can specify a "default value" for your type by adding a `Default` function to it. For example, the default value for the `players` type is the name of the player who ran the command. The `Default` function should always return a **string**, as this is inserted BEFORE parsing.

For any argument that is type with a default value, you can simply type a `.` in Cmdr and the default value will automatically be used in its place.

## Enum types

Because Enum types are so common, there is a special function that easily lets you create an Enum type. When a command has an argument of this type, it'll always be a string matching exactly one of the strings in the array you define (see below).

```lua
return function (registry)
	registry:RegisterType("place", registry.Cmdr.Util.MakeEnumType("Place", {"World 1", "World 2", "World 3", "Final World"}))
end
```