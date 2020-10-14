---
title: Commands
---

# Commands

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

Check out the <ApiLink to="Registry.CommandDefinition">API reference</ApiLink> full details.

The implementation should be in a separate ModuleScript. Cmdr will never deliver the server implementation to the client. This module should only return one function. The module must be named the same thing as the definition module as described above, with the word "Server" appended to the end.

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

## Command Data

If you need to gather some data from the client before the command runs, you can create a <ApiLink to="Registry.CommandDefinition">`Data`</ApiLink> function in your command. This function will run on the client, and whatever is returned from it will be available with `context:GetData()` in the command implementation.

As an example, you might want to know the local player's current mouse world position in a server command. This can be achieved by returning `LocalPlayer:GetMouse().Hit.Position` from the Data function, then using `context:GetData()` to get the Vector3.

`context:GetData()` will work on both client and server commands.

## Client commands

It is possible to have commands that run on the client exclusively or both.

If you want your command to run on the client, you can add a <ApiLink to="Registry.CommandDefinition">`ClientRun`</ApiLink> function to the command definition itself. It works exactly like the function that you would return from the Server module.

If using `ClientRun`, having a Server module associated with this command is optional.

- If your `ClientRun` function returns a string, the command will run entirely on the client and won't touch the server at all (which means server-only hooks won't run).
- If this function doesn't return anything, it will then execute the associated Server module implementation on the server.

::: warning
If this function is present and there isn't a Server module for this command, it is considered an error to not return a string from this function.
:::

## Execution order

Including [Hooks](Hooks.md), the full execution order is:

1. `BeforeRun` hook on client.
2. `Data` function on client.
3. `ClientRun` function on client.
4. `BeforeRun` hook on server. *
5. Server command implementation returned from Server module. *
6. `AfterRun` hook on server. *
7. `AfterRun` hook on client.

\* Only runs if `ClientRun` isn't present or `ClientRun` returns `nil`.

## Default Commands
If you run `Cmdr:RegisterDefaultCommands()`, these commands will be available with the following `Group`s:

Group: `DefaultAdmin`: `announce` (`m`), `bring`, `kick`, `teleport` (`tp`), `kill`, `respawn`, `to`

Group: `DefaultDebug`: `blink` (`b`), `thru` (`t`), `position`, `version`, `fetch`, `get-player-place-instance`, `uptime`
Group: `DefaultUtil`: `alias`, `bind`, `unbind`, `run` (`>`), `runif`, `echo`, `hover`, `replace` (`//`, `gsub`), `history`, `me`, `var`, `var=`, `json-array-encode`, `json-array-decode`, `resolve`, `len`, `pick`, `rand`, `edit`, `goto-place`

Group: `Help`: `help`

### Registering a subset of the default commands
If you only want some, but not all, of the default commands, you can restrict the commands that you register in two ways.

1. Pass an array of groups to the RegisterDefaultCommands function: `Cmdr:RegisterDefaultCommands({"Help", "DefaultUtil"})`
2. Pass a filter function that accepts a CommandDefinition and either returns `true` or `false`:

```lua
Cmdr:RegisterDefaultCommands(function(cmd)
	return #cmd.Name < 6 -- This is absurd... but possible!
end)
```

## Argument Value Operators

Instead of typing out an entire argument, you can insert the following operators as a shorthand.

| Operator | Meaning | Listable types only |
| -------- | ------- | ------------------- |
| `.`      | Default value for the type | No
| `?`      | A random value from all possible values | No
| `*`      | A list of all possible values | Yes
| `**`     | All possible values minus the default value. | Yes
| `?N`     | N random values picked from all possible values | Yes

"All possible values" is determined automatically by using the values that are displayed in the autocomplete menu when you haven't typed anything for that argument yet.

If you want Cmdr to interpret the operator as literal text, you can escape these operators by inserting a `\` before them. For example: `\*` will be interpreted as a literal `*`.

### Example

For the `players` type, this is the meaning of the operators:


| Operator | Meaning |
| -------- | ------ |
| `.`      | "me", or the player who is running the command.
| `?`      | A random single player.
| `*`      | All players.
| `**`     | "others", or all players who aren't the player running the command.
| `?N`     | N random players.

So: `kill *` kills all players, while `kill **` kills all players but you.

### `resolve` command

The `resolve` command can be used to retrieve the true value of these operators as a list. It takes a type and an operator as arguments, and returns the list as a string.

Examples:

| Input | Output |
| ----- | ------ |
| `resolve players .` | `Player1`
| `resolve players *` | `Player1,Player2,Player3,Player4`
| `resolve players **`| `Player2,Player3,Player4`
| `resolve players ?` | `Player3`

## Prefixed Union Types
An argument can be allowed to accept a different type when starting with a specific prefix. The most common example of this is with the `players` type, which when prefixed with % allows the user to select players based on team, rather than name.

These can be defined on a per-argument basis, so that your commands can accept many types of arguments in a single slot. Under the Args section of command definition, each argument has a `Type` key.  For arguments that accept only a single type, it would look like `Type = "string"`. If we also wanted to accept a number when the user prefixes the argument with `#`, we could change it to: `Type = "string # number"`. Then, if the user provided `#33` for this argument, your function would be delivered the number value `33` in that position.

This is infinitely expandable, and you can include as many prefixed union types as you wish: `Type = "string # number @ player % team"`, etc. Remember that there must be a space between the symbol and the type.

Some default types automatically have a prefixed union type applied to them, because they would both resolve to the same type in the end. For example, whenever you define an argument of type `players`, under the hood this is perceived as `players % teamPlayers`. (`teamPlayers` is a type that matches based on team name, but resolves to an array of Players: the same thing that the normal `players` type would resolve with.)

Here is a list of automatic prefixed union types:

| Type | Union |
|------|-------|
| `players` | `players % teamPlayers`
| `playerId` | `playerId # integer`
| `playerIds` | `playerIds # integers`
| `brickColor` | `brickColor % teamColor`
| `brickColors` | `brickColors % teamColors`
| `color3` | `color3 # hexColor3 ! brickColor3`
| `color3s` | `color3s # hexColor3s ! brickColor3s`
