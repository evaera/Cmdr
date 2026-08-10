const TeleportService = game:GetService("TeleportService")

return function(context: any, players: { Player }, placeId: number, jobId: string?): string
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
