return {
	Name = "ban";
	Description = "Bans a player or set of players.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "playerIds";
			Name = "players";
			Description = "The players to ban.";
		},
		{
			Type = "duration";
			Name = "duration";
			Description = "How long the ban should last. A negative value means a permanent ban.";
		},
		{
			Type = "string";
			Name = "reason";
			Description = "The reason for the ban. This is shown to the player(s) and saved in history.";
		},
	};
}
