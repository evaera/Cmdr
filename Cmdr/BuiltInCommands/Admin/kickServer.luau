const TextService = game:GetService("TextService")

return function(context: any, players: { Player }, reason: string): string
	if reason:match("^%s*$") then
		reason = "No reason provided"
	end

	local filterSuccess, filteredReason = nil, reason
	if reason ~= "No reason provided" then
		filterSuccess, filteredReason = pcall(function()
			const filterResult =
				TextService:FilterStringAsync(reason, context.Executor.UserId, Enum.TextFilterContext.PublicChat)

			return filterResult:GetNonChatStringForBroadcastAsync()
		end)

		if not filterSuccess then
			return `Failed to filter reason: {filteredReason}`
		end
	end

	for _, player in ipairs(players) do
		player:Kick(filteredReason)
	end

	return `Kicked {#players} players.`
end
