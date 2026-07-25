const COMMAND_COLOR = Color3.fromRGB(230, 126, 34)
const TEXT_COLOR = Color3.fromRGB(230, 230, 230)

const ARGUMENT_SHORTHANDS = [[
Argument Shorthands
-------------------
.   Me/Self
*   All/Everyone
**  Others
?   Random
?N  List of N random values
]]

const TIPS = [[
Tips
----
• Utilize the Tab key to automatically complete commands
• Easily select and copy command output
]]

return {
	Name = "help",
	Aliases = { "cmds", "commands" },
	Description = "Displays a list of all commands, or inspects one command.",
	Group = "Help",

	Args = {
		{
			Type = "command",
			Name = "Command",
			Description = "The command to view information on.",
			Optional = true,
		},
	},

	ClientRun = function(context: any, commandName: string): string
		const registry = context.Cmdr.Registry
		if commandName then
			const command = registry:GetCommand(commandName)
			context:Reply(`Command: {command.Name}`, COMMAND_COLOR)

			if command.Aliases and #command.Aliases > 0 then
				context:Reply(`Aliases: {table.concat(command.Aliases, ", ")}`, TEXT_COLOR)
			end

			if command.Description then
				context:Reply(`Description: {command.Description}`, TEXT_COLOR)
			end

			if command.Group then
				context:Reply(`Group: {command.Group}`, TEXT_COLOR)
			end

			if command.Args then
				for index, argument in ipairs(command.Args) do
					if type(argument) == "table" then
						const optional = argument.Optional and "?" or ""

						context:Reply(`#{index} {argument.Name}{optional}: {argument.Type} - {argument.Description}`)
					else
						context:Reply(`#{index} Unknown (inline argument)`)
					end
				end
			end
		else
			context:Reply(ARGUMENT_SHORTHANDS)
			context:Reply(TIPS)

			const commands = registry:GetCommands()
			table.sort(commands, function(a, b)
				if a.Group and b.Group then
					return a.Group < b.Group
				end

				return a.Group ~= nil
			end)

			local lastGroup
			for _, command in ipairs(commands) do
				if command._isHidden then
					continue
				end

				const group = command.Group or "No Group"
				if lastGroup ~= group then
					context:Reply(`\n{group}\n{string.rep("-", #group)}`)
					lastGroup = group
				end

				context:Reply(command.Description and `{command.Name} - {command.Description}` or command.Name)
			end
		end

		return ""
	end,
}
