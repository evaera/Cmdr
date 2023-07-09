local ARGUMENT_SHORTHANDS = [[
Argument Shorthands
-------------------
.   Me/Self
*   All/Everyone
**  Others
?   Random
?N  List of N random values
]]

local TIPS = [[
Tips
----
• Utilize the Tab key to automatically complete commands
• Easily select and copy command output
]]

return {
	Name = "help";
	Description = "Displays a list of all commands, or inspects one command.";
	Group = "Help";
	Args = {
		{
			Type = "command";
			Name = "Command";
			Description = "The command to view information on";
			Optional = true;
		},
	};

	ClientRun = function (context, commandName)
		if commandName then
			local command = context.Cmdr.Registry:GetCommand(commandName)
			context:Reply(`Command: {command.Name}`, Color3.fromRGB(230, 126, 34))
			if command.Aliases and #command.Aliases > 0 then
				context:Reply(`Aliases: {table.concat(command.Aliases, ", ")}`, Color3.fromRGB(230, 230, 230))
			end
			context:Reply(command.Description, Color3.fromRGB(230, 230, 230))
			for i, arg in ipairs(command.Args) do
				context:Reply(
					`#{i} {arg.Name}{if arg.Optional == true then "?" else ""}: {arg.Type} - {arg.Description}`
				)
			end
		else
			context:Reply(ARGUMENT_SHORTHANDS)
			context:Reply(TIPS)

			local commands = context.Cmdr.Registry:GetCommands()
			table.sort(commands, function(a, b)
				return if a.Group and b.Group then a.Group < b.Group else a.Group
			end)
			local lastGroup
			for _, command in ipairs(commands) do
				command.Group = command.Group or "No Group"
				if lastGroup ~= command.Group then
					context:Reply(`\n{command.Group}\n{string.rep("-", #command.Group)}`)
					lastGroup = command.Group
				end
				context:Reply(if command.Description then `{command.Name} - {command.Description}` else command.Name)
			end
		end
		return ""
	end;
}
