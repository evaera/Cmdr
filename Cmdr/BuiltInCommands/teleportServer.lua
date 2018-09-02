return function (context, fromPlayers, toPlayer)
  if toPlayer.Character and toPlayer:FindFirstChild("HumanoidRootPart") then
    local position = toPlayer.Character.HumanoidRootPart.CFrame

    for _, player in ipairs(fromPlayers) do
      if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = position
      end
    end

    return "Teleported players."
  end

  return "Target player has no character."
end