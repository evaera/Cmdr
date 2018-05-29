return {
	name = "kick";
	aliases = {"boot"};
	description = "Kicks a player or set of players.";
	args = {
		{
			type = "players";
			name = "players";
			description = "The players to kick.";
		},
	};
}