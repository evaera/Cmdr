local TextChatService = game:GetService("TextChatService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

return function(context, text)
	local success, filterResult = pcall(function(...)
		return TextService:FilterStringAsync(text, context.Executor.UserId, Enum.TextFilterContext.PublicChat)
	end)

	if success then
		local filteredText = filterResult:GetNonChatStringForBroadcastAsync()

		for _, player in ipairs(Players:GetPlayers()) do
			if TextChatService:CanUsersChatAsync(context.Executor.UserId, player.UserId) then
				context:SendEvent(player, "Message", filteredText)
			end
		end

		return "Created announcement."
	end

	return "Failed to filter announcement!"
end
