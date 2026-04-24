return {
	Name = "unban";
	Description = "Unbans a player or set of players.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "playerIds";
			Name = "players";
			Description = "The players to unban.";
		},
	};
}
