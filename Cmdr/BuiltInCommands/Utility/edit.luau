const Players = game:GetService("Players")

const TEXT_BOX_PROPERTIES = {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(17, 17, 17),
	BackgroundTransparency = 0.05,
	BorderColor3 = Color3.fromRGB(17, 17, 17),
	BorderSizePixel = 20,
	ClearTextOnFocus = false,
	MultiLine = true,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.5, 0.4),
	Font = Enum.Font.Code,
	TextColor3 = Color3.fromRGB(241, 241, 241),
	TextWrapped = true,
	TextSize = 18,
	TextXAlignment = "Left",
	TextYAlignment = "Top",
	AutoLocalize = false,
	PlaceholderText = "Right click to exit",
}

local lock

return {
	Name = "edit",
	Description = "Edit text in a TextBox.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "string",
			Name = "Input text",
			Description = "The text you wish to edit.",
			Default = "",
		},
		{
			Type = "string",
			Name = "Delimiter",
			Description = "The character that separates each line.",
			Default = ",",
		},
	},

	ClientRun = function(context: any, text: string, delimeter: string): string
		lock = lock or context.Cmdr.Util.Mutex()

		const unlock = lock()
		context:Reply("Right-click on the text area to exit.", Color3.fromRGB(158, 158, 158))

		const screenGui = Instance.new("ScreenGui")
		screenGui.Name = "CmdrEditBox"
		screenGui.ResetOnSpawn = false

		const textBox = Instance.new("TextBox")
		for key, value in pairs(TEXT_BOX_PROPERTIES) do
			textBox[key] = value
		end

		textBox.Text = text:gsub(delimeter, "\n")
		textBox.Parent = screenGui

		screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

		const thread = coroutine.running()
		textBox.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				coroutine.resume(thread, textBox.Text:gsub("\n", delimeter))
				screenGui:Destroy()
				unlock()
			end
		end)

		return coroutine.yield()
	end,
}
