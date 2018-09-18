# Cmdr

**Cmdr** is a fully extensible and type safe command console for Roblox developers.

<p align="center">
  <img src="https://giant.gfycat.com/ChillyAjarGoldfish.gif" alt="Cmdr Demo" />
</p>

Cmdr is designed specifically so that you can write your own commands and argument types, so that it can fit right in with the rest of your game. In addition to the standard moderation commands (teleport, kill, kick, ban), Cmdr is also great for debug commands in your game (say, if you wanted to have a command to give you a weapon, reset a round, teleport you between places in your universe).

Cmdr provides a friendly API that lets the game developer choose if they want to register the default admin commands, register their own commands, choose a different key bind for activating the console, and disabling Cmdr altogether.

Cmdr has a robust and friendly type validation system (making sure strings are strings, players are players, etc), which can give end users realtime command validation as they type, and automatic error messages. By the time the command actually gets to your code, you can be assured that all of the arguments are present and of the correct type.

## Set-up

### Server
You should create a folder to keep your commands inside, and then register them on the server. You need to require Cmdr on the server *and* on the client for it to be fully loaded.

```lua
-- This is a script you would create in ServerScriptService, for example.
local Cmdr = require(path.to.Cmdr)
Cmdr:RegisterCommandsIn(script.Parent.CmdrCommands) -- Your folder
-- See below for the full API.
```

### Client

From the client, you also need to require the CmdrClient module. After the server code above runs, it'll be inserted into ReplicatedStorage automatically.

To prepare the GUI, download the Cmdr.rbxm model file and insert it into your game under StarterGui.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

-- Configurable, and you can choose multiple keys
Cmdr:SetActivationKeys({ Enum.KeyCode.Semicolon })
-- See below for the full API.
```

## Commands

No commands are registered by default. Cmdr ships with a set of default commands, which can be loaded if you so wish by calling `Cmdr:RegisterDefaultCommands()`. See [Default Commands](#default-commands) for a list.

Custom commands are defined in ModuleScripts that return a single table.

```lua
-- Teleport.lua, inside your commands folder as defined above.
return {
	Name = "teleport";
	Aliases = {"tp"};
	Description = "Teleports a player or set of players to one target.";
	Group = "Admin";
	Args = {
		{
			Type = "players";
			Name = "from";
			Description = "The players to teleport";
		},
		{
			Type = "player";
			Name = "to";
			Description = "The player to teleport to"
		}
	};
}
```

The implementation should be in a separate file, which is never delivered to the client. This module should only return one function. The module must be named the same thing as the definition module as described above, with the word "Server" appended to the end.

```lua
-- TeleportServer.lua

-- These arguments are guaranteed to exist and be correctly typed.
return function (context, fromPlayers, toPlayer)
  if toPlayer.Character and toPlayer:FindFirstChild("HumanoidRootPart") then
    local position = toPlayer.Character.HumanoidRootPart.CFrame

    for _, player in ipairs(fromPlayers) do
      if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = position
      end
    end

    return "Teleported players."
  end

  return "Target player has no character."
end
```

### Definition properties

#### Name: string
The name that's in auto complete and displayed to user.

#### Aliases: array<string>
Aliases that are not in the autocomplete, but if matched will run this command just the same. For example, `m` might be an alias of `announce`.

#### Description: string
A description of the command which is displayed to the user.

#### Group?: any
Optional, can be be any value you wish. This property is intended to be used in hooks, so that you can categorize commands and decide if you want a specific user to be able to run them or not.

#### Args: array<dictionary>
An array containing dictionaries with the following keys:

##### Arg.Type: string
The argument type (case sensitive).

##### Arg.Name: string
The argument name, this is displayed to the user as they type.

##### Arg.Description: string
A description of what the argument is, this is also displayed to the user.

##### Arg.Optional?: boolean
If this is present and set to `true`, then the user can run the command without filling out this value. The argument will be sent to your commands as `nil`.

#### Data?: function (context: CommandContext)
If your command needs to gather some extra data from the client that's only available on the client, then you can define this function. It should accept the CommandContext for the current command as an argument, and return a single value which will be available on the server command with `context:GetData()`.

#### Run?: function (context: CommandContext, ...: any)
If you want your command to run entirely on the client, you can add this function directly to the command definition itself. It works exactly like the function that you would return from the Server module. Hooks defined on the server won't fire if this function is present, since it runs entirely on the client and the server will not know if the user runs this command.

### Default Commands
Note: These commands are coming soon, they are not bundled yet.

If you run `Cmdr:RegisterDefaultCommands()`, these commands are available with the following `Group`s:

Group: `DefaultAdmin`: `announce` (`m`), `bring`, `kick`, `ban`, `teleport` (`tp`), `kill`

Group: `DefaultDebug`: `to`, `blink` (`b`), `thru` (`t`)

## Types

By default, these types are available:

`string`, `number`, `integer`, `boolean`, `player`, `players`, `team`, `teamPlayers`

Custom types are defined as tables that implement specific named functions. When Types are in a ModuleScript, the ModuleScript should not return the table directly; instead it should return a function, which accepts the Registry as a parameter. You should then call `registry:RegisterType("typeName", yourTable)` to register it.

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

### Definition properties
#### Transform

`Transform` is an optional function that is passed two values: the raw text, and the player running the command. Then, whatever values this function returns will be passed to all other functions in the type (Validate, Autocomplete, and Parse).

#### Validate

The `Validate` function is passed whatever is returned from the Transform function (or the raw value if there is no Transform function). If the value is valid for the type, it should return `true`. If it the value is invalid, it should return two values: `false`, and a string containing an error message.

If this function isn't present, anything will be considered valid.

#### Autocomplete

`Autocomplete` is optional and should only be present for types that are possible to be auto completed. It should return an array of strings that will be displayed in the auto complete menu.

#### Parse

Parse is the only required function in a type definition. It is the final step before the value is considered finalized. This function should return the actual parsed value that will be sent to the command functions.

### Enum types

Because Enum types are so common, there is a special function that easily lets you create an Enum type. When a command has an argument of this type, it'll always be a string matching exactly one of the strings in the array you define (see below).

```lua
return function (registry)
	registry:RegisterType("place", registry.Cmdr.Util.MakeEnumType("Place", {"World 1", "World 2", "World 3", "Final World"}))
end
```

## Hooks

Hooks are callback functions that you can register which *hook* into the command execution process. Hooks are extremely useful: they can be used for implementing a custom permission system, logging commands, or overriding command output.

Hooks can be registered on the server or the client, but for most applications (permissions, logging, etc) they should be used on the server.

There can be many hooks of each type, and they are all run until one returns a string, which will replace the command response in the console.

### BeforeRun

The callback is passed the CommandContext for the relevant command. The hooks are the last thing to run before the command itself, so all properties are available.

This hook can be used to interrupt command execution (useful for permissions) by returning a string. The returned string will replace the command output on the executing user's screen. If the callback returns nothing (`nil`), then the command will run normally.

```lua
Cmdr:AddHook("BeforeRun", function(command)
  if command.Group == "Admin" and command.Executor:IsInGroup(1) == false then
    return "You don't have permission to run this command"
  end
end)
```

### AfterRun

The AfterRun hook runs, as its name implies, directly after a command is run. The callback is also passed a CommandContext, but the `Response` property is now available, which is the response from the command implementation (what would normally be displayed after running the command).

If this callback returns a string, then it will replace the normal response on the user's screen. If the callback returns nothing (`nil`), then the response will be shown normally.

This hook is most useful for logging.

```lua
Cmdr:AddHook("AfterRun", function(command)
  print(command.Response) -- see the actual response from the command execution
  return "Returning a string from this hook replaces the response message with this text"
end)
```

# API

Descriptions for the API are coming soon.

## Cmdr Server

### Properties
#### `Cmdr.Registry: Registry`
#### `Cmdr.Dispatcher: Dispatcher`
#### `Cmdr.Util: Util`

## Cmdr Client

### Methods

#### `CmdrClient:SetActivationKeys(keys: array<Enum.KeyCode>): void`
#### `CmdrClient:SetPlaceName(labelText: string): void`
#### `CmdrClient:SetEnabled(isEnabled: boolean): void`
#### `CmdrClient:HandleEvent(event: string, handler: function): void`

### Properties

#### `CmdrClient.Enabled: boolean`
#### `CmdrClient.PlaceName: string`
#### `CmdrClient.ActivationKeys: dictionary<Enum.KeyCode, true>`
#### `CmdrClient.Registry: Registry`
#### `CmdrClient.Dispatcher: Dispatcher`
#### `CmdrClient.Util: Util`

## Registry

### Methods

#### `Registry:RegisterTypesIn(container: Instance): void`
#### `Registry:RegisterType(name: string, typeDefinition: TypeDefinition): void`
#### `Registry:GetType(name: string): TypeDefinition?`
#### `Registry:RegisterCommandsIn(container: Instance): void`
#### `Registry:RegisterCommand(commandScript: ModuleScript, commandServerScript?: ModuleScript): void`
#### `Registry:RegisterDefaultCommands(): void`
#### `Registry:GetCommand(name: string): CommandDefinition?`
#### `Registry:GetCommands(): array<CommandDefinition>`
#### `Registry:GetCommandsAsStrings(): array<string>`
#### `Registry:AddHook(hookName: string, callback: function): void`

## Dispatcher

### Methods

#### `Dispatcher:Run(...: string): string`

## CommandContext

### Properties

#### `CommandContext.Dispatcher: Dispatcher`
#### `CommandContext.Name: string`
#### `CommandContext.RawText: string`
#### `CommandContext.Group: any`
#### `CommandContext.Aliases: array<string>`
#### `CommandContext.Description: string`
#### `CommandContext.Executor: Player`
#### `CommandContext.RawArguments: array<string>`
#### `CommandContext.Arguments: array<ArgumentContext>`
#### `CommandContext.Response: string?`

### Methods

#### `CommandContext:GetArgument(index: number): ArgumentContext`
#### `CommandContext:GetData(): any`
#### `CommandContext:SendEvent(player: Player, event: string, ...: any): void`
#### `CommandContext:BroadcastEvent(event: string, ...: any): void`
#### `CommandContext:Reply(text: string, color?: Color3): void`

## ArgumentContext

### Properties

#### `ArgumentContext.Command: CommandContext`
#### `ArgumentContext.Name: string`
#### `ArgumentContext.Required: boolean`
#### `ArgumentContext.Executor: Player`
#### `ArgumentContext.RawValue: string`

### Methods

#### `ArgumentContext:GetValue(): any`
#### `ArgumentContext:GetTransformedValue(): any...`

## Util

### Methods

#### `Util.MakeDictionary(array: array<any>): dictionary<any, true>`
#### `Util.MakeFuzzyFinder(setOrContainer: array<string> | array<Instance> | Instance): fuzzyFinder(text: string, returnFirst: boolean)`
#### `Util.GetInstanceNames(instances: array<Instance>): array<string>`
#### `Util.SplitStringSimple(text: string, seperator: string): array<string>`
#### `Util.SplitString(text: string, max: number): array<string>`
#### `Util.TrimString(text: string): string`
#### `Util.GetTextSize(text: string, label: TextLabel, size: number): Vector2`
#### `Util.MakeEnumType(name: string, values: array<string>): TypeDefinition`

# Todo
- Write documentation
- Add more methods to command context
	- Allowing commands to take more control of the console, printing extra messages, clearing, rich text, etc.
- Make players type able to have a comma-separated list.
