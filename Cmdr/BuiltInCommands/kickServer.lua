return function (_, players)
	for _, player in pairs(players) do
		player:Kick("Kicked by admin.")
	end

	return ("Kicked %d players."):format(#players)
end