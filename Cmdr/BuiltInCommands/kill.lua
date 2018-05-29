return {
	name = "kill";
	aliases = {"slay"};
	description = "Kills a player or set of players.";
	args = {
		{
			type = "players";
			name = "victims";
			description = "The players to kill.";
		},
	};
}