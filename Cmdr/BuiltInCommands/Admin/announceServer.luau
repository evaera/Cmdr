local TextService = game:GetService("TextService")

return function(context, text)
	if text:match("^%s*$") then
		return "Announce text cannot be empty."
	end

	local filterSuccess, filteredText = pcall(function()
		local filterResult =
			TextService:FilterStringAsync(text, context.Executor.UserId, Enum.TextFilterContext.PublicChat)
		return filterResult:GetNonChatStringForBroadcastAsync()
	end)

	if not filterSuccess then
		return `Failed to filter announcement: {filteredText}`
	end

	context:BroadcastEvent("Message", filteredText)
	return "Created announcement."
end
