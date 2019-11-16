return {
	Name = "replace";
	Aliases = {};
	Description = "Replaces text A with text B";
	Group = "DefaultUtil";
	Args = {
		{
			Type = "string";
			Name = "Haystack";
			Description = "The source string upon which to perform replacement."
		},
		{
			Type = "string";
			Name = "Needle";
			Description = "The string pattern search for."
		},
		{
			Type = "string";
			Name = "Replacement";
			Description = "The string to replace matches (%1 to insert matches)."
		},
	};

	ClientRun = function(_, haystack, needle, replacement)
		return haystack:gsub(needle, replacement)
	end
}