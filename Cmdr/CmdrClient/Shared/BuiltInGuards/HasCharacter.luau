const function hasValidCharacter(player: Player): boolean
	const character = player.Character
	return character ~= nil and character:FindFirstChild("HumanoidRootPart")
end

return function(index: number?)
	return function(context: any): string?
		local target: Player | { Player } = context.Executor
		if index then
			const arg = context:GetArgument(index)
			target = if arg then arg:GetValue() else nil
		end

		const isSingle = typeof(target) == "Instance" and target:IsA("Player")
		const isList = typeof(target) == "table" and typeof(target[1]) == "Instance" and target[1]:IsA("Player")

		if not (isSingle or isList) then
			return nil
		end

		const players: { Player } = if isSingle then { target :: Player } else target :: { Player }

		for _, player in ipairs(players) do
			if hasValidCharacter(player) then
				continue
			end

			if isSingle then
				return if index then "Target player has no character." else "You don't have a character."
			end

			return if #players == 1
				then "Target player has no character."
				else "One or more target players don't have a character."
		end

		return nil
	end
end
