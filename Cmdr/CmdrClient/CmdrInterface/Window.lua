-- Here be dragons
-- luacheck: ignore 212
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local LINE_HEIGHT = 20
local WINDOW_MAX_HEIGHT = 300

--- Window handles the command bar GUI
local Window = {
	Valid = true,
	AutoComplete = nil,
	ProcessEntry = nil,
	OnTextChanged = nil,
	Cmdr = nil
}

local Gui = Player:WaitForChild("PlayerGui"):WaitForChild("Cmdr"):WaitForChild("Frame")
local Line = Gui:WaitForChild("Line")
local Entry = Gui:WaitForChild("Entry")

Line.Parent = nil

--- Update the text entry label
function Window:UpdateLabel()
	Entry.TextLabel.Text = Player.Name .. "@" .. self.Cmdr.PlaceName .. "$"
	Entry.TextLabel.Size = UDim2.new(0, Entry.TextLabel.TextBounds.X, 0, 20)
	Entry.TextBox.Position = UDim2.new(0, Entry.TextLabel.Size.X.Offset + 7, 0, 0)
end

--- Get the text entry label
function Window:GetLabel()
	return Entry.TextLabel.Text
end

--- Recalculate the window height
function Window:UpdateWindowHeight()
	local numLines = 0

	for _, child in pairs(Gui:GetChildren()) do
		if child:IsA("GuiObject") then
			numLines = numLines + 1
		end
	end

	local windowHeight = (numLines * LINE_HEIGHT) + 20

	Gui.CanvasSize = UDim2.new(Gui.CanvasSize.X.Scale, Gui.CanvasSize.X.Offset, 0, windowHeight)
	Gui.Size =
		UDim2.new(
		Gui.Size.X.Scale,
		Gui.Size.X.Offset,
		0,
		windowHeight > WINDOW_MAX_HEIGHT and WINDOW_MAX_HEIGHT or windowHeight
	)

	Gui.CanvasPosition = Vector2.new(0, math.clamp(windowHeight - 300, 0, math.huge))
end

--- Add a line to the command bar
function Window:AddLine(text, color)
	if #text == 0 then
		return
	end

	local line = Line:Clone()
	line.Text = text or "nil"
	line.TextColor3 = color or line.TextColor3
	line.Parent = Gui
end

--- Returns if the command bar is visible
function Window:IsVisible()
	return Gui.Visible
end

--- Sets the command bar visible or not
function Window:SetVisible(visible)
	Gui.Visible = visible

	if visible then
		Entry.TextBox:CaptureFocus()
		self:SetEntryText("")
	else
		Entry.TextBox:ReleaseFocus()
		self.AutoComplete:Hide()
	end
end

--- Hides the command bar
function Window:Hide()
	return self:SetVisible(false)
end

--- Shows the command bar
function Window:Show()
	return self:SetVisible(true)
end

--- Sets the text in the command bar text box, and captures focus
function Window:SetEntryText(text)
	Entry.TextBox.Text = text

	if self:IsVisible() then
		Entry.TextBox:CaptureFocus()
	end
end

--- Gets the text in the command bar text box
function Window:GetEntryText()
	return Entry.TextBox.Text:gsub("\t", "")
end

--- Sets whether the command is in a valid state or not.
-- Cannot submit if in invalid state.
function Window:SetIsValidInput(isValid, errorText)
	Entry.TextBox.TextColor3 = isValid and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 73, 73)
	self.Valid = isValid
	self._errorText = errorText
end

--- Event handler for text box focus lost
function Window:LoseFocus(submit)
	local text = Entry.TextBox.Text

	if Gui.Visible and not GuiService.MenuIsOpen then
		-- self:SetEntryText("")
		Entry.TextBox:CaptureFocus()
	elseif GuiService.MenuIsOpen and Gui.Visible then
		self:Hide()
	end

	if submit and self.Valid then
		wait()
		self:SetEntryText("")
		self.ProcessEntry(text)
	elseif submit then
		self:AddLine(self._errorText, Color3.fromRGB(255, 153, 153))
	end
end

local lastPressTime = 0
local pressCount = 0
--- Handles user input when the box is focused
function Window:BeginInput(input, gameProcessed)
	if GuiService.MenuIsOpen then
		self:Hide()
	end

	if self.Cmdr.Enabled == false then
		if self:IsVisible() then
			self:Hide()
		end

		return
	end

	if gameProcessed and self:IsVisible() == false then
		return
	end

	if self.Cmdr.ActivationKeys[input.KeyCode] then -- Activate the command bar
		if self.Cmdr.MashToEnable and not self:IsVisible() then
			if tick() - lastPressTime < 1 then
				if pressCount >= 5 then
					return self.Cmdr:SetEnabled(true)
				else
					pressCount = pressCount + 1
				end
			else
				pressCount = 1
			end
			lastPressTime = tick()
		else
			self:SetVisible(not self:IsVisible())
			wait()
			self:SetEntryText("")

			if GuiService.MenuIsOpen then -- Special case for menu getting stuck open (roblox bug)
				self:Hide()
			end
		end
	elseif input.KeyCode == Enum.KeyCode.Down then -- Auto Complete Down
		self.AutoComplete:Select(1)
	elseif input.KeyCode == Enum.KeyCode.Up then -- Auto Complete Up
		self.AutoComplete:Select(-1)
	elseif input.KeyCode == Enum.KeyCode.Return then -- Eat new lines
		wait()
		self:SetEntryText(self:GetEntryText():gsub("\n", ""):gsub("\r", ""))
	elseif input.KeyCode == Enum.KeyCode.Tab then -- Auto complete
		local item = self.AutoComplete:GetSelectedItem()
		local text = self:GetEntryText()
		if item and not (text:sub(#text, #text):match("%s") and self.AutoComplete.LastItem) then
			local replace = item[2]
			local newText
			local insertSpace = true
			local command = self.AutoComplete.Command

			if command then
				local lastArg = self.AutoComplete.Arg

				newText = command.Alias
				insertSpace = self.AutoComplete.NumArgs ~= #command.ArgumentDefinitions

				local args = command.Arguments
				for i = 1, #args do
					local arg = args[i]
					local segments = arg.RawSegments
					if arg == lastArg then
						segments[#segments] = replace
					end

					local argText = arg.Prefix .. table.concat(segments, ",")

					-- Put auto completion options in quotation marks if they have a space
					if argText:find(" ") then
						argText = ("%q"):format(argText)
					end

					newText = ("%s %s"):format(newText, argText)

					if arg == lastArg then
						break
					end
				end
			else
				newText = replace
			end
			-- need to wait a frame so we can eat the \t
			wait()
			-- Update the text box
			self:SetEntryText(newText .. (insertSpace and " " or ""))
		else
			-- Still need to eat the \t even if there is no auto-complete to show
			wait()
			self:SetEntryText(self:GetEntryText())
		end
	end
end

-- Hook events
Entry.TextBox.FocusLost:Connect(
	function(submit)
		return Window:LoseFocus(submit)
	end
)

UserInputService.InputBegan:Connect(
	function(input, gameProcessed)
		return Window:BeginInput(input, gameProcessed)
	end
)

Entry.TextBox:GetPropertyChangedSignal("Text"):Connect(
	function()
		if Entry.TextBox.Text:match("\t") then -- Eat \t
			Entry.TextBox.Text = Entry.TextBox.Text:gsub("\t", "")
			return
		end
		if Window.OnTextChanged then
			return Window.OnTextChanged(Entry.TextBox.Text)
		end
	end
)

Gui.ChildAdded:Connect(Window.UpdateWindowHeight)

return Window
