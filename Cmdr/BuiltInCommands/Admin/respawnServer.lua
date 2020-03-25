-- A fully extensible and type-safe admin-commands console
-- @documentation https://github.com/evaera/Cmdr/blob/master/README.md
-- @source https://github.com/evaera/Cmdr
-- @rostrap Cmdr
-- @author evaera

return function(_, players)
	for _, player in pairs(players) do
		if player.Character then
			player:LoadCharacter()
		end
	end
end
