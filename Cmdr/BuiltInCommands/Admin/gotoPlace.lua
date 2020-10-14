return {
	Name = "goto-place";
	Aliases = {};
	Description = "Teleport to a Roblox place";
	Group = "DefaultAdmin";
	AutoExec = {
		"alias follow-player goto-place $1{players|Players} ${{get-player-place-instance $2{playerId|Target}}}",
		"alias rejoin goto-place $1{players|Players} ${get-player-place-instance ${me} PlaceId}"
	};
	Args = {
		{
			Type = "players";
			Name = "Players";
			Description = "The players you want to teleport";
		},
		{
			Type = "integer";
			Name = "Place ID";
			Description = "The Place ID you want to teleport to";
		},
		{
			Type = "string";
			Name = "JobId";
			Description = "The specific JobId you want to teleport to";
			Optional = true;
		}
	};
}