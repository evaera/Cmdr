const UNIT_SECONDS: { [string]: number } = {
	Years = 31556926,
	Months = 2629744,
	Weeks = 604800,
	Days = 86400,
	Hours = 3600,
	Minutes = 60,
	Seconds = 1,
}

const unitNames: { string } = {}
for unitName: string in pairs(UNIT_SECONDS) do
	unitNames[#unitNames + 1] = unitName
end

const function mapUnits(units: { string }, rawText: string, lastNumber: number?, startIndex: number?): { string }
	const start: number = startIndex or 1
	const results: { string } = {}

	for index: number, unit: string in ipairs(units) do
		results[index] = `{rawText}{if lastNumber == 1 then unit:sub(start, #unit - 1) else unit:sub(start)}`
	end

	return results
end

return function(registry: any)
	const unitFinder = registry.Cmdr.Util.MakeFuzzyFinder(unitNames)
	const function stringToSecondDuration(text: string): (number?, number?, boolean?)
		if text == nil or text == "" then
			return nil
		end

		const number = tonumber(text)
		if number == 0 then
			return 0, 0, true
		end

		const numberOnly = text:gsub("-?%d+%a+", "")
		const missingUnit = numberOnly:match("-?%d+")

		if missingUnit then
			return nil, tonumber(missingUnit), true
		end

		local seconds: number = 0
		local lastNumber: number?

		for component: string in text:gmatch("-?%d+%a+") do
			const rawNumber, rawUnit = component:match("(-?%d+)(%a+)")
			if rawNumber == nil or rawUnit == nil then
				continue
			end

			lastNumber = tonumber(rawNumber)

			const matches: { string } = unitFinder(rawUnit, false, true)

			if #matches == 0 then
				return nil, lastNumber
			end

			const unit: number = if rawUnit:lower() == "m" then 60 else UNIT_SECONDS[matches[1]]
			seconds += unit * (lastNumber :: number)
		end

		if seconds == 0 then
			return nil
		end

		return seconds, lastNumber
	end

	const durationType = {
		Transform = function(text: string): (string, number?, number?, boolean?)
			return text, stringToSecondDuration(text)
		end,

		Validate = function(_, duration: number?): (boolean, string?)
			return duration ~= nil, "Invalid duration format. Example: 1d6h, 30m, 10s."
		end,

		Autocomplete = function(rawText: string, duration: number?, lastNumber: number?, missingUnit: boolean?): { string }
			local results: { string } = {}
			if missingUnit then
				const units: { string } = unitFinder("", false, true)
				results = mapUnits(units, rawText, lastNumber)
			elseif duration ~= nil then
				const endingUnit = rawText:match("^.*-?%d+(%a+)%s?$")
				const matches: { string } = unitFinder(endingUnit, false, true)

				results = mapUnits(matches, rawText, lastNumber, #endingUnit + 1)
				table.sort(results)
			end

			return results
		end,

		Parse = function(_, duration: number): number
			return duration
		end,
	}

	registry:RegisterType("duration", durationType)
	registry:RegisterType("durations", registry.Cmdr.Util.MakeListableType(durationType))
end
