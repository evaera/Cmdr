return {
	Name = "goto-place",
	Description = "Teleport to a Roblox place.",
	Group = "DefaultAdmin",
	AutoExec = {
		'alias "follow-player|Join a player in another server." goto-place $1{players|Players|The players to teleport.} ${{get-player-place-instance $2{playerId|Target|The player you want to follow.}}}',
		'alias "rejoin|Rejoin this place. You might end up in a different server." goto-place $1{players|Players|The players to teleport.} ${get-player-place-instance ${me} PlaceId}',
	},
	Args = {
		{
			Type = "players",
			Name = "Players",
			Description = "The players to teleport.",
		},
		{
			Type = "positiveInteger",
			Name = "Place ID",
			Description = "The Place ID to teleport to.",
		},
		{
			Type = "string",
			Name = "JobId",
			Description = "The JobId to teleport to.",
			Optional = true,
		},
	},
}
