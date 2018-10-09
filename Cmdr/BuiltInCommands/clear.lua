local Players = game:GetService("Players")

return {
	Name = "clear";
	Aliases = {};
	Description = "Clear all lines above the entry line of the Cmdr window.";
	Group = "DefaultUtil";
	Args = {};

    Run = function()
        local Player = Players.LocalPlayer
        local Gui = Player:WaitForChild("PlayerGui"):WaitForChild("Cmdr")
        local Frame = Gui:WaitForChild("Frame")

        if Gui and Frame then
            local shrinkHeight = 0
            for _, child in pairs(Frame:GetChildren()) do
                if (child.Name == "Line" and child:IsA("TextLabel")) then
                    shrinkHeight = shrinkHeight + child.Size.Y.Offset
                    child:Destroy()
                end
            end
            Frame.Size = Frame.Size - UDim2.new(0, 0, 0, -shrinkHeight)
        end
		return ""
	end
}