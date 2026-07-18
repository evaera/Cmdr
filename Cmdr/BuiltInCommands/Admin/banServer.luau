local Players = game:GetService("Players")

return function(
	_,
	playerIds,
	duration,
	displayReason,
	privateReason,
	excludeAltAccounts,
	applyToUniverse,
	applyDeviceBlock
)
	if #playerIds > 50 then
		return "Too many players specified. BanAsync limits batches to a maximum of 50 players."
	end

	if displayReason:match("^%s*$") then
		return "Display reason cannot be empty."
	end

	if not privateReason or privateReason:match("^%s*$") then
		privateReason = displayReason
	end

	if #displayReason > 400 then
		return "Display reason exceeds the 400-character limit."
	end

	if #privateReason > 1000 then
		return "Private reason exceeds the 1000-character limit."
	end

	if duration < 1 and duration ~= -1 then
		duration = -1
	end

	local success, errorMessage = pcall(Players.BanAsync, Players, {
		UserIds = playerIds,
		Duration = duration,
		DisplayReason = displayReason,
		PrivateReason = privateReason,
		ExcludeAltAccounts = excludeAltAccounts,
		ApplyToUniverse = applyToUniverse,
		ApplyDeviceBlock = applyDeviceBlock,
	})

	return if success then `Banned {#playerIds} players.` else `BanAsync failed: {errorMessage}`
end
