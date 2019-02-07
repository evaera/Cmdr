local players = game:GetService("Players")
local textService = game:GetService("TextService")

local dataStoreService = game:GetService("DataStoreService")
local banService = dataStoreService:GetDataStore("BanService")

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
	local sec = date.sec < 10 and "0" .. date.sec or date.sec
	
	local dateFormat = month .. " " .. day .. ", " .. year
	local timeFormat = hour .. ":" .. min .. ":" .. sec .. " " .. (isPM and "PM" or "AM")
	
	return dateFormat .. " at " .. timeFormat
end

players.PlayerAdded:Connect(function(player)
	local banData
	
	pcall(function()
		banData = banService:GetAsync(player.UserId)
	end)
	
	if banData then
		local reason = banData.Reason
		local duration = banData.Duration
		
		local filteredReason = ""
		
		pcall(function()
			filteredReason = textService:FilterStringAsync(reason, player.UserId, Enum.TextFilterContext.PublicChat)
		end)
		
		if duration ~= "permanent" then
			if duration - os.time() >= 0 then
				player:Kick("You have been banned from this game for " .. string.lower(filteredReason) .. ". This ban will be lifted on " .. getDateFromTime(duration) .. " UTC.")
			else
				local success, err = pcall(function()
					banService:RemoveAsync(player.UserId)
				end)
			end
		else
			player:Kick("You have been banned from this game for " .. string.lower(filteredReason) .. ". This ban will be lifted on December 31, 9999 at 11:59:59 PM UTC.")
		end
	end
end)

return function(context, fromPlayers, reason, duration)
	for _, player in ipairs(fromPlayers) do
		if reason then
			
			local banData
			
			local success, err = pcall(function()
				banData = banService:GetAsync(player.UserId)
			end)
			
			if not banData and success then			
				local timeAmount = duration and math.clamp(os.time() + duration, 0, 2147483647) or "permanent"
				
				local data = {
					Reason = reason,
					Duration = timeAmount
				}
				
				local success, err = pcall(function()
					banService:SetAsync(player.UserId, data)
				end)
				
				if success then
					player:Kick("You have been banned from this game for " .. string.lower(reason) .. ". This ban will be lifted on " .. getDateFromTime(timeAmount) .. " UTC.")
				end
			end
		end
	end
end
