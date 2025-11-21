local Chat = game:GetService("Chat")
local unfiltered_reason
return function(context, players, reason)
	unfiltered_reason = nil reason = if reason then unfiltered_reason = Chat:FilterStringForBroadcastAsync(context.Executor, reason) else `Kicked by {context.Executor.Name}.` if string.find(reason, "#") and not string.find(unfiltered_reason, "#") then reason = `Kicked by {context.Executor.Name}.` end for _, player in pairs(players) do player:Kick(reason) end return (`Kicked %d players, for {reason}`):format(#players)
end
