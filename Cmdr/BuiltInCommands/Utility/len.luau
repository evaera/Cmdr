return {
	Name = "len",
	Description = "Returns the length of a comma-separated list",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "string",
			Name = "CSV",
			Description = "The comma-separated list",
		},
	},

	ClientRun = function(_, list: string): number
		return #(list:split(","))
	end,
}
