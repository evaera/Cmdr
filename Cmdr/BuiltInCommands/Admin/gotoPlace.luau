return {
	Name = "goto-place",
	Aliases = {},
	Description = "Teleport to a Roblox place",
	Group = "DefaultAdmin",
	AutoExec = {
		'alias "follow-player|Join a player in another server" goto-place $1{players|Players} ${{get-player-place-instance $2{playerId|Target}}}',
		'alias "rejoin|Rejoin this place. You might end up in a different server." goto-place $1{players|Players} ${get-player-place-instance ${me} PlaceId}',
	},
	Args = {
		{
			Type = "players",
			Name = "Players",
			Description = "The players you want to teleport",
		},
		{
			Type = "positiveInteger",
			Name = "Place ID",
			Description = "The Place ID you want to teleport to",
		},
		{
			Type = "string",
			Name = "JobId",
			Description = "The specific JobId you want to teleport to",
			Optional = true,
		},
	},
}
