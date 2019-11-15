local UserInputService = game:GetService("UserInputService")

return {
	Name = "bind";
	Aliases = {};
	Description = "Binds a command string to a key or mouse input.";
	Group = "DefaultUtil";
	Args = {
		{
			Type = "userInput ! bindableResource @ player";
			Name = "Input";
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
			Default = "";
		}
	};

	ClientRun = function(context, bind, command, arguments)
		local binds = context:GetStore("CMDR_Binds")

		command = command .. " " .. arguments

		if binds[bind] then
			binds[bind]:Disconnect()
		end

		local bindType = context:GetArgument(1).Type.Name

		if bindType == "userInput" then
			binds[bind] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then
					return
				end

				if input.UserInputType == bind or input.KeyCode == bind then
					context:Reply(context.Dispatcher:EvaluateAndRun(context.Cmdr.Util.RunEmbeddedCommands(context.Dispatcher, command)))
				end
			end)
		elseif bindType == "bindableResource" then
			return "Unimplemented..."
		elseif bindType == "player" then
			binds[bind] = bind.Chatted:Connect(function(message)
				local args = { message }
				local chatCommand = context.Cmdr.Util.RunEmbeddedCommands(context.Dispatcher, context.Cmdr.Util.SubstituteArgs(command, args))
				context:Reply(("%s $ %s : %s"):format(
					bind.Name,
					chatCommand,
					context.Dispatcher:EvaluateAndRun(chatCommand)
				), Color3.fromRGB(244, 92, 66))
			end)
		end


		return "Bound command to input."
	end
}