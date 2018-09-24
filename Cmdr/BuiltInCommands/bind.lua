local UserInputService = game:GetService("UserInputService")

return {
	Name = "bind";
	Aliases = {};
	Description = "Binds a command string to a key or mouse input.";
	Group = "DefaultUtil";
	Args = {
		{
			Type = "userInput";
			Name = "Input/Key";
			Description = "The key or input type you'd like to bind the command to."
		},
		{
			Type = "command";
			Name = "Command";
			Description = "The command you want to run on this input"
		},
		{
			Type = "string";
			Name = "Arguments";
			Description = "The arguments for the command";
			Optional = true;
		}
	};

	Run = function(context, inputEnum, command, arguments)
		arguments = arguments or ""

		local binds = context:GetStore("CMDR_Binds")

		if binds[inputEnum] then
			binds[inputEnum]:Disconnect()
		end

		binds[inputEnum] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.UserInputType == inputEnum or input.KeyCode == inputEnum then
				context:Reply(context.Dispatcher:EvaluateAndRun(command .. " " .. arguments))
			end
		end)

		return "Bound command to input."
	end
}