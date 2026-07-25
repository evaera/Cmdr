const TeleportService = game:GetService("TeleportService")

return function(_, playerId: number, format: string): string
	format = format or "PlaceIdJobId"

	const success, _, errorText, placeId, jobId = pcall(TeleportService.GetPlayerPlaceInstanceAsync, TeleportService, playerId)
	if not success or (errorText and #errorText > 0) then
		if format == "PlaceIdJobId" then
			return "0" .. " -"
		elseif format == "PlaceId" then
			return "0"
		elseif format == "JobId" then
			return "-"
		end
	end

	if format == "PlaceIdJobId" then
		return placeId .. " " .. jobId
	elseif format == "PlaceId" then
		return tostring(placeId)
	elseif format == "JobId" then
		return tostring(jobId)
	end

	return "Something went very wrong!"
end
