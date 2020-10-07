local HttpService = game:GetService("HttpService")

return {
	Name = "json_array_encode";
	Aliases = {};
	Description = "Encodes a comma-separated list into a JSON array";
	Group = "DefaultUtil";
	Args = {
		{
			Type = "string";
			Name = "CSV";
			Description = "The comma-separated list"
		},
	};

	Run = function(_, text)
		return HttpService:JSONEncode(text:split(","))
	end
}