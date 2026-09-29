const ContextActionService = game:GetService("ContextActionService")
const Players = game:GetService("Players")
const TextChatService = game:GetService("TextChatService")

local hasHelperRan = false

const function runBindHelper(Cmdr)
	Players.PlayerRemoving:Connect(function(player: Player)
		Cmdr.Registry:GetStore("CMDR_Binds")[player] = nil
	end)

	TextChatService.MessageReceived:Connect(function(message: TextChatMessage)
		const senderId = message.TextSource and message.TextSource.UserId
		const player = senderId and Players:GetPlayerByUserId(senderId)
		const playerBind = player and Cmdr.Registry:GetStore("CMDR_Binds")[player]
		if playerBind then
			playerBind(message)
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
		if type(binds[bind]) == "string" then
			ContextActionService:UnbindAction(binds[bind])
		end

		const Util = context.Cmdr.Util
		const commandString = `{command} {arguments}`

		if context:GetArgument(1).Type.Name == "userInput" then
			const actionName = `evaera/Cmdr/bind_{bind}`

			const function runCommand()
				context:Reply(
					context.Dispatcher:EvaluateAndRun(Util.RunEmbeddedCommands(context.Dispatcher, commandString))
				)
			end

			ContextActionService:BindActionAtPriority(actionName, function(_, state: Enum.UserInputState)
				if state == Enum.UserInputState.Begin then
					task.spawn(runCommand)
				end

				return Enum.ContextActionResult.Pass
			end, false, Enum.ContextActionPriority.High.Value, bind)

			binds[bind] = actionName
		else
			binds[bind] = function(message: TextChatMessage)
				const chatCommand =
					Util.RunEmbeddedCommands(context.Dispatcher, Util.SubstituteArgs(commandString, { message.Text }))
				const result = context.Dispatcher:EvaluateAndRun(chatCommand)
				context:Reply(`{bind.Name} $ {chatCommand} : {result}`, Color3.fromRGB(244, 92, 66))
			end
		end

		return "Bound command to input."
	end,
}
