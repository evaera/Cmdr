local TextService = game:GetService("TextService")

return function(context, text)
	local filterSuccess, filteredText = pcall(function()
		local filterResult =
			TextService:FilterStringAsync(text, context.Executor.UserId, Enum.TextFilterContext.PublicChat)
		return filterResult:GetNonChatStringForBroadcastAsync()
	end)

	if filterSuccess then
		context:BroadcastEvent("Message", filteredText)
		return "Created announcement."
	end

	return `Failed to filter announcement: {filteredText}`
end
