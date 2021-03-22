local Util = require(script.Parent.Parent.Shared.Util)

local unitTable = {
    Years = 31556926,
    Months = 2629744,
    Weeks = 604800,
    Days = 86400,
    Hours = 3600,
    Minutes = 60,
    Seconds = 1
}

local searchKeyTable = {}
for key, _ in pairs(unitTable) do
    table.insert(searchKeyTable, key)
end
local unitFinder = Util.MakeFuzzyFinder(searchKeyTable)

local function stringToSecondDuration(stringDuration)
    -- The duration cannot be null or an empty string.
    if stringDuration == nil or stringDuration == "" then
        return nil
    end
    -- Allow 0 by itself (without a unit) to indicate 0 seconds
    local durationNum = tonumber(stringDuration)
    if durationNum and durationNum == 0 then
        return 0, 0, true
    end
    -- The duration must end with a unit,
    -- if it doesn't then return true as the fourth value to indicate the need to offer autocomplete for units.
    local endOnlyString = stringDuration:gsub("-?%d+%a+", "")
    local endNumber = endOnlyString:match("-?%d+")
    if endNumber then
        return nil, tonumber(endNumber), true
    end
    local seconds = nil
    local rawNum, rawUnit
    for rawComponent in stringDuration:gmatch("-?%d+%a+") do
        rawNum, rawUnit = rawComponent:match("(-?%d+)(%a+)")
        local unitNames = unitFinder(rawUnit)
        -- There were no matching units, it's invalid. Return the parsed number to be used for autocomplete
        if #unitNames == 0 then
            return nil, tonumber(rawNum)
        end
        if seconds == nil then seconds = 0 end
        -- While it was already defaulting to use minutes when using just "m", this does it without worrying
        -- about any consistency between list ordering.
        seconds = seconds + (rawUnit:lower() == "m" and 60 or unitTable[unitNames[1]]) * tonumber(rawNum)
    end
    -- If no durations were provided, return nil.
    if seconds == nil then
        return nil
    else
        return seconds, tonumber(rawNum)
    end
end

local function mapUnits(units, rawText, lastNumber, subStart)
    subStart = subStart or 1
    local returnTable = {}
    for i, unit in pairs(units) do
        if lastNumber == 1 then
            returnTable[i] = rawText .. unit:sub(subStart, #unit - 1)
        else
            returnTable[i] = rawText .. unit:sub(subStart)
        end
    end
    return returnTable
end

local durationType = {
    Transform = function(text)
        return text, stringToSecondDuration(text)
    end;

    Validate = function(_, duration)
        return duration ~= nil
    end;

    Autocomplete = function(rawText, duration, lastNumber, isUnitMissing, matchedUnits)
        local returnTable = {}
        if isUnitMissing or matchedUnits then
            local unitsTable = isUnitMissing == true and unitFinder("") or matchedUnits
            if isUnitMissing == true then
                -- Concat the entire unit name to existing text.
                returnTable = mapUnits(unitsTable, rawText, lastNumber)
            else
                -- Concat the rest of the unit based on what already exists of the unit name.
                local existingUnitLength = rawText:match("^.*(%a+)$"):len()
                returnTable = mapUnits(unitsTable, rawText, existingUnitLength + 1)
            end
        elseif duration ~= nil then
            local endingUnit = rawText:match("^.*-?%d+(%a+)%s?$")
            -- Assume there is a singular match at this point
            local fuzzyUnits = unitFinder(endingUnit)
            -- List all possible fuzzy matches. This is for the Minutes/Months ambiguity case.
            returnTable = mapUnits(fuzzyUnits, rawText, lastNumber, #endingUnit + 1)
            -- Sort alphabetically in the Minutes/Months case, so Minutes are displayed on top.
            table.sort(returnTable)
        end
        return returnTable
    end;

    Parse = function(_, duration)
        return duration
    end;
}

return function(registry)
    registry:RegisterType("duration", durationType)
    registry:RegisterType("durations", Util.MakeListableType(durationType))
end
