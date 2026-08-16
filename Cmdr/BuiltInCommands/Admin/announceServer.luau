const TextService = game:GetService("TextService")

return function(context: any, text: string): string
	const filterSuccess, filteredText = pcall(function()
		const filterResult =
			TextService:FilterStringAsync(text, context.Executor.UserId, Enum.TextFilterContext.PublicChat)

		return filterResult:GetNonChatStringForBroadcastAsync()
	end)

	if not filterSuccess then
		return `Failed to filter announcement: {filteredText}`
	end

	context:BroadcastEvent("Message", filteredText, context.Executor)
	return "Created announcement."
end
