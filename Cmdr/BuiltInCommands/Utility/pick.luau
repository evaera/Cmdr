return {
	Name = "pick",
	Aliases = {},
	Description = "Picks a value out of a comma-separated list.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "positiveInteger",
			Name = "Index to pick",
			Description = "The index of the item you want to pick",
		},
		{
			Type = "string",
			Name = "CSV",
			Description = "The comma-separated list",
		},
	},

	ClientRun = function(_, index, list)
		return list:split(",")[index] or ""
	end,
}
