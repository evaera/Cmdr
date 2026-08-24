# Guards

Guards are command-specific check functions defined directly in a command definition file. They work similarly to `BeforeRun` hooks, but instead of applying globally across your entire registry, they run exclusively for the command they are attached to.

When you have requirements that pop up across multiple commands, such as checking if a player has an active character alive in the workspace or verifying an attribute, guards let you abstract those conditions into reusable functions rather than cluttering your actual command logic.

## Defining guards

You declare guards by adding a `Guards` array to your command definition table. Each entry in the array is a function that receives the [`CommandContext`](/api/CommandContext) as its first argument.

```luau title="teleport.luau"
const function hasAliveCharacter(context: any): string?
	const character = context.Executor.Character
	const humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return "You must be alive to run this command."
	end
end

const function isCreator(context: any): string?
	if context.Executor.UserId ~= game.CreatorId then
		return "You are not allowed to do this!"
	end
end

return {
	Name = "teleport",
	Aliases = { "tp" },
	Description = "Teleports you to another player.",
	Group = "Admin",
	Guards = {
		hasAliveCharacter,
		isCreator,
	},
	Args = {
		{
			Type = "player",
			Name = "to",
			Description = "The player to teleport to",
		},
	},
}
```

## Execution flow and behavior

Cmdr processes guards sequentially in the order they are listed inside the `Guards` array.

- **Passing checks:** If a guard function returns `nil` (or nothing at all), Cmdr moves straight to the next step in the execution pipeline.
- **Interrupting execution:** If a guard returns any non-nil value (typically an error string), Cmdr immediately halts execution. The returned value is displayed to the executing player in the console as the command response.

Because command definitions are shared between client and server, guards are evaluated on the client first during UI invocation, and evaluated **again on the server** prior to running server code to prevent exploiters from bypassing client checks.

Including [Hooks](/docs/hooks) and client functions, the full execution order is:

1. `BeforeRun` hook on client.
2. Command `Guards` on client.
3. `Data` function on client.
4. `ClientRun` function on client.
5. `BeforeRun` hook on server. \*
6. Command `Guards` on server. \*
7. Server command implementation returned from Server module. \*
8. `AfterRun` hook on server. \*
9. `AfterRun` hook on client.

_\* Only runs if `ClientRun` isn't present or `ClientRun` returns `nil`._

## Parameters and varargs

The dispatcher passes the current [`CommandContext`](/api/CommandContext) as the primary argument to each guard function.

```luau
Guards = {
	function(context: any, ... any): string?
		-- context gives you access to Executor, Arguments, Cmdr, etc.
	end,
}
```

Behind the scenes, Cmdr's dispatcher also passes through any additional varargs supplied during internal dispatching. While standard command execution won't pass extra arguments beyond the context, this keeps guard execution consistent with how hooks receive arbitrary parameters.

## When to use guards vs. hooks

Use **`BeforeRun` hooks** when you need global policies, such as blocking all admin commands across the game if a player isn't on a whitelist or is banned.

Use **Guards** when a check only applies to a specific command (or a small set of commands), or when you want to write modular, self-contained preconditions that live alongside the command definition.
