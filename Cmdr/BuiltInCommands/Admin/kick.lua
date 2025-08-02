return {
	Name = "kick",
	Aliases = { "boot" },
	Description = "Kicks a player or set of players.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to kick.",
		},
		{
			Type = "string",
			Name = "reason",
			Description = "The reason for kicking the players."
		}
	},
}
