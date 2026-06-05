local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local Chat = game:GetService("Chat")

return function(context, text)
	local filteredText = TextService:FilterStringAsync(
		text,
		context.Executor.UserId,
		Enum.TextFilterContext.PublicChat
	)

	local message = filteredText:GetNonChatStringForBroadcastAsync()

	for _, player in ipairs(Players:GetPlayers()) do
		if Chat:CanUsersChatAsync(context.Executor.UserId, player.UserId) then
			context:SendEvent(
				player,
				"Message",
				message,
				context.Executor
			)
		end
	end

	return "Created announcement."
end
