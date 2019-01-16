return {
	Name = "teleport";
	Aliases = {"tp"};
	Description = "Teleports a player or set of players to one target.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "players";
			Name = "From";
			Description = "The players to teleport";
		},
		{
			Type = "player @ vector3";
			Name = "Destination";
			Description = "The player to teleport to"
		}
	};
}