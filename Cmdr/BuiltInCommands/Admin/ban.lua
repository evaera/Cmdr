return {
	Name = "ban",
	Description = "Bans a player or set of players.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "playerIds",
			Name = "Players",
			Description = "The players to ban (max 50)",
		},
		{
			Type = "duration",
			Name = "Duration",
			Description = "How long the ban lasts (negative values indicate a permanent ban)",
		},
		{
			Type = "string",
			Name = "Display Reason",
			Description = "Ban message shown to the player",
		},
		{
			Type = "string",
			Name = "Private Reason",
			Description = "Internal staff notes for ban history",
			Optional = true,
		},
		{
			Type = "boolean",
			Name = "Exclude Alt Accounts",
			Description = "Skip banning their alternate accounts",
			Default = false,
		},
		{
			Type = "boolean",
			Name = "Apply to Universe",
			Description = "Ban from all places in this experience",
			Default = true,
		},
		{
			Type = "boolean",
			Name = "Apply Device Block",
			Description = "Block their device from rejoining for 24 hours",
			Default = false,
		},
	},
}
