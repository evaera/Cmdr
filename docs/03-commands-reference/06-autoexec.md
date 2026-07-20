# Automatic execution

The `AutoExec` feature allows commands to automatically run a pre-defined list of command strings the exact moment a command is registered. This creates a clean lifecycle hook for setting up shortcuts, environments, or initial state configurations without requiring manual user intervention.

## Why use AutoExec?

Before `AutoExec`, creating aliases or running initialization sequences required loose setup scripts scattered across your codebase. By leveraging `AutoExec` directly within your command definitions, you gain several benefits:

- **Encapsulated Setup:** Keep a command's initialization logic neatly bundled within its own definition file instead of polluting global bootstrap scripts.
- **Automated Macros:** Instantly register aliases, shortcuts, or configuration preferences as soon as a custom command becomes active.
- **Order Independence:** Commands inside an `AutoExec` array are safely deferred to the end of the current frame cycle. This guarantees that all types and dependent commands are completely registered, eliminating startup race conditions.

:::warning Client-Only Execution

`AutoExec` arrays **only execute on the client**. This avoids duplicate work on the server and safeguards performance.

:::

---

## Setting up persistent and session states with variables

Because `AutoExec` runs entirely on the client, you can combine it with the default `var` and `var=` commands to read, write, and manage localized configuration environments.

Cmdr supports a variety of scope prefixes for variable keys, allowing you to control whether your automated configurations stick around forever or clear out when you leave.

### Understanding key scopes

When interacting with keys via `var` or `var=`, pay close attention to the prefix characters:

| Prefix   | Scope                       | Storage Type                    | Perfect For                                                      |
| -------- | --------------------------- | ------------------------------- | ---------------------------------------------------------------- |
| **None** | User-Specific, Persistent   | Roblox `DataStoreService`       | Persistent user profiles, custom bindings, custom themes.        |
| `.`      | User-Specific, Session-Only | In-Memory (Server/Client Store) | Temporary runtime toggles, local debugging state.                |
| `$`      | Game-Wide, Persistent       | Roblox `DataStoreService`       | Global developer toggles, cross-server maintenance flags.        |
| `$.`     | Game-Wide, Session-Only     | In-Memory (Server/Client Store) | Current server-wide match preferences or temporary lobby states. |

---

## Best practices for AutoExec variables

### Pre-fill shorthand alias arguments

You can use `AutoExec` to instantly register macro shortcuts that point to more complex underlying framework commands. This is ideal for abstracting long argument chains into distinct, readable commands by hardcoding specific arguments early while passing remaining arguments (like `$1`, `$2`, etc.) along to the base function.

For example, you can cleanly map dedicated `bring` and `to` commands directly onto a central `teleport` backend by pre-filling contextual target variables like `${me}` alongside custom argument validation types:

```lua
AutoExec = {
	-- Maps "bring <players>" to pull others to your exact location
	'alias "bring|Brings a player or set of players to you." teleport $1{players|players|The players to bring} ${me}',

	-- Maps "to <destination>" to transport yourself instantly to a player or vector position
	'alias "to|Teleports you to another player or location." teleport ${me} $1{player @ positionVector3|Destination|The player or location to teleport to}',
}
```

### Chain commands sequentially using delimiters

You can run multiple distinct commands sequentially within a single `AutoExec` string by separating them with the `&&` delimiter. This is exceptionally powerful for evaluating or creating variables and immediately feeding them into structural macros.

```lua
AutoExec = {
	-- Creates an alias, then outputs a verification log sequentially
	"alias reset_debug var= .debugMode false && echo Debug environment has been reset!",
}
```

### Leverage the slot operator (`||`) to pass state

When chaining commands with `&&`, you can easily capture the output text of the previous command and inject it into the next one by using the `||` slot operator. If the captured text contains spaces, Cmdr will automatically wrap the injected value in quotes.

```lua
AutoExec = {
	-- Fetches the 'init' variable value and immediately passes it to the run-lines command
	"var init && run-lines ||",
}
```

### Handle script editing environments gracefully

If you want to let users view, update, or manually execute persistent strings (like startup scripts), you can use `AutoExec` blocks to cleanly establish editing macros. Combined with sub-command embedding (`${}`) and the slot operator (`||`), you can create streamlined workflows:

```lua
-- How Cmdr internally pairs variable initialization and script execution
AutoExec = {
	'alias "init-edit|Edit your initialization script" edit ${var init} \\\\\n && var= init ||',
	'alias "init-run|Re-runs the initialization script manually." run-lines ${var init}',
	"init-run",
}
```
