local Players = game:GetService("Players")

return function (_, players)
	Players:UnbanAsync({
		UserIds = players,
		ApplyToUniverse = true,
	})

	return ("Unbanned %d players."):format(#players)
end
