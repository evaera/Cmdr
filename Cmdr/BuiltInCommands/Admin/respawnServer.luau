return function(_, players: { Player }): string
	for _, player in ipairs(players) do
		task.spawn(pcall, player.LoadCharacterAsync, player)
	end

	return `Respawned {#players} players.`
end
