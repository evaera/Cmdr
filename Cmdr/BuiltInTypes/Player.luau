const Players = game:GetService("Players")

return function(registry: any)
	const playerType = {
		Transform = function(text: string): { Player }
			const findPlayer = registry.Cmdr.Util.MakeFuzzyFinder(Players:GetPlayers())
			return findPlayer(text)
		end,

		Validate = function(players: { Player }): (boolean, string?)
			return #players > 0, "No player with that name could be found."
		end,

		Autocomplete = function(players: { Player }): { string }
			return registry.Cmdr.Util.GetNames(players)
		end,

		Parse = function(players: { Player }): Player?
			return players[1]
		end,

		Default = function(player: Player): string
			return player.Name
		end,

		ArgumentOperatorAliases = {
			me = ".",
			all = "*",
			others = "**",
			random = "?",
		},
	}

	registry:RegisterType("player", playerType)
	registry:RegisterType("players", registry.Cmdr.Util.MakeListableType(playerType, { Prefixes = "% teamPlayers" }))
end
