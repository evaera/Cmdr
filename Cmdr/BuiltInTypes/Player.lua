local Util = require(script.Parent.Parent.Shared.Util)
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

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
	transform = function (text, executor)
		local shorthand = CheckShorthands(text, executor, ShorthandSingle)
		if shorthand then
			return shorthand, text
		end

		local findPlayer = Util.MakeFuzzyFinder(Players:GetPlayers())

		return findPlayer(text), text
	end;

	validate = function (players)
		return #players > 0, "No player with that name could be found."
	end;

	autocomplete = function (players, rawText)
		return Util.GetInstanceNames(players), rawText:sub(1, 1) == "%" and 2 or 1
	end;

	parse = function (players)
		return players[1]
	end;
}

local playersType = {
	transform = function (text, executor)
		local shorthand = CheckShorthands(text, executor, ShorthandSingle, ShorthandMultiple)

		if shorthand then
			return shorthand, text
		end

		if text:sub(1, 1) == "%" then
			local findTeam = Util.MakeFuzzyFinder(Teams:GetTeams())
			local team = findTeam(text:sub(2), true)
			local teams = findTeam(text:sub(2))

			if team then
				return team:GetPlayers(), text, teams
			end

			return {}, text
		else
			local findPlayers = Util.MakeFuzzyFinder(Players:GetPlayers())

			return findPlayers(text), text
		end
	end;

	validate = function (players)
		return #players > 0, "No players were found matching that query."
	end;

	autocomplete = function (players, rawText, teams)
		return Util.GetInstanceNames(teams or players), rawText:sub(1, 1) == "%" and 2 or 1
	end;

	parse = function (players)
		return players
	end;
}

return function (cmdr)
	cmdr:RegisterType("player", playerType)
	cmdr:RegisterType("players", playersType)
end