return function(_, players: { Player }): string
	for _, player in ipairs(players) do
		const character = player.Character
		const humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
		if not humanoid then
			continue
		end

		humanoid.Health = 0
	end

	return `Killed {#players} players.`
end
