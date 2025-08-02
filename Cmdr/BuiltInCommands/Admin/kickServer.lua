return function(_, players, reason)
	reason = if reason then reason else `Kicked by {_.Executor.Name}.`
	for _, player in pairs(players) do
		player:Kick(reason)
	end

	return ("Kicked %d players."):format(#players)
end
