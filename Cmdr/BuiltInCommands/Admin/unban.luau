return {
	Name = "unban",
	Description = "Unbans a player or set of players.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "playerIds",
			Name = "Players",
			Description = "The players to unban (max 50)",
		},
		{
			Type = "boolean",
			Name = "Apply to Universe",
			Description = "Remove the ban across all places in this experience",
			Default = true,
		},
	},
}
