const TeleportService = game:GetService("TeleportService")

return function(context: any, players: { Player }, placeId: number, jobId: string?): string
	if placeId <= 0 then
		return "Invalid place ID"
	elseif jobId == "-" then
		return "Invalid job ID"
	end

	context:Reply("Commencing teleport...")

	const success, errorMessage = pcall(function()
		if jobId then
			const options = Instance.new("TeleportOptions")
			options.ServerInstanceId = jobId
			TeleportService:TeleportAsync(placeId, players, options)
		else
			TeleportService:TeleportAsync(placeId, players)
		end
	end)

	return if success then "Teleported." else `Teleport failed: {errorMessage}`
end
