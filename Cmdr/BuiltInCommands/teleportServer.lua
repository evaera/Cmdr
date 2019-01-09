return function (_, fromPlayers, toPlayer)
	if toPlayer.Character and toPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local position = toPlayer.Character.HumanoidRootPart.CFrame

		for _, player in ipairs(fromPlayers) do
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				player.Character.HumanoidRootPart.CFrame = position
			end
		end

		return ("Teleported %d players."):format(#fromPlayers)
	end

	return "Target player has no character."
end
