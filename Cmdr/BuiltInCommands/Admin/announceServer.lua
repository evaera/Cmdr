local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

return function(context, text)
	for _, player in ipairs(Players:GetPlayers()) do
		if TextChatService:CanUsersChatAsync(context.Executor.UserId, player.UserId) then
			context:SendEvent(player, "Message", text)
		end
	end

	return "Created announcement."
end
