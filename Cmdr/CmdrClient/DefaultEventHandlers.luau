const TextChatService = game:GetService("TextChatService")

const TEXT_CHANNELS = TextChatService:WaitForChild("TextChannels")
const RBXSYSTEM_CHANNEL: TextChannel = TEXT_CHANNELS:WaitForChild("RBXSystem")

return function(CmdrClient)
	CmdrClient:HandleEvent("Message", function(text: string)
		RBXSYSTEM_CHANNEL:DisplaySystemMessage(`<font color="rgb(249, 217, 56)">[Announcement] {text}</font>`)
	end)

	CmdrClient:HandleEvent("AddLine", function(...: any)
		CmdrClient._interface.Window:AddLine(...)
	end)

	CmdrClient:HandleEvent("RunBeforeCommandRegisterHooks", function()
		CmdrClient.Dispatcher:RunBeforeCommandRegisterHooks()
	end)
end
