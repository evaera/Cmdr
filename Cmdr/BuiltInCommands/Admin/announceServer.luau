const TextService = game:GetService("TextService")
local lastAnnouncement = 0

return function(context: any, text: string): string
	-- This is silly, but it's what Roblox has said is needed.
	if (os.time() - lastAnnouncement) < 60 then
		return `You need to wait {math.ceil(os.time() - lastAnnouncement)} seconds before another announcement can be made.`
	end
	const filterSuccess, filteredText = pcall(function()
		const filterResult =
			TextService:FilterStringAsync(text, context.Executor.UserId, Enum.TextFilterContext.PublicChat)

		return filterResult:GetNonChatStringForBroadcastAsync()
	end)

	if not filterSuccess then
		return `Failed to filter announcement: {filteredText}`
	end

	lastAnnouncement = os.time()
	context:BroadcastEvent("Message", filteredText, context.Executor)
	return "Created announcement."
end
