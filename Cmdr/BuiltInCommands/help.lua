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
			local commands = context.Cmdr.Registry:GetCommands()

			for _, cmd in pairs(commands) do
				context:Reply(("%s - %s"):format(cmd.Name, cmd.Description))
			end
		end
		return ""
	end;
}