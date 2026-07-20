local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")

local hasHelperRan = false
local function runBindHelper(Cmdr)
	Players.PlayerRemoving:Connect(function(Player)
		local binds = Cmdr.Registry:GetStore("CMDR_Binds")
		if binds[Player] then
			binds[Player] = nil
		end
	end)

	TextChatService.MessageReceived:Connect(function(message: TextChatMessage)
		local senderId = message.TextSource and message.TextSource.UserId
		local player = senderId and Players:GetPlayerByUserId(senderId)
		if not player then
			return
		end

		local binds = Cmdr.Registry:GetStore("CMDR_Binds")
		if binds[player] then
			binds[player](message)
		end
	end)

	hasHelperRan = true
end

return {
	Name = "bind",
	Aliases = {},
	Description = "Binds a command string to a key or mouse input.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "userInput ! bindableResource @ player",
			Name = "Input",
			Description = "The key or input type you'd like to bind the command to.",
		},
		{
			Type = "command",
			Name = "Command",
			Description = "The command you want to run on this input",
		},
		{
			Type = "string",
			Name = "Arguments",
			Description = "The arguments for the command",
			Default = "",
		},
	},

	ClientRun = function(context, bind, command, arguments)
		if not hasHelperRan then
			runBindHelper(context.Cmdr)
		end

		local binds = context:GetStore("CMDR_Binds")
		if binds[bind] then
			if typeof(binds[bind]) == "RBXScriptConnection" then
				binds[bind]:Disconnect()
			end

			binds[bind] = nil
		end

		command = command .. " " .. arguments

		local bindType = context:GetArgument(1).Type.Name
		if bindType == "userInput" then
			binds[bind] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then
					return
				end

				if input.UserInputType == bind or input.KeyCode == bind then
					context:Reply(
						context.Dispatcher:EvaluateAndRun(
							context.Cmdr.Util.RunEmbeddedCommands(context.Dispatcher, command)
						)
					)
				end
			end)
		elseif bindType == "bindableResource" then
			return "Unimplemented..."
		elseif bindType == "player" then
			binds[bind] = function(message: TextChatMessage)
				local args = { message.Text }
				local chatCommand = context.Cmdr.Util.RunEmbeddedCommands(
					context.Dispatcher,
					context.Cmdr.Util.SubstituteArgs(command, args)
				)

				context:Reply(
					("%s $ %s : %s"):format(bind.Name, chatCommand, context.Dispatcher:EvaluateAndRun(chatCommand)),
					Color3.fromRGB(244, 92, 66)
				)
			end
		end

		return "Bound command to input."
	end,
}
