return {
	Name = "kick",
	Aliases = { "boot" },
	Description = "Kicks a player or set of players.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "players",
			Name = "Players",
			Description = "The players to kick.",
		},
		{
			Type = "string",
			Name = "Reason",
			Description = "Kick message shown to the players.",
			Default = "No reason provided",
		},
	},
}
