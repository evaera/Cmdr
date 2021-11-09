local AssetService = game:GetService("AssetService")
local TeleportService = game:GetService("TeleportService")

local pages = AssetService:GetGamePlacesAsync()
local places = {}

while true do
	for _, place in ipairs(pages:GetCurrentPage()) do
		table.insert(places, place.PlaceId)
	end

	if pages.isFinished then
		break
	end
	pages:AdvanceToNextpageAsync()
end

return function(context, players, placeId, jobId)
	players = players or { context.Executor }

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
		if table.find(places, placeId) then
			TeleportService:TeleportPartyAsync(placeId, players)
		else
			TeleportService:TeleportAsync(placeId, players)
		end
	end

	return "Teleported."
end
