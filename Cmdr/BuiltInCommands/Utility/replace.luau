return {
	Name = "replace",
	Aliases = { "gsub", "//" },
	Description = "Replaces text A with text B",
	Group = "DefaultUtil",
	AutoExec = {
		'alias "map|Maps a CSV into another CSV" replace $1{string|CSV} ([^,]+) "$2{string|mapped value|Use %1 to insert the element}"',
		'alias "join|Joins a CSV with a specified delimiter" replace $1{string|CSV} , $2{string|Delimiter}',
	},
	Args = {
		{
			Type = "string",
			Name = "Haystack",
			Description = "The source string upon which to perform replacement.",
		},
		{
			Type = "string",
			Name = "Needle",
			Description = "The string pattern search for.",
		},
		{
			Type = "string",
			Name = "Replacement",
			Description = "The string to replace matches (%1 to insert matches).",
			Default = "",
		},
	},

	ClientRun = function(_, haystack, needle, replacement)
		return haystack:gsub(needle, replacement)
	end,
}
