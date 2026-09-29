const SEAT_TIMEOUT = 1

const function teleportCharacter(humanoid: Humanoid, character: Model, cFrame: CFrame): boolean
	if humanoid.Sit then
		const wasSeated = humanoid.SeatPart ~= nil
		humanoid.Sit = false

		if wasSeated then
			const deadline = os.clock() + SEAT_TIMEOUT
			while humanoid.SeatPart and os.clock() < deadline do
				task.wait()
			end
		end
	end

	if not character:IsDescendantOf(workspace) then
		return false
	end

	character:PivotTo(cFrame)
	return true
end

return function(_, fromPlayers: { Player }, destination: Player | Vector3): string
	const cFrame = if typeof(destination) == "Instance"
		then (destination.Character :: Model):GetPivot()
		else CFrame.new(destination)

	local pending = 0
	local teleported = 0

	for _, player: Player in ipairs(fromPlayers) do
		const character = player.Character
		const humanoid = character and character:FindFirstChildWhichIsA("Humanoid") :: Humanoid?
		if not humanoid then
			continue
		end

		pending += 1

		task.spawn(function()
			const ok, success = pcall(teleportCharacter, humanoid, character, cFrame)

			if ok and success then
				teleported += 1
			end

			pending -= 1
		end)
	end

	while pending > 0 do
		task.wait()
	end

	if teleported == #fromPlayers then
		return `Teleported {teleported} players.`
	end

	return `Teleported {teleported} of {#fromPlayers} players.`
end
