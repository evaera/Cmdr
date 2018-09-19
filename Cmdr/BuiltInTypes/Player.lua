local Util = require(script.Parent.Parent.Shared.Util)
local Players = game:GetService("Players")

function ShorthandSingle (text, executor)
	if text == "." or text == "me" then
		return {executor}
	end
end

function ShorthandMultiple (text)
	if text == "*" or text == "all" then
		return Players:GetPlayers()
	end
end

function CheckShorthands (text, executor, ...)
	for _, func in pairs({...}) do
		local values = func(text, executor)

		if values then return values end
	end
end

local playerType = {
	Transform = function (text, executor)
		local shorthand = CheckShorthands(text, executor, ShorthandSingle)
		if shorthand then
			return shorthand
		end

		local findPlayer = Util.MakeFuzzyFinder(Players:GetPlayers())

		return findPlayer(text), text
	end;

	Validate = function (players)
		return #players > 0, "No player with that name could be found."
	end;

	Autocomplete = function (players)
		return Util.GetInstanceNames(players)
	end;

	Parse = function (players)
		return players[1]
	end;
}

local playersType = {
	Listable = true;

	Transform = function (text, executor)
		local shorthand = CheckShorthands(text, executor, ShorthandSingle, ShorthandMultiple)

		if shorthand then
			return shorthand, true
		end

		local findPlayers = Util.MakeFuzzyFinder(Players:GetPlayers())

		return findPlayers(text)
	end;

	Validate = function (players)
		return #players > 0, "No players were found matching that query."
	end;

	Autocomplete = function (players)
		return Util.GetInstanceNames(players)
	end;

	Parse = function (players, returnAll)
		return returnAll and players or { players[1] }
	end;
}

return function (cmdr)
	cmdr:RegisterType("player", playerType)
	cmdr:RegisterType("players", playersType)
end