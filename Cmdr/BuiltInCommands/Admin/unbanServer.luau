const Players = game:GetService("Players")

return function(_, playerIds: { number }, applyToUniverse: boolean): string
	const success, errorMessage = pcall(Players.UnbanAsync, Players, {
		UserIds = playerIds,
		ApplyToUniverse = applyToUniverse,
	})

	return if success then `Unbanned {#playerIds} players.` else `UnbanAsync failed: {errorMessage}`
end
