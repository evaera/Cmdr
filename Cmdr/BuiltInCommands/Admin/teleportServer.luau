return function(_, fromPlayers, destination)
	local cframe

	if typeof(destination) == "Instance" then
		if destination.Character and destination.Character:FindFirstChild("HumanoidRootPart") then
			cframe = destination.Character.HumanoidRootPart.CFrame
		else
			return "Target player has no character."
		end
	elseif typeof(destination) == "Vector3" then
		cframe = CFrame.new(destination)
	end

	for _, player in ipairs(fromPlayers) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if player.Character.Humanoid.Sit then
				player.Character.Humanoid.Jump = true
			end
			player.Character.HumanoidRootPart.CFrame = cframe
		end
	end

	return ("Teleported %d players."):format(#fromPlayers)
end
