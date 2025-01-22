local TextChatService = game:GetService("TextChatService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

return function(context, text)
	local filterResult = TextService:FilterStringAsync(text, context.Executor.UserId, Enum.TextFilterContext.PublicChat)

	for _, player in ipairs(Players:GetPlayers()) do
		if TextChatService:CanUsersChatAsync(context.Executor.UserId, player.UserId) then
			context:SendEvent(player, "Message", filterResult:GetChatForUserAsync(player.UserId), context.Executor)
		end
	end

	return "Created announcement."
end
