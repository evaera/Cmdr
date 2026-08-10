return function(index: number?)
	return function(context: any): string?
		local player = context.Executor
		if index then
			const arg = context:GetArgument(index)
			player = if arg then arg:GetValue() else nil
		end

		if typeof(player) ~= "Instance" or not player:IsA("Player") then
			return nil
		end

		const character = player.Character
		if not character or not character:FindFirstChild("HumanoidRootPart") then
			return if index then "Target player has no character." else "You don't have a character."
		end

		return nil
	end
end
