return {
	Name = "json-array-decode",
	Description = "Decodes a JSON Array into a comma-separated list.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "json",
			Name = "JSON",
			Description = "The JSON array.",
		},
	},

	ClientRun = function(_, value: any): string
		if type(value) ~= "table" then
			return tostring(value)
		end

		const stringValues = {}
		for index, item in ipairs(value) do
			stringValues[index] = tostring(item)
		end

		return table.concat(stringValues, ",")
	end,
}
