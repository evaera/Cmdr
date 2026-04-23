local TextChatService = game:GetService("TextChatService")
local Window = require(script.Parent.CmdrInterface.Window)

return function(Cmdr)
	Cmdr:HandleEvent("Message", function(text)
		TextChatService.TextChannels.RBXSystem:DisplaySystemMessage(
			`<font color="rgb(249, 217, 56)">[Announcement] {text}</font>`
		)
	end)

	Cmdr:HandleEvent("AddLine", function(...)
		Window:AddLine(...)
	end)
end
