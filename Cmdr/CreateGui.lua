return function ()
	local Cmdr = Instance.new("ScreenGui")
	Cmdr.DisplayOrder = 1000
	Cmdr.Name = "Cmdr"
	Cmdr.ResetOnSpawn = false
	Cmdr.AutoLocalize = false

	local Frame = Instance.new("ScrollingFrame")
	Frame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
	Frame.BackgroundTransparency = 0.4
	Frame.BorderSizePixel = 0
	Frame.CanvasSize = UDim2.new(0, 0, 0, 100)
	Frame.Name = "Frame"
	Frame.Position = UDim2.new(0.025, 0, 0, 25)
	Frame.ScrollBarThickness = 6
	Frame.ScrollingDirection = Enum.ScrollingDirection.Y
	Frame.Selectable = false
	Frame.Size = UDim2.new(0.95, 0, 0, 50)
	Frame.Visible = false
	Frame.Parent = Cmdr

	local Autocomplete = Instance.new("Frame")
	Autocomplete.BackgroundColor3 = Color3.fromRGB(59, 59, 59)
	Autocomplete.BackgroundTransparency = 0.5
	Autocomplete.BorderSizePixel = 0
	Autocomplete.Name = "Autocomplete"
	Autocomplete.Position = UDim2.new(0, 167, 0, 75)
	Autocomplete.Size = UDim2.new(0, 200, 0, 200)
	Autocomplete.Visible = false
	Autocomplete.Parent = Cmdr

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Parent = Frame

	local Line = Instance.new("TextLabel")
	Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Line.BackgroundTransparency = 1
	Line.Font = Enum.Font.Code
	Line.Name = "Line"
	Line.Size = UDim2.new(1, 0, 0, 20)
	Line.TextColor3 = Color3.fromRGB(255, 255, 255)
	Line.TextSize = 14
	Line.TextXAlignment = Enum.TextXAlignment.Left
	Line.Parent = Frame

	local UIPadding = Instance.new("UIPadding")
	UIPadding.PaddingBottom = UDim.new(0, 10)
	UIPadding.PaddingLeft = UDim.new(0, 10)
	UIPadding.PaddingRight = UDim.new(0, 10)
	UIPadding.PaddingTop = UDim.new(0, 10)
	UIPadding.Parent = Frame

	local Entry = Instance.new("Frame")
	Entry.BackgroundTransparency = 1
	Entry.LayoutOrder = 999999999
	Entry.Name = "Entry"
	Entry.Size = UDim2.new(1, 0, 0, 20)
	Entry.Parent = Frame

	local UIListLayout2 = Instance.new("UIListLayout")
	UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout2.Parent = Autocomplete

	local Title = Instance.new("Frame")
	Title.BackgroundColor3 = Color3.fromRGB(59, 59, 59)
	Title.BackgroundTransparency = 0.2
	Title.BorderSizePixel = 0
	Title.LayoutOrder = -2
	Title.Name = "Title"
	Title.Size = UDim2.new(1, 0, 0, 40)
	Title.Parent = Autocomplete

	local Description = Instance.new("Frame")
	Description.BackgroundColor3 = Color3.fromRGB(59, 59, 59)
	Description.BackgroundTransparency = 0.2
	Description.BorderSizePixel = 0
	Description.LayoutOrder = -1
	Description.Name = "Description"
	Description.Size = UDim2.new(1, 0, 0, 20)
	Description.Parent = Autocomplete

	local TextButton = Instance.new("TextButton")
	TextButton.BackgroundColor3 = Color3.fromRGB(59, 59, 59)
	TextButton.BackgroundTransparency = 0.5
	TextButton.BorderSizePixel = 0
	TextButton.Font = Enum.Font.Code
	TextButton.Size = UDim2.new(1, 0, 0, 30)
	TextButton.Text = ""
	TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextButton.TextSize = 14
	TextButton.TextXAlignment = Enum.TextXAlignment.Left
	TextButton.Parent = Autocomplete

	local TextBox = Instance.new("TextBox")
	TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextBox.BackgroundTransparency = 1
	TextBox.ClearTextOnFocus = false
	TextBox.Font = Enum.Font.Code
	TextBox.LayoutOrder = 999999999
	TextBox.Position = UDim2.new(0, 140, 0, 0)
	TextBox.Size = UDim2.new(1, 0, 0, 20)
	TextBox.Text = "x"
	TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextBox.TextSize = 14
	TextBox.TextXAlignment = Enum.TextXAlignment.Left
	TextBox.Selectable = false
	TextBox.Parent = Entry

	local TextLabel = Instance.new("TextLabel")
	TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.BackgroundTransparency = 1
	TextLabel.Font = Enum.Font.Code
	TextLabel.Size = UDim2.new(0, 133, 0, 20)
	TextLabel.Text = ""
	TextLabel.TextColor3 = Color3.fromRGB(255, 223, 93)
	TextLabel.TextSize = 14
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left
	TextLabel.Parent = Entry

	local Field = Instance.new("TextLabel")
	Field.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Field.BackgroundTransparency = 1
	Field.Font = Enum.Font.SourceSansBold
	Field.Name = "Field"
	Field.Size = UDim2.new(0, 37, 1, 0)
	Field.Text = "from"
	Field.TextColor3 = Color3.fromRGB(255, 255, 255)
	Field.TextSize = 20
	Field.TextXAlignment = Enum.TextXAlignment.Left
	Field.Parent = Title

	local UIPadding2 = Instance.new("UIPadding")
	UIPadding2.PaddingLeft = UDim.new(0, 10)
	UIPadding2.Parent = Title

	local Label = Instance.new("TextLabel")
	Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.SourceSansLight
	Label.Name = "Label"
	Label.Size = UDim2.new(1, 0, 1, 0)
	Label.Text = "The players to teleport. The players to teleport. The players to teleport. The players to teleport. "
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextSize = 16
	Label.TextWrapped = true
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextYAlignment = Enum.TextYAlignment.Top
	Label.Parent = Description

	local UIPadding3 = Instance.new("UIPadding")
	UIPadding3.PaddingBottom = UDim.new(0, 10)
	UIPadding3.PaddingLeft = UDim.new(0, 10)
	UIPadding3.PaddingRight = UDim.new(0, 10)
	UIPadding3.Parent = Description

	local Typed = Instance.new("TextLabel")
	Typed.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Typed.BackgroundTransparency = 1
	Typed.Font = Enum.Font.Code
	Typed.Name = "Typed"
	Typed.Size = UDim2.new(1, 0, 1, 0)
	Typed.Text = "Lab"
	Typed.TextColor3 = Color3.fromRGB(131, 222, 255)
	Typed.TextSize = 14
	Typed.TextXAlignment = Enum.TextXAlignment.Left
	Typed.Parent = TextButton

	local UIPadding4 = Instance.new("UIPadding")
	UIPadding4.PaddingLeft = UDim.new(0, 10)
	UIPadding4.Parent = TextButton

	local Suggest = Instance.new("TextLabel")
	Suggest.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Suggest.BackgroundTransparency = 1
	Suggest.Font = Enum.Font.Code
	Suggest.Name = "Suggest"
	Suggest.Size = UDim2.new(1, 0, 1, 0)
	Suggest.Text = "   el"
	Suggest.TextColor3 = Color3.fromRGB(255, 255, 255)
	Suggest.TextSize = 14
	Suggest.TextXAlignment = Enum.TextXAlignment.Left
	Suggest.Parent = TextButton

	local Type = Instance.new("TextLabel")
	Type.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Type.BackgroundTransparency = 1
	Type.BorderColor3 = Color3.fromRGB(255, 153, 153)
	Type.Font = Enum.Font.SourceSans
	Type.Name = "Type"
	Type.Position = UDim2.new(1, 0, 0, 0)
	Type.Size = UDim2.new(0, 0, 1, 0)
	Type.Text = ": Players"
	Type.TextColor3 = Color3.fromRGB(255, 255, 255)
	Type.TextSize = 15
	Type.TextXAlignment = Enum.TextXAlignment.Left
	Type.Parent = Field

	Cmdr.Parent = game:GetService("StarterGui")
	return Cmdr
end