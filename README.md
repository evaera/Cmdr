<div align="center">
	<img src="assets/logo.png" alt="Cmdr" height="150" />
	<br>
	<a href="https://www.npmjs.com/package/rbx-cmdr"><img src="https://badge.fury.io/js/rbx-cmdr.svg"></a>
	<br><br>
</div>

**Cmdr** is a fully extensible and type safe command console for Roblox developers.

- Great for admin commands, but does much more.
- Make commands that tie in specifically with your game systems.
- Intelligent autocompletion and instant validation.
- Run commands programmatically on behalf of the local user.
- Bind commands to user input.
- Secure: the client and server both validate input separately.
- Embedded commands: dynamically use the output of an inner command when running a command.

<p align="center">
  <img src="https://i.eryn.io/tx29vhqbla.gif" alt="Cmdr Demo" />
</p>

Cmdr is designed specifically so that you can write your own commands and argument types, so that it can fit right in with the rest of your game. In addition to the standard admin commands (teleport, kill, kick), Cmdr is also great for debug commands in your game (say, if you wanted to have a command to give you a weapon, reset a round, teleport you between places in your universe).

Cmdr provides a friendly API that lets the game developer choose if they want to register the default admin commands, register their own commands, choose a different key bind for activating the console, and disabling Cmdr altogether.

Cmdr has a robust and friendly type validation system (making sure strings are strings, players are players, etc), which can give end users real time command validation as they type, and automatic error messages. By the time the command actually gets to your code, you can be assured that all of the arguments are present and of the correct type.

If you have any questions, suggestions, or ideas for Cmdr, or you run into a bug, please don't hesitate to [open an issue](https://github.com/evaera/Cmdr/issues)! PRs are welcome as well.

## Set-up

### Installation
#### Method 1 - Recommended

The easiest way to get started with Cmdr is to install the [RoStrap Roblox Studio plugin](https://www.roblox.com/library/725884332/RoStrap), open the RoStrap interface in a place, and then install "Cmdr". This will instantly download and build the newest version of Cmdr right from GitHub.

![Installation](https://user-images.githubusercontent.com/2489210/45920094-b27c3f80-be6d-11e8-9105-f358140b5a13.png)

#### Method 2 - Manual

You can download the latest model file release from the [releases section](https://github.com/evaera/Cmdr/releases/latest), but this may not always be the most up to date version of Cmdr. You'll want to put this is a server directory, like ServerScriptService.

#### Method 3 - Advanced

Cmdr has no dependencies, so it can also be easily included as a Git submodule and synced in with the rest of your project with [Rojo](https://github.com/LPGhatguy/rojo). If you don't know how to do this already, then please see method 1 :)

### Server
You should create a folder to keep your commands inside, and then register them on the server. You need to require Cmdr on the server *and* on the client for it to be fully loaded. However, you only need to register commands and types on the server. There should be no need to modify the actual Cmdr library itself.

```lua
-- This is a script you would create in ServerScriptService, for example.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources")) -- With RoStrap
local Cmdr = Resources:LoadLibrary("Cmdr") -- or if not using RoStrap: require(path.to.Cmdr)

Cmdr:RegisterDefaultCommands() -- This loads the default set of commands that Cmdr comes with. (Optional)
-- Cmdr:RegisterCommandsIn(script.Parent.CmdrCommands) -- Register commands from your own folder. (Optional)
-- See below for the full API.
```

The Cmdr GUI will be inserted into StarterGui if it doesn't already exist. You can customize the GUI to your liking (changing colors, etc.) if you play the game, copy the GUI, stop the game, and then paste it in to StarterGui. Of course, this is completely optional.

### Client

From the client, you also need to require the CmdrClient module.

If not using RoStrap, then after the server code above runs, CmdrClient will be inserted into ReplicatedStorage automatically.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources")) -- With RoStrap
local Cmdr = Resources:LoadLibrary("CmdrClient") -- Without RoStrap: require(ReplicatedStorage:WaitForChild("CmdrClient"))

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

The implementation should be in a separate ModuleScript. Cmdr will never deliver this script to the client. This module should only return one function. The module must be named the same thing as the definition module as described above, with the word "Server" appended to the end.

It is passed the CommandContext for this command, which is a special object that represents a single command run. The context can be used to get the executing player, send events, reply with additional lines in the console, and more. See CommandContext in the API section below for more details. After the context, any arguments you defined in the command definition will be passed in order.

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

Take a gander at the [built-in commands](https://github.com/evaera/Cmdr/tree/master/Cmdr/BuiltInCommands) for more examples.

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

##### Arg.Default?: any
If present, the argument will be optional and if the user doesn't supply a value, your function will receive whatever you set this to. `Default` being set implies `Optional = true`, so `Optional` can be omitted.

#### Data?: function (context: CommandContext)
If your command needs to gather some extra data from the client that's only available on the client, then you can define this function. It should accept the CommandContext for the current command as an argument, and return a single value which will be available on the server command with `context:GetData()`.

#### Run?: function (context: CommandContext, ...: any)
If you want your command to run entirely on the client, you can add this function directly to the command definition itself. It works exactly like the function that you would return from the Server module. Hooks defined on the server won't fire if this function is present, since it runs entirely on the client and the server will not know if the user runs this command.

#### AutoExec?: array<string>
A list of commands to run automatically when this command is registered at the start of the game. This should primarily be used to register any aliases regarding this command with the `alias` command, but can be used for initializing state as well. Command execution will be deferred until the end of the frame.

### Default Commands
If you run `Cmdr:RegisterDefaultCommands()`, these commands will be available with the following `Group`s:

Group: `DefaultAdmin`: `announce` (`m`), `bring`, `kick`, `teleport` (`tp`), `kill`

Group: `DefaultDebug`: `to`, `blink` (`b`), `thru` (`t`), `position`

Group: `DefaultUtil`: `alias`, `bind`, `unbind`, `run`, `runif`, `echo`, `hover`, `replace`, `history`

Group: `Help`: `help`

#### Registering a subset of the default commands
If you only want some, but not all, of the default commands, you can restrict the commands that you register in two ways.

1. Pass an array of groups to the RegisterDefaultCommands function: `Cmdr:RegisterDefaultCommands({"Help", "DefaultUtil"})`
2. Pass a filter function that accepts a CommandDefinition and either returns `true` or `false`:

```lua
Cmdr:RegisterDefaultCommands(function(cmd)
	return #cmd.Name < 6 -- This is absurd... but possible!
end)
```

### Prefixed Union Types
An argument can be allowed to accept a different type when starting with a specific prefix. The most common example of this is with the `players` type, which when prefixed with % allows the user to select players based on team, rather than name.

These can be defined on a per-argument basis, so that your commands can accept many types of arguments in a single slot. Under the Args section of command definition, each argument has a `Type` key.  For arguments that accept only a single type, it would look like `Type = "string"`. If we also wanted to accept a number when the user prefixes the argument with `#`, we could change it to: `Type = "string # number"`. Then, if the user provided `#33` for this argument, your function would be delivered the number value `33` in that position.

This is infinitely expandable, and you can include as many prefixed union types as you wish: `Type = "string # number @ player % team"`, etc. Remember that there must be a space between the symbol and the type.

Some default types automatically have a prefixed union type applied to them, because they would both resolve to the same type in the end. For example, whenever you define an argument of type `players`, under the hood this is perceived as `players % teamPlayers`. (`teamPlayers` is a type that matches based on team name, but resolves to an array of Players: the same thing that the normal `players` type would resolve with.)

Here is a list of automatic prefixed union types:

- `players`: `players % teamPlayers`
- `playerId`: `playerId # integer`
- `playerIds`: `playerIds # integers`
- `brickColor`: `brickColor % teamColor`
- `brickColors`: `brickColors % teamColors`
- `color3`: `color3 # hexColor3 ! brickColor3`
- `color3s`: `color3s # hexColor3s ! brickColor3s`

## Types

By default, these types are available:

`string`, `strings`: string, array<string>
`number`, `numbers`: number, array<number>
`integer`, `integers`: number, array<number>
`boolean`, `booleans`: boolean, array<boolean>
`player`, `players`: Player, array<Player>
`team`, `teams`: Team, array<Team>
`teamPlayers`: Player, array<Player>
`command`, `commands`: string, array<string>
`userInput`, `userInputs` Enum.UserInputType | Enum.KeyCode, array<Enum.UserInputType | Enum.KeyCode>
`brickColor`, `brickColors`: BrickColor, array<BrickColor>
`teamColor`, `teamColors`: BrickColor, array<BrickColor>
`color3`, `color3s`: Color3, array<Color3>
`hexColor3`, `hexColor3s`: Color3, array<Color3>
`brickColor3`, `brickColor3s`: Color3, array<Color3>
`vector3`, `vector3s`: Vector3, array<Vector3>
`vector2`, `vector2s`: Vector2, array<Vector2>

Plural types (types that return a table) are listable, so you can provide a comma-separated list of values.

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

Take a look-see at the [built-in types](https://github.com/evaera/Cmdr/tree/master/Cmdr/BuiltInTypes) for more examples.

### Definition properties
#### DisplayName
Optionally overrides the user-facing name of this type in the autocomplete menu. If omitted, the registered name of this type will be used.

#### Transform
`Transform` is an optional function that is passed two values: the raw text, and the player running the command. Then, whatever values this function returns will be passed to all other functions in the type (Validate, Autocomplete, and Parse).

#### Validate
The `Validate` function is passed whatever is returned from the Transform function (or the raw value if there is no Transform function). If the value is valid for the type, it should return `true`. If it the value is invalid, it should return two values: `false`, and a string containing an error message.

If this function isn't present, anything will be considered valid.

#### ValidateOnce
This function works exactly the same as the normal `Validate` function, except it only runs once (after the user presses Enter). This should only be used if the validation process is relatively expensive or needs to yield. For example, the `PlayerId` type uses this because it needs to call `GetUserIdFromNameAsync` in order to validate.

For the vast majority of types, you should just use `Validate` instead.

#### Autocomplete
`Autocomplete` is optional and should only be present for types that are possible to be auto completed. It should return an array of strings that will be displayed in the auto complete menu.

#### Parse
Parse is the only required function in a type definition. It is the final step before the value is considered finalized. This function should return the actual parsed value that will be sent to the command functions.

#### Listable
If you set the optional key `Listable` to `true` in your table, this will tell Cmdr that comma-separated lists are allowed for this type. Cmdr will automatically split the list and parse each segment through your Transform, Validate, Autocomplete, and Parse functions individually, so you don't have to change the logic of your Type at all.

The only limitation is that your Parse function **must return a table**. The tables from each individual segment's Parse will be merged into one table at the end of the parse step. The uniqueness of values is ensured upon merging, so even if the user lists the same value several times, it will only appear once in the final table.

### Enum types

Because Enum types are so common, there is a special function that easily lets you create an Enum type. When a command has an argument of this type, it'll always be a string matching exactly one of the strings in the array you define (see below).

```lua
return function (registry)
	registry:RegisterType("place", registry.Cmdr.Util.MakeEnumType("Place", {"World 1", "World 2", "World 3", "Final World"}))
end
```

## Hooks

Hooks are callback functions that you can register which *hook* into the command execution process. Hooks are extremely useful: they can be used for implementing a custom permission system, logging commands, or overriding command output.

Hooks can be registered on both the server and the client. Server commands will run server hooks, and client commands (such as `blink`) will run client hooks. Depending on your application, you may need to register hooks on one or both. For example, logging may only need to be registered on the server, but permissions might need to be registered on the client in addition to the server.

There can be many hooks of each type, and they are all run until one returns a string, which will replace the command response in the console.

### BeforeRun

The callback is passed the CommandContext for the relevant command. The hooks are the last thing to run before the command itself, so all properties are available.

This hook can be used to interrupt command execution (useful for permissions) by returning a string. The returned string will replace the command output on the executing user's screen. If the callback returns nothing (`nil`), then the command will run normally.

As a quick way to register hooks on both the server and the client, you can make a folder for your hooks, with module scripts in them which return a function. Similar to Types, if you call `Cmdr:RegisterHooksIn(yourFolderHere)` from the server, Cmdr will load all ModuleScripts in the folder on the server and the client, so you only need to write your code once.

```lua
-- A ModuleScript inside your hooks folder.
return function (registry)
	registry:RegisterHook("BeforeRun", function(context)
		if context.Group == "DefaultAdmin" and context.Executor.UserId ~= game.CreatorId then
			return "You don't have permission to run this command"
		end
	end)
end
```

### AfterRun

The AfterRun hook runs, as its name implies, directly after a command is run. The callback is also passed a CommandContext, but the `Response` property is now available, which is the response from the command implementation (what would normally be displayed after running the command).

If this callback returns a string, then it will replace the normal response on the user's screen. If the callback returns nothing (`nil`), then the response will be shown normally.

This hook is most useful for logging. Since we don't want to add this hook on the client in this example, we can just require the server version of Cmdr and add this hook directly right here (as opposed to what we did in the BeforeRun example, which adds the hook to the client as well):

```lua
Cmdr.Registry:RegisterHook("AfterRun", function(context)
  print(context.Response) -- see the actual response from the command execution
  return "Returning a string from this hook replaces the response message with this text"
end)
```

## Network Event Handlers

Some commands that run on the server might need to also do something on the client, or on every client. Network event handlers are callback functions that you can set to run when a server command sends a message back to the client. Only one handler can be set to a certain event at a time, so it's possible to change the handler for a specific event without needing to re-implement the entire command yourself.

For example, consider the default `announce` command, which creates a message on every player's screen. By default, this creates a system chat message with the given text, because Cmdr has a default event handler for the `"Message"` event, which the `announce` command broadcasts,

If you wanted to display announcements some other way, you could just override the default event handler:

```lua
CmdrClient:HandleEvent("Message", function (text, player)
	print("Announcement from", player.Name, text)
end)
```

You can send events from your own commands on the server (or to the local player if in a client-only command) by using `context:SendEvent(player, ...)` and `context:BroadcastEvent(...)`. The built-in `context:Reply(text)` method actually uses `SendEvent` under the hood, whose default handler on the client is set to just add a new line to the console window with the given text.

## Bind, Alias, and Run
The `bind`, `alias`, and `run` commands make use of *command strings*. A command string is raw text made up of a command name and possibly predefined arguments that is run in the background as a command itself. Before these command strings are run, they are preprocessed, replacing arguments (in the format `$1`, `$2`, `$3`, etc.) and embedded commands with their textual values.

### Embedded commands
Sub-commands may be embedded inside command strings, in the format `${command arg1 arg2 arg3}`. These sub-commands are evaluated just before the command string is run, and are run every time the command string runs. They evaluate to whatever the command returns as output.

Embedded commands are nestable: `run echo ${run echo ${echo hello}!}` (displays `"hello!"`). We use `run` here instead of just running `echo` directly, because embedded commands are only evaluated in the preprocess step of commands that use *command strings* (which is only `run`, `alias`, and `bind`).

By default, if the evaluated command output has a space in it, the return value will be encapsulated in quote marks so that the entire value is perceived as one argument to Cmdr. In cases where it's desirable for Cmdr to parse each word as a separate argument, you can use use a literal syntax: `run teleport ${{echo first second}}` (in this example, "first" and "second" would then become the first and second arguments to the `teleport` command, instead of the first argument being "first second")

### Run
Run is the simplest of the bunch, and does right what it says on the tin. It runs whatever text you give it immediately as a command. This is useful, because it evaluates embedded commands within the command string before running.

```
run ${{echo kill me}}
```

### Bind
Bind is a command that allows you to run a certain command string every time some event happens. The default bind type is by user input (mouse or keyboard input), but you can also bind to other events.

This is very powerful: You could define a command, like `cast_ability`, which casts a certain move in your game. Then, you could have a keybindings menu that allows the user to rebind keys, and whenever they do, it runs `CmdrClient:Run("bind", keyCode.Name, "cast_ability", abilityId)` in the background. By separating the user input from our hypothetical ability code, our code is made more robust as we can now trigger abilities from a number of possible events, in addition to the bound key.

If you prefix the first argument with `@`, you can instead select a player to bind to, which will run this command string every time that player chats. You can get the chat text by using `$1` in your command string.

In the future, you will be able to bind to network events as described in the previous section by prefixing the first argument with `!`.

The `unbind` command can be used to unbind anything that `bind` can bind.

### Alias
The alias command lets you create a new, single command out of a command string. Alias commands can contain more than one distinct command, delimited by `&&`. You can also accept arguments from the command with `$1` through `$5`.

```
alias farewell announce Farewell, $1! && kill $1
```

Then, if we run `farewell evaera`, it would make an announcement saying "Farewell, evaera!" and then kill the player called "evaera".

As another example, you could create a command that killed anyone your mouse was currently hovering over like so:

```
alias pointer_of_death kill ${hover}
```

# API

## How to read these function signatures

- Parameters and properties are in the format `name: type` (`name: string`)
- Return value types are listed following a colon after the closing paren (`example(): boolean`)
- Optional parameters are listed with a `?` following their name
- Potentially nil properties or return types are listed with a `?` following their type
- `void` is interchangeable with `nil` in most circumstances
- Varargs are in the format `...: type`, where the type applies to all values (`...: string`)
- Callback functions are written as *arrow functions*, in the format `function(param1: type, param2: type) => type`, where the return type follows the arrow.

## Cmdr Server

### Properties
#### `Cmdr.Registry: Registry`
Refers to the current command Registry, see Registry below.

#### `Cmdr.Dispatcher: Dispatcher`
Refers to the current command Dispatcher, see Dispatcher below.

#### `Cmdr.Util: Util`
Refers to a table containing many useful utility functions, see Util below.

## Cmdr Client

### Methods

#### `CmdrClient:SetActivationKeys(keys: array<Enum.KeyCode>): void`
Sets the key codes that will hide or show Cmdr.

#### `CmdrClient:SetPlaceName(labelText: string): void`
Sets the place name label that appears when executing commands. This is useful for a quick way to tell what game you're playing in a universe game.

#### `CmdrClient:SetEnabled(isEnabled: boolean): void`
Sets whether or not Cmdr can be shown via the defined activation keys. Useful for when you want users to need to opt-in to show the console in a settings menu.

#### `CmdrClient:HandleEvent(event: string, handler: function(...: any) => void): void`
Sets the event handler for a certain network event. See Network Event Handlers above.

#### `CmdrClient:SetMashToEnable(isEnabled: boolean): void`
Enables the "Mash to Enable" feature, which requires the player to press the activation key 7 times in quick succession to open the Cmdr menu for the first time. This is not meant as a security feature, rather, as a way to ensure that the console is not accidentally obtrusive to regular players of your game.

### Properties

#### `CmdrClient.Enabled: boolean`
Whether or not the Cmdr console is enabled. See CmdrClient:SetEnabled.

#### `CmdrClient.PlaceName: string`
The current place name label text.

#### `CmdrClient.ActivationKeys: dictionary<Enum.KeyCode, true>`
A map containing the current activation keys,

#### `CmdrClient.Registry: Registry`
Refers to the current command Registry, see Registry below.

#### `CmdrClient.Dispatcher: Dispatcher`
Refers to the current command Dispatcher, see Dispatcher below.

#### `CmdrClient.Util: Util`
Refers to a table containing many useful utility functions, see Util below.

## Registry
The registry handles registering commands, types, and hooks. Exists on both client and server.

### Methods

#### `Registry:RegisterTypesIn(container: Instance): void`
Registers all types from within a container. This only needs to be called server-side.

#### `Registry:RegisterType(name: string, typeDefinition: TypeDefinition): void`
Registers a type. This function should be called from within the type definition ModuleScript.

#### `Registry:GetType(name: string): TypeDefinition?`
Returns a type definition with the given name, or nil if it doesn't exist.

#### `Registry:RegisterHooksIn(container: Instance): void`
Registers all hooks from within a container on both the server and the client. This only needs to be called server-side. See the Hooks section for examples. If you want to add a hook to the server or the client *only* (not on both), then you should use the Registry:RegisterHook method directly by requiring Cmdr in a server or client script.

#### `Registry:RegisterCommandsIn(container: Instance, filter?: function(command: CommandDefinition) => boolean): void`
Registers all commands from within a container. `filter` is an optional function, and if given will be passed a command definition which will only be registered if the function returns `true`. This only needs to be called server-side.

#### `Registry:RegisterCommand(commandScript: ModuleScript, commandServerScript?: ModuleScript, filter?: function(command: CommandDefinition) => boolean): void`
Registers an individual command directly from a module script and possible server script. For most cases, you should use RegisterCommandsIn instead.

#### `Registry:RegisterDefaultCommands(groupsOrFilterFunc?: array<string> | function(command: CommandDefinition) => boolean): void`
Registers the default set of commands. See Default Commands above for more details.

#### `Registry:GetCommand(name: string): CommandDefinition?`
Returns the CommandDefinition of the given name, or nil if not registered. Command aliases are also accepted.

#### `Registry:GetCommands(): array<CommandDefinition>`
Returns an array of all commands (aliases not included).

#### `Registry:GetCommandsAsStrings(): array<string>`
Returns an array of all command names.

#### `Registry:RegisterHook(hookName: string, callback: function(context: CommandContext) => string?, priority: number = 0): void`
Adds a hook. This should probably be run on the server, but can also work on the client. Hooks run in order of priority (lower number runs first). See the Hooks section above.

#### `Registry:GetStore(name: string): table`
Returns a table saved with the given name. This is the same as `CommandContext:GetStore()`.

## Dispatcher
The Dispatcher handles parsing, validating, and evaluating commands. Exists on both client and server.

### Methods

#### `Dispatcher:Run(...: string): string`
This should be used to invoke commands programmatically as the local player. Accepts a variable number of arguments, which are all joined with spaces before being run. This function will raise an error if any validations occur, since it's only for hard-coded (or generated) commands. Client only.

#### `Dispatcher:EvaluateAndRun(text: string, executor?: Player, options: { Data?: any, IsHuman?: boolean }): string`
Runs a command as the given player. If called on the client, only text is required. Returns output or error test as a string. If the `data` parameter is given, it will be available with `CommandContext:GetData()`.

#### `Dispatcher:GetHistory(): array<string>`
(Client only) Returns an array of the user's command history. Most recent commands are inserted at the end of the array.

## CommandContext
This object represents a single command being run. It is passed as the first argument to command implementations.

### Properties

#### `CommandContext.Cmdr: Cmdr`
A reference to Cmdr. This may either be the server or client version of Cmdr depending on where the command is running.

#### `CommandContext.Dispatcher: Dispatcher`
The dispatcher that created this command.

#### `CommandContext.Name: string`
The name of the command

#### `CommandContext.Alias: string`
The specific alias of this command that was used to trigger this command (may be the same as `Name`)

#### `CommandContext.RawText: string`
The raw text that was used to trigger this command.

#### `CommandContext.Group: any`
The group this command is a part of. Defined in command definitions, typically a string.

#### `CommandContext.State: table`
A blank table that can be used to store user-defined information about this command's current execution. This could potentially be used with hooks to add information to this table which your command or other hooks could consume.

#### `CommandContext.Aliases: array<string>`
Any aliases that can be used to also trigger this command in addition to its name.

#### `CommandContext.Description: string`
The description for this command from the command definition.

#### `CommandContext.Executor: Player`
The player who ran this command.

#### `CommandContext.RawArguments: array<string>`
An array of strings which is the raw value for each argument.

#### `CommandContext.Arguments: array<ArgumentContext>`
An array of ArgumentContext objects, the parsed equivalent to RawArguments.

#### `CommandContext.Response: string?`
The command output, if the command has already been run. Typically only accessible in the AfterRun hook.

### Methods

#### `CommandContext:GetArgument(index: number): ArgumentContext`
Returns the ArgumentContext for the given index.

#### `CommandContext:GetData(): any`
Returns the command data that was sent along with the command. This is the return value of the `Data` function from the command definition.

#### `CommandContext:GetStore(name: string): table`
Returns a table of the given name. Always returns the same table on subsequent calls. Useful for storing things like ban information. Same as Registry:GetStore.

#### `CommandContext:SendEvent(player: Player, event: string, ...: any): void`
Sends a network event of the given name to the given player. See Network Event Handlers.

#### `CommandContext:BroadcastEvent(event: string, ...: any): void`
Broadcasts a network event to all players. See Network Event Handlers.

#### `CommandContext:Reply(text: string, color?: Color3): void`
Prints the given text in the user's console. Useful for when a command needs to print more than one message or is long-running. You should still `return` a string from the command implementation when you are finished, `Reply` should only be used to send additional messages before the final message.

## ArgumentContext
This object represents an argument from a CommandContext.

### Properties

#### `ArgumentContext.Command: CommandContext`
The command that this argument belongs to.

#### `ArgumentContext.Name: string`
The name of this argument.

#### `ArgumentContext.Type: TypeDefinition`
The type definition for this argument.

#### `ArgumentContext.Required: boolean`
Whether or not this argument was required.

#### `ArgumentContext.Executor: Player`
The player that ran the command this argument belongs to.

#### `ArgumentContext.RawValue: string`
The raw, unparsed value for this argument.

#### `ArgumentContext.RawSegments: array<string>`
An array of strings representing the values in a comma-separated list, if applicable. If this type isn't listable,

#### `ArgumentContext.Prefix: string`
The prefix used in this argument (like `%` in `%Team`). Empty string if no prefix was used. See Prefixed Union Types for more details.

### Methods

#### `ArgumentContext:GetValue(): any`
Returns the parsed value for this argument.

#### `ArgumentContext:GetTransformedValue(segment: number): any...`
Returns the *transformed value* from this argument, see Types.

## Util

### Methods

#### `Util.MakeDictionary(array: array<any>): dictionary<any, true>`
Accepts an array and flips it into a dictionary, its values becoming keys in the dictionary with the value of `true`.

#### `Util.Map(array: array<any>, callback: (value: any, index: number) => any): array<any>`
Maps values from one array to a new array. Passes each value through the given callback and uses its return value in the same position in the new array.

#### `Util.Each(callback: (value: any) => any, ...: any): any...
Maps arguments #2-n through callback and returns all values as tuple.

#### `Util.MakeFuzzyFinder(setOrContainer: array<string> | array<Instance> | array<EnumItem> | array<{Name: string}> | Instance): function(text: string, returnFirst?: boolean) => any`
Makes a fuzzy finder for the given set or container. You can pass an array of strings, array of instances, array of EnumItems, array of dictionaries with a `Name` key or an instance (in which case its children will be used).

Returns a function that accepts a string and returns a table of matching objects. Exact matches are inserted in the front of the resultant array.

#### `Util.GetNames(instances: array<Instance>): array<string>`
Accepts an array of instances (or anything with a `Name` property) and maps them into an array of their names.

#### `Util.SplitStringSimple(text: string, separator: string): array<string>`
Slits a string into an array split by the given separator.

#### `Util.SplitString(text: string, max?: number): array<string>`
Splits a string by spaces, but taking double-quoted sequences into account which will be treated as a single value.

#### `Util.TrimString(text: string): string`
Trims whitespace from both sides of a string.

#### `Util.GetTextSize(text: string, label: TextLabel, size?: Vector2): Vector2`
Returns the text bounds size as a Vector2 based on the given label and optional display size. If size is omitted, the absolute width is used.

#### `Util.MakeEnumType(name: string, values: array<string>): TypeDefinition`
Makes an Enum type out of a name and an array of strings. See Enum Values.

#### `Util.MakeListableType(type: TypeDefinition): TypeDefinition`
Takes a singular type and produces a plural (listable) type out of it.

#### `Util.MakeSequenceType(options: dictionary): TypeDefinition`
A helper function that makes a type which contains a sequence, like Vector3 or Color3. The delimeter can be either `,` or whitespace, checking `,` first. `options` is a table that can contain:

- `TransformEach(value: any) => any`: a function that is run on each member of the sequence, transforming it individually.
- `ValidateEach(value: any, index: number) => boolean, string`: a function is run on each member of the sequence validating it. It is passed the value and the index at which it occurs in the sequence. It should return true if it is valid, or false and a string reason if it is not.

And one of:
- `Parse(values: array<any>) => any`: A function that parses all of the values into a single type.
- `Constructor(...: any) => any`: A function that expects the values unpacked as parameters to create the parsed object. This is a shorthand that allows you to set `Constructor` directly to `Vector3.new`, for example.

#### `Util.SplitPrioritizedDelimeter(text: string, delimiters: array<string>): array<string>`
Splits a string by a single delimeter chosen from the given set. The first matching delimeter from the set becomes the split character.

#### `Util.SubstituteArgs(text: string, replace: array<string> | dictionary<string, string> | function(var: string) => string): string`
Accepts a string with arguments (such as $1, $2, $3, etc) and a table or function to use with `string.gsub`. Returns a string with arguments replaced with their values.

#### `Util.RunEmbeddedCommands(dispatcher: Dispatcher, commandString: string): string`
Accepts the current dispatcher and a command string. Parses embedded commands from within the string, evaluating to the output of the command when run with `dispatcher:EvaluateAndRun`. Returns the compiled string.

#### `Util.EmulateTabstops(text: string, tabWidth: number): string`
Returns a string emulating \t tab stops with spaces.

#### `Util.ParseEscapeSequences(text: string): string`
Replaces escape sequences with their fully qualified characters in a string. This only parses `\n`, `\t`, `\uXXXX`, and `\xXX` where `X` is any hexadecimal character.