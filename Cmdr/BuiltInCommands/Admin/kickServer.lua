local Chat = game:GetService("Chat")
return function(context, players, reason)
	reason = if reason then Chat:FilterStringForBroadcastAsync(context.Executor, reason) else `Kicked by {context.Executor.Name}.`
		if string.find(reason, "#") then
			reason = `Kicked by {context.Executor.Name}.`
		end
	for _, player in pairs(players) do
		player:Kick(reason)
	end

	return (`Kicked %d players, for {reason}`):format(#players)
end
