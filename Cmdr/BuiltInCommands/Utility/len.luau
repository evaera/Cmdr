return {
	Name = "len",
	Aliases = {},
	Description = "Returns the length of a comma-separated list",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "string",
			Name = "CSV",
			Description = "The comma-separated list",
		},
	},

	ClientRun = function(_, list)
		return #(list:split(","))
	end,
}
