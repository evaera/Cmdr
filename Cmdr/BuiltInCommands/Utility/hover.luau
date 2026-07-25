const Players = game:GetService("Players")

const Player = Players.LocalPlayer

return {
	Name = "hover",
	Description = "Returns the name of the player you are hovering over.",
	Group = "DefaultUtil",
	Args = {},

	ClientRun = function(): string
		const mouse = Player:GetMouse()
		const target = mouse.Target
		if not target then
			return ""
		end

		local targetPlayer = Players:GetPlayerFromCharacter(target:FindFirstAncestorOfClass("Model"))
		return targetPlayer and `{targetPlayer.DisplayName} @({targetPlayer.Name})` or ""
	end,
}
