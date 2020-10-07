local HttpService = game:GetService("HttpService")

return {
	Name = "json_array_decode";
	Aliases = {};
	Description = "Decodes a JSON Array into a comma-separated list";
	Group = "DefaultUtil";
	Args = {
		{
			Type = "string";
			Name = "JSON";
			Description = "The JSON array."
		},
	};

	Run = function(_, text)
		local value = HttpService:JSONDecode(text)

		if type(value) ~= "table" then
			value = { value }
		end

		return table.concat(value, ",")
	end
}