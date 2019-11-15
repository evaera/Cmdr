local Players = game:GetService("Players")

return {
	Name = "position";
	Aliases = {"pos"};
	Description = "Returns Vector3 position of you or other players. Empty string is the player has no character.";
	Group = "DefaultDebug";
	Args = {
		{
			Type = "player";
			Name = "Player";
			Description = "The player to report the position of. Omit for your own position.";
			Default = Players.LocalPlayer;
		}
	};

	ClientRun = function(_, player)
		local character = player.Character

		if not character or not character:FindFirstChild("HumanoidRootPart") then
			return ""
		end

		return tostring(character.HumanoidRootPart.Position):gsub("%s", "")
	end
}