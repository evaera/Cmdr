local Players = game:GetService("Players")

return {
	Name = "clear",
	Aliases = {},
	Description = "Clear all lines above the entry line of the Cmdr window.",
	Group = "DefaultUtil",
	Args = {},
	Run = function()
		local player = Players.LocalPlayer
		local gui = player:WaitForChild("PlayerGui"):WaitForChild("Cmdr")
		local frame = gui:WaitForChild("Frame")

		if gui and frame then
			local shrinkHeight = 0
			for _, child in pairs(frame:GetChildren()) do
				if child.Name == "Line" and child:IsA("TextLabel") then
					shrinkHeight = shrinkHeight + child.Size.Y.Offset
					child:Destroy()
				end
			end
			frame.Size = frame.Size - UDim2.new(0, 0, 0, -shrinkHeight)
		end
		return ""
	end
}
