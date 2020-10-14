local TeleportService = game:GetService("TeleportService")

return function(context, players, placeId, jobId)
	players = players or { context.Executor}

	if placeId <= 0 then
		return "Invalid place ID"
	elseif jobId == "-" then
		return "Invalid job ID"
	end

	context:Reply("Commencing teleport...")

	if jobId then
		for _, player in ipairs(players) do
			TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
		end
	else
		TeleportService:TeleportPartyAsync(placeId, players)
	end

	return "Teleported."
end