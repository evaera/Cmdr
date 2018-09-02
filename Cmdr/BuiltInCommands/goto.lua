return {
	Name = "goto";
	Aliases = {"travel"};
	Description = "Teleports you to another place in this game.";
	Args = {
		{
			Type = "place";
			Name = "Destination";
			Description = "The place to travel to.";
		},
		{
			Type = "players";
			Name = "Players to teleport";
			Optional = true;
			Description = "The players to teleport to the place."
		}
	};
}