return {
	Name = "clear",
	Aliases = {},
	Description = "Clear all lines above the entry line of the Cmdr window.",
	Group = "DefaultUtil",
	Args = {},
	ClientRun = function(context)
		local frame = context.Cmdr.Gui:WaitForChild("Frame")
		if frame then
			for _, child in pairs(frame:GetChildren()) do
				if child.Name == "Line" and child:IsA("TextBox") then
					child:Destroy()
				end
			end
		end

		return ""
	end,
}
