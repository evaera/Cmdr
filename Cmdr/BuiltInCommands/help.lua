local ARGUMENT_SHORTHANDS = [[
Argument Shorthands
-------------------			
.   Me/Self
*   All/Everyone 
**  Others 
?   Random
?N  List of N random values			
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
			context:Reply(("Command: %s"):format(command.Name), Color3.fromRGB(230, 126, 34))
			if command.Aliases and #command.Aliases > 0 then
				context:Reply(("Aliases: %s"):format(table.concat(command.Aliases, ", ")), Color3.fromRGB(230, 230, 230))
			end
			context:Reply(command.Description, Color3.fromRGB(230, 230, 230))
			for i, arg in ipairs(command.Args) do
				context:Reply(("#%d %s%s: %s - %s"):format(
					i,
					arg.Name,
					arg.Optional == true and "?" or "",
					arg.Type, arg.Description
				))
			end
		else
			context:Reply(ARGUMENT_SHORTHANDS)

			local commands = context.Cmdr.Registry:GetCommands()
			table.sort(commands, function(a, b)
				return a.Group < b.Group
			end)
			local lastGroup
			for _, command in ipairs(commands) do
				if lastGroup ~= command.Group then
					context:Reply(("\n%s\n-------------------"):format(command.Group))
					lastGroup = command.Group	
				end
				context:Reply(("%s - %s"):format(command.Name, command.Description))
			end
		end
		return ""
	end;
}
