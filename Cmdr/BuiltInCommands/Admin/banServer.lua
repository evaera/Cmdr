local Players = game:GetService("Players")

return function (_, players, duration, reason)
	if duration <= 0 then
		duration = -1
	end

	Players:BanAsync({
		UserIds = players,
		Duration = duration,
		DisplayReason = reason,
		PrivateReason = reason,
		ExcludeAltAccounts = false,
		ApplyToUniverse = true,
	})

	return ("Banned %d players."):format(#players)
end
