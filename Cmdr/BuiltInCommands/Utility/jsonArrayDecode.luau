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
		for i, item in value do
			stringValues[i] = tostring(item)
		end

		return table.concat(stringValues, ",")
	end,
}
