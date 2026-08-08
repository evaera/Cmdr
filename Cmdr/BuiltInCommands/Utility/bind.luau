const Players = game:GetService("Players")
const TextChatService = game:GetService("TextChatService")
const UserInputService = game:GetService("UserInputService")

local hasHelperRan = false

const function runBindHelper(Cmdr)
	Players.PlayerRemoving:Connect(function(Player)
		const binds = Cmdr.Registry:GetStore("CMDR_Binds")
		if binds[Player] then
			binds[Player] = nil
		end
	end)

	TextChatService.MessageReceived:Connect(function(message: TextChatMessage)
		const senderId = message.TextSource and message.TextSource.UserId
		const player = senderId and Players:GetPlayerByUserId(senderId)
		if not player then
			return
		end

		const binds = Cmdr.Registry:GetStore("CMDR_Binds")
		if binds[player] then
			binds[player](message)
		end
	end)

	hasHelperRan = true
end

return {
	Name = "bind",
	Description = "Binds a command string to a key or mouse input.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "userInput @ player",
			Name = "Input",
			Description = "The key or input type you'd like to bind the command to.",
		},
		{
			Type = "command",
			Name = "Command",
			Description = "The command you want to run on this input.",
		},
		{
			Type = "string",
			Name = "Arguments",
			Description = "The arguments for the command.",
			Default = "",
		},
	},

	ClientRun = function(
		context: any,
		bind: Enum.UserInputType | Enum.KeyCode | Player,
		command: string,
		arguments: string
	): string
		if not hasHelperRan then
			runBindHelper(context.Cmdr)
		end

		const binds = context:GetStore("CMDR_Binds")
		if binds[bind] then
			if typeof(binds[bind]) == "RBXScriptConnection" then
				binds[bind]:Disconnect()
			end

			binds[bind] = nil
		end

		command = `{command} {arguments}`

		const bindType = context:GetArgument(1).Type.Name
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
		elseif bindType == "player" then
			binds[bind] = function(message: TextChatMessage)
				const args = { message.Text }
				const chatCommand = context.Cmdr.Util.RunEmbeddedCommands(
					context.Dispatcher,
					context.Cmdr.Util.SubstituteArgs(command, args)
				)
				const result = context.Dispatcher:EvaluateAndRun(chatCommand)
				context:Reply(`{bind.Name} $ {chatCommand} : {result}`, Color3.fromRGB(244, 92, 66))
			end
		end

		return "Bound command to input."
	end,
}
