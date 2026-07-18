local TextService = game:GetService("TextService")

return function(context, players, reason)
	if reason:match("^%s*$") then
		reason = "No reason provided"
	end

	local success, filteredReason = pcall(function()
		local filterResult =
			TextService:FilterStringAsync(reason, context.Executor.UserId, Enum.TextFilterContext.PublicChat)
		return filterResult:GetNonChatStringForBroadcastAsync()
	end)

	if success then
		for _, player in pairs(players) do
			player:Kick(filteredReason)
		end

		return `Kicked {#players} players.`
	end

	return `Failed to filter reason: {filteredReason}`
end
