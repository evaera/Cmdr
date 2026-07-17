local Players = game:GetService("Players")

return function(_, playerIds, applyToUniverse)
	if #playerIds > 50 then
		return "Too many players specified. UnbanAsync limits batches to a maximum of 50 players."
	end

	local success, errorMessage = pcall(Players.UnbanAsync, Players, {
		UserIds = playerIds,
		ApplyToUniverse = applyToUniverse,
	})

	return if success then `Unbanned {#playerIds} players.` else `UnbanAsync failed: {errorMessage}`
end
