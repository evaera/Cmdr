return {
	name = "teleport";
	aliases = {"tp"};
	description = "Teleports a player or set of players to one target.";
	args = {
		{
			type = "players";
			name = "from";
			description = "The players to teleport";
		},
		{
			type = "player";
			name = "to";
			description = "The player to teleport to"
		}
	};
}