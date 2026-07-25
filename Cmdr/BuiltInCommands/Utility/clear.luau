return {
	Name = "clear",
	Aliases = { "clr" },
	Description = "Clear all lines above the entry line of the Cmdr window.",
	Group = "DefaultUtil",
	Args = {},
	ClientRun = function(context): string
		const entryFrame = context.Cmdr.Gui:WaitForChild("Frame")
		assert(entryFrame, "[Cmdr] Something went seriously wrong if you're experiencing this error..")

		for _, child in pairs(entryFrame:GetChildren()) do
			if child.Name == "Line" and child:IsA("TextBox") then
				child:Destroy()
			end
		end

		return ""
	end,
}
