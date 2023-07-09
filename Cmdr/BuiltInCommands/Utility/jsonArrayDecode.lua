return {
	Name = "json-array-decode";
	Aliases = {};
	Description = "Decodes a JSON Array into a comma-separated list";
	Group = "DefaultUtil";
	Args = {
		{
			Type = "json";
			Name = "JSON";
			Description = "The JSON array."
		},
	};

	ClientRun = function(_, value)
		if type(value) ~= "table" then
			value = { value }
		end

		return table.concat(value, ",")
	end
}
