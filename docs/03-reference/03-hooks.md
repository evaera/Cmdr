# Hooks

Hooks are callback functions that you can register to tap into the command execution process. They are extremely useful for implementing permission systems, logging commands, or overriding command output.

Every hook callback receives the [`CommandContext`](/api/CommandContext) for the command, giving you full access to parsed arguments, execution context, and user metadata.

Hooks can be registered on either or both the server and the client:

- **Server commands** execute both client and server hooks.
- **Client commands** execute client hooks only.

Depending on your use case, you may need to register hooks on one or both sides. For example, command logging may only be needed on the server, whereas permission checks might need to run on the client as well as the server to prevent unnecessary network requests.

There can be multiple hooks registered for each phase. Hooks execute in **order of priority (lowest to highest)** until one returns a value that halts further execution.

## Registering hooks

You can register hooks manually with `Cmdr.Registry:RegisterHook`, or bulk-register them across both client and server using `Cmdr.Registry:RegisterHooksIn(folder)`.

```luau title="A ModuleScript inside your hooks folder."
return function(registry: any)
	registry:RegisterHook("BeforeRun", function(context: any): string?
		if context.Group == "DefaultAdmin" and context.Executor.UserId ~= game.CreatorId then
			return "You don't have permission to run this command"
		end
	end)
end
```

:::info Yielding

Hooks are blocking, meaning Cmdr will wait for them to run, so you should avoid yielding.

You can load data like a user's permissions or group roles into tables and read off of those tables, failing-deny if data hasn't loaded yet.

:::

## Hook priority and ordering

When registering a hook via `Cmdr.Registry:RegisterHook(hookName, callback, priority)`, you can pass an optional numeric `priority` argument (defaults to `0`).

- **Lowest values run first:** A hook with priority `-10` will run before a hook with priority `0`.
- **Higher values run later:** A hook with priority `10` will run after standard priority (`0`) hooks.
- **First return wins:** If a hook returns a halting value (such as a string for `BeforeRun` or `false` for `BeforeCommandRegister`), hook execution stops immediately.

## BeforeCommandRegister

:::info Version Requirement

`BeforeCommandRegister` was added in **v1.13.0**. If you are using an older release (such as **v1.12.0**), this hook is not yet available and attempting to register it will result in an error. Make sure your Cmdr installation is updated to use this feature.

:::

Command hiding can confuse users and there usually isn't actually a need for it. However, it can be achieved using a hook called `BeforeCommandRegister`. These hooks run on the **client** when command definitions are being loaded. It allows you to filter which commands are visible and available in the UI and autocomplete menu for a specific player.

- **Returning `false`:** Hides the command from console autocomplete, the `help` listing, and client execution.
- **Returning `nil`:** Registers and displays the command as normal.
- Any other return value will result in an error.

```luau title="Client-side hook"
return function(registry: any)
	registry:RegisterHook("BeforeCommandRegister", function(context: any): boolean?
		-- Prevent non-allowed users from seeing admin commands
		if context.Group == "Admin" and context.Executor.UserId ~= game.CreatorId then
			return false
		end

		-- Hide a specific command completely
		if context.Name == "ban" and not context.Executor:GetAttribute("IsModerator") then
			return false
		end

		return nil
	end)
end
```

`BeforeCommandRegister` hooks are automatically called when a command is being registered. You can use [`Dispatcher:RunBeforeCommandRegisterHooks`](/api/Dispatcher#RunBeforeCommandRegisterHooks), either on the server or client, to re-evaluate whether commands should be hidden or not; use this sparingly, for example when a user's permissions have meaningfully changed.

:::warning Client-only

`BeforeCommandRegister` only runs on the client; exploiters can bypass client-side code. Always enforce backend authorization checks using a `BeforeRun` hook on the server.

:::

The name is slightly misleading, because it can be ran against commands already registered, and commands will still be registered internally (just with a secret "hidden" flag). Command hiding is cosmetic only; any command definition or `ClientRun` methods will still be visible to exploiters. Your `BeforeCommandRegister` hooks can display commands which `BeforeRun` would block execution of (or vice versa).

:::warning Yielding

`BeforeCommandRegister` is called against every registered command, sequentially, when `RunBeforeCommandRegisterHooks` is called and when a command is registered.

**You should not yield in a `BeforeCommandRegister` hook, it will create performance issues.**

:::

## BeforeRun

The `BeforeRun` hook is the last step before a command implementation itself executes, so all parsed arguments and context properties are fully available.

Returning a string from a `BeforeRun` hook halts command execution immediately and displays that string to the user as an error or response message. Returning `nil` allows execution to continue normally.

:::warning Security warning

Commands will be blocked from running in a live game unless you register at least one `BeforeRun` hook. Commands in the `DefaultUtil` or `UserAlias` groups are exempt from this requirement.

:::

## AfterRun

The `AfterRun` hook executes immediately after a command finishes running. In addition to standard context properties, `context.Response` contains the string output generated by the command implementation (or a previous `AfterRun` hook).

If an `AfterRun` callback returns a string, it replaces the command's original response on the user's screen. If it returns `nil`, the response remains unchanged.

This hook is ideal for logging actions.

```luau title="Server-side hook registration"
-- Higher priority ensures this runs after standard response modifiers
Cmdr.Registry:RegisterHook("AfterRun", function(context: any)
	print(`{context.Executor.Name} ran {context.Text}: {context.Response}`)
	return nil
end, 10)
```

## Execution order

When a command is executed, Cmdr runs components in the following sequence (with hooks evaluated from lowest to highest priority):

1. `BeforeRun` hooks on client
2. `Data` function on client
3. `ClientRun` function on client
4. `BeforeRun` hooks on server \*
5. Server command implementation \*
6. `AfterRun` hooks on server \*
7. `AfterRun` hooks on client

\* _Only runs if `ClientRun` isn't present or returns `nil`._

:::info Security note

Exploiters can manipulate or bypass any code running on the client. Never rely exclusively on client-side `BeforeRun` or `BeforeCommandRegister` hooks for critical authorization checks. Always validate permissions on the server.

:::
