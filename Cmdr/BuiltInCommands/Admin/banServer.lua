local players = game:GetService("Players")
local textService = game:GetService("TextService")

local dataStoreService = game:GetService("DataStoreService")
local banService = dataStoreService:GetDataStore("BanService")

local kickMessage = "You have been banned from this game for %s. This ban will be lifted on %s."

local months = {
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
}

local function getDateFromTime(timeAmount)
	if timeAmount == "permanent" then
		return "December 31, 9999 at 11:59 PM UTC"
	end
	local date = os.date("!*t", timeAmount)
	local month = months[date.month]
	local day = date.day
	local year = date.year
	local hour = date.hour
	local isPM = false
	if hour > 12 then
		hour = hour - 12
		isPM = true
	end
	if hour < 10 then
		hour = "0" .. hour
	end
	local min = date.min < 10 and "0" .. date.min or date.min
	local dateFormat = month .. " " .. day .. ", " .. year
	local timeFormat = hour .. ":" .. min .. " " .. (isPM and "PM" or "AM")
	return dateFormat .. " at " .. timeFormat .. " UTC."
end

local function returnFilteredReason(player, reason)
	local returnedReason = ""
	pcall(function()
		reason = textService:FilterStringAsync(reason, player.UserId, Enum.TextFilterContext.PublicChat)
	end)
	return string.lower(returnedReason)
end

players.PlayerAdded:Connect(function(player)
	local banData
	pcall(function()
		banData = banService:GetAsync(player.UserId)
	end)
	if banData then
		local reason = returnFilteredReason(player, banData.Reason)
		local duration = banData.Duration
		if duration ~= "permanent" and duration - os.time() > 0 then
			player:Kick(string.format(kickMessage, reason, getDateFromTime(duration)))
		else
			pcall(function()
				banService:RemoveAsync(player.UserId)
			end)
		end
	end
end)

return function(context, fromPlayers, reason, duration)
	for _, player in ipairs(fromPlayers) do
		if reason then
			local banData
			local dataRetrieval = pcall(function()
				banData = banService:GetAsync(player.UserId)
			end)
			if not banData and dataRetrieval then	
				local timeAmount = duration and math.min(os.time() + duration, 2147483647) or "permanent"
				local data = {
					Reason = reason,
					Duration = timeAmount
				}
				local setBan = pcall(function()
					banService:SetAsync(player.UserId, data)
				end)
				if setBan then
					local filteredReason = returnFilteredReason(player, banData.Reason)
					player:Kick(string.format(kickMessage, filteredReason, getDateFromTime(timeAmount)))
				end
			end
		end
	end
end
