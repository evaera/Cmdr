local Util = require(script.Parent.Parent.Shared.Util)

local unitTable = {
    Year = 31556926,
    Month = 2629744,
    Week = 604800,
    Day = 86400,
    Hour = 3600,
    Minute = 60,
    Second = 1
}

local searchKeyTable = {}
for key, _ in pairs(unitTable) do
    table.insert(searchKeyTable, key)
end
local unitFinder = Util.MakeFuzzyFinder(searchKeyTable)

local function stringToSecondDuration(stringDuration)
    -- The duration cannot be null or an empty string.
    if stringDuration == nil or stringDuration == "" then
        return nil, stringDuration
    end
    -- The duration must end with a unit,
    -- if it doesn't then return true as the third value to indicate the need to offer autocomplete for units.
    if stringDuration:find("^.*%d+$") then
        return nil, stringDuration, true
    end
    local secondValue = -1
    for rawComponent in stringDuration:gmatch("%d+%a+") do
        local rawNum, rawUnit = rawComponent:match("(%d+)(%a+)")
        local unitNames = unitFinder(rawUnit)
        -- There were no matching units, it's invalid.
        if #unitNames == 0 then
            return nil, stringDuration
        -- There were multiple matching units, which can only happen with Minutes/Months, so we default to Minutes.
        elseif #unitNames > 1 then
            unitNames[1] = "Minute"
        end
        secondValue = secondValue + unitTable[unitNames[1]] * tonumber(rawNum)
    end
    -- No durations were actually provided, so return nil.
    if secondValue == -1 then
        -- Add 1 to escape the effect of having -1 as the original value.
        return nil
    else
        return secondValue + 1, stringDuration
    end
end

local durationType = {
    Transform = function(text)
        return stringToSecondDuration(text)
    end;

    Validate = function(_, _, isUnitMissingOrMatchedUnits)
        -- If the units are accurate, or the units are completely missing,
        -- or there is exactly one matching unit then the duration is valid.
        return isUnitMissingOrMatchedUnits == nil or isUnitMissingOrMatchedUnits == true or
            (type(isUnitMissingOrMatchedUnits) == "table" and #isUnitMissingOrMatchedUnits == 1)
    end;

    Autocomplete = function(duration, rawText, isUnitMissingOrMatchedUnits)
        local returnTable = {}
        if isUnitMissingOrMatchedUnits then
            local unitsTable = isUnitMissingOrMatchedUnits == true and unitFinder("") or isUnitMissingOrMatchedUnits
            if isUnitMissingOrMatchedUnits == true then
                -- Concat the entire unit name to existing text.
                for i, unit in pairs(unitsTable) do
                    returnTable[i] = rawText .. unit
                end
            else
                -- Concat the rest of the unit based on what already exists of the unit name.
                local existingUnitLength = rawText:match("^.*(%a+)$"):len()
                for i, unit in pairs(unitsTable) do
                    returnTable[i] = rawText .. unit:sub(existingUnitLength + 1)
                end
            end
        elseif duration ~= nil then
            local endingUnit = rawText:match("^.*%d+(%a+)$")
            -- Assume there is a singular match at this point
            local fuzzyUnits = unitFinder(endingUnit)
            -- List all possible fuzzy matches. This is for the Minutes/Months ambiguity case.
            for i, unit in pairs(fuzzyUnits) do
                returnTable[i] = rawText .. unit:sub(#endingUnit + 1)
            end
            -- Sort alphabetically in the Minutes/Months case, so Minutes are displayed on top.
            table.sort(returnTable)
        end
        return returnTable
    end;

    Parse = function(duration)
        return duration
    end;
}

return function(registry)
    registry:RegisterType("duration", durationType)
    registry:RegisterType("durations", Util.MakeListableType(durationType))
end
