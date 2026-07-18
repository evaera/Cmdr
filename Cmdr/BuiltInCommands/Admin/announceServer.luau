local TextChatService = game:GetService("TextChatService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

return function(context, text)
	local filterSuccess, filteredText = pcall(function()
		local filterResult =
			TextService:FilterStringAsync(text, context.Executor.UserId, Enum.TextFilterContext.PublicChat)
		return filterResult:GetNonChatStringForBroadcastAsync()
	end)

	if filterSuccess then
		for _, player in ipairs(Players:GetPlayers()) do
			local canChatSuccess, canChat =
				pcall(TextChatService.CanUsersChatAsync, TextChatService, context.Executor.UserId, player.UserId)

			if canChatSuccess and canChat then
				context:SendEvent(player, "Message", filteredText)
			elseif not canChatSuccess then
				context:Reply(`There was an error checking if you can chat with {player.Name}: {canChat}`)
			end
		end

		return "Created announcement."
	end

	return `Failed to filter announcement: {filteredText}`
end
