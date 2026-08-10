const Players = game:GetService("Players")

return function(
	_,
	playerIds: { number },
	duration: number,
	displayReason: string,
	privateReason: string?,
	excludeAltAccounts: boolean,
	applyToUniverse: boolean,
	applyDeviceBlock: boolean
): string
	const resolvedPrivateReason = if not privateReason or privateReason:match("^%s*$")
		then displayReason
		else privateReason

	const resolvedDuration = if duration < 1 and duration ~= -1 then -1 else duration

	const success, errorMessage = pcall(Players.BanAsync, Players, {
		UserIds = playerIds,
		Duration = resolvedDuration,
		DisplayReason = displayReason,
		PrivateReason = resolvedPrivateReason,
		ExcludeAltAccounts = excludeAltAccounts,
		ApplyToUniverse = applyToUniverse,
		ApplyDeviceBlock = applyDeviceBlock,
	})

	return if success then `Banned {#playerIds} players.` else `BanAsync failed: {errorMessage}`
end
