local Chat = game:GetService("Chat")
return function(_, players, reason)
	reason = if reason then Chat:FilterStringForBroadcastAsync(_.Executor, reason) else `Kicked by {_.Executor.Name}.`
	for _, player in pairs(players) do
		player:Kick(reason)
	end

	return (`Kicked %d players for {reason}`):format(#players)
end
