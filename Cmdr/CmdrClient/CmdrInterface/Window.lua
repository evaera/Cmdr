-- Here be dragons
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local WINDOW_MAX_HEIGHT = 300
local MOUSE_TOUCH_ENUM = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.Touch }

-- Window handles the command bar GUI
local Window = {
	Valid = true,
	AutoComplete = nil,
	ProcessEntry = nil,
	OnTextChanged = nil,
	Cmdr = nil,
	HistoryState = nil,
}

local Gui = Player:WaitForChild("PlayerGui"):WaitForChild("Cmdr"):WaitForChild("Frame")
local Line = Gui:WaitForChild("Line")
local Entry = Gui:WaitForChild("Entry")

Line.Parent = nil

-- Update the text entry label
function Window:UpdateLabel()
	Entry.TextLabel.Text =
		`{Player.Name}{if self.Cmdr.PlaceName and self.Cmdr.PlaceName ~= "" then `@{self.Cmdr.PlaceName}` else ""}$`
end

-- Get the text entry label
function Window:GetLabel()
	return Entry.TextLabel.Text
end

-- Recalculate the window height
function Window:UpdateWindowHeight()
	local windowHeight = Gui.UIListLayout.AbsoluteContentSize.Y
		+ Gui.UIPadding.PaddingTop.Offset
		+ Gui.UIPadding.PaddingBottom.Offset
	Gui.Size = UDim2.new(Gui.Size.X.Scale, Gui.Size.X.Offset, 0, math.clamp(windowHeight, 0, WINDOW_MAX_HEIGHT))
	Gui.CanvasPosition = Vector2.new(0, windowHeight)
end

-- Add a line to the command bar
function Window:AddLine(text, options)
	options = options or {}
	text = tostring(text)

	if typeof(options) == "Color3" then
		options = { Color = options }
	end

	if #text == 0 then
		Window:UpdateWindowHeight()
		return
	end

	local str = self.Cmdr.Util.EmulateTabstops(text or "nil", 8)

	local line = Line:Clone()
	line.Text = str
	line.TextColor3 = options.Color or line.TextColor3
	line.RichText = options.RichText or false
	line.Parent = Gui
end

-- Returns if the command bar is visible
function Window:IsVisible()
	return Gui.Visible
end

-- Sets the command bar visible or not
function Window:SetVisible(visible)
	Gui.Visible = visible

	if visible then
		self.PreviousChatWindowConfigurationEnabled = TextChatService.ChatWindowConfiguration.Enabled
		self.PreviousChatInputBarConfigurationEnabled = TextChatService.ChatInputBarConfiguration.Enabled
		self.PreviousChannelTabsConfigurationEnabled = TextChatService.ChannelTabsConfiguration.Enabled
		TextChatService.ChatWindowConfiguration.Enabled = false
		TextChatService.ChatInputBarConfiguration.Enabled = false
		TextChatService.ChannelTabsConfiguration.Enabled = false

		Entry.TextBox:CaptureFocus()
		self:SetEntryText("")

		if self.Cmdr.ActivationUnlocksMouse then
			self.PreviousMouseBehavior = UserInputService.MouseBehavior
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	else
		TextChatService.ChatWindowConfiguration.Enabled = if self.PreviousChatWindowConfigurationEnabled ~= nil
			then self.PreviousChatWindowConfigurationEnabled
			else true
		TextChatService.ChatInputBarConfiguration.Enabled = if self.PreviousChatInputBarConfigurationEnabled
				~= nil
			then self.PreviousChatInputBarConfigurationEnabled
			else true
		TextChatService.ChannelTabsConfiguration.Enabled = if self.PreviousChannelTabsConfigurationEnabled ~= nil
			then self.PreviousChannelTabsConfigurationEnabled
			else true

		Entry.TextBox:ReleaseFocus()
		self.AutoComplete:Hide()

		if self.PreviousMouseBehavior then
			UserInputService.MouseBehavior = self.PreviousMouseBehavior
			self.PreviousMouseBehavior = nil
		end
	end
end

-- Hides the command bar
function Window:Hide()
	return self:SetVisible(false)
end

-- Shows the command bar
function Window:Show()
	return self:SetVisible(true)
end

-- Sets the text in the command bar text box, and captures focus
function Window:SetEntryText(text)
	Entry.TextBox.Text = text

	if self:IsVisible() then
		Entry.TextBox:CaptureFocus()
		Entry.TextBox.CursorPosition = #text + 1
		Window:UpdateWindowHeight()
	end
end

-- Gets the text in the command bar text box
function Window:GetEntryText()
	return Entry.TextBox.Text:gsub("\t", "")
end

-- Sets whether the command is in a valid state or not.
-- Cannot submit if in invalid state.
function Window:SetIsValidInput(isValid, errorText)
	Entry.TextBox.TextColor3 = isValid and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 73, 73)
	self.Valid = isValid
	self._errorText = errorText
end

function Window:HideInvalidState()
	Entry.TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
end

-- Event handler for text box focus lost
function Window:LoseFocus(submit)
	local text = Entry.TextBox.Text

	self:ClearHistoryState()

	if Gui.Visible and not GuiService.MenuIsOpen and not UserInputService.TouchEnabled then
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

function Window:TraverseHistory(delta)
	local history = self.Cmdr.Dispatcher:GetHistory()

	if self.HistoryState == nil then
		self.HistoryState = {
			Position = #history + 1,
			InitialText = self:GetEntryText(),
		}
	end

	self.HistoryState.Position = math.clamp(self.HistoryState.Position + delta, 1, #history + 1)

	self:SetEntryText(
		self.HistoryState.Position == #history + 1 and self.HistoryState.InitialText
			or history[self.HistoryState.Position]
	)
end

function Window:ClearHistoryState()
	self.HistoryState = nil
end

function Window:SelectVertical(delta)
	if self.AutoComplete:IsVisible() and not self.HistoryState then
		self.AutoComplete:Select(delta)
	else
		self:TraverseHistory(delta)
	end
end

local lastPressTime = 0
local pressCount = 0
-- Handles user input when the box is focused
function Window:BeginInput(input, gameProcessed)
	if GuiService.MenuIsOpen then
		self:Hide()
	end

	if gameProcessed and self:IsVisible() == false then
		return
	end

	if self.Cmdr.ActivationKeys[input.KeyCode] then -- Activate the command bar
		if self.Cmdr.MashToEnable and not self.Cmdr.Enabled then
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
		elseif self.Cmdr.Enabled then
			self:SetVisible(not self:IsVisible())
			wait()
			self:SetEntryText("")

			if GuiService.MenuIsOpen then -- Special case for menu getting stuck open (roblox bug)
				self:Hide()
			end
		end

		return
	end

	if self.Cmdr.Enabled == false or not self:IsVisible() then
		if self:IsVisible() then
			self:Hide()
		end

		return
	end

	if self.Cmdr.HideOnLostFocus and table.find(MOUSE_TOUCH_ENUM, input.UserInputType) then
		local ps = input.Position
		local ap = Gui.AbsolutePosition
		local as = Gui.AbsoluteSize
		if ps.X < ap.X or ps.X > ap.X + as.X or ps.Y < ap.Y or ps.Y > ap.Y + as.Y then
			self:Hide()
		end
	elseif input.KeyCode == Enum.KeyCode.Down then -- Auto Complete Down
		self:SelectVertical(1)
	elseif input.KeyCode == Enum.KeyCode.Up then -- Auto Complete Up
		self:SelectVertical(-1)
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
					and self.AutoComplete.IsPartial == false

				local args = command.Arguments
				for i = 1, #args do
					local arg = args[i]
					local segments = arg.RawSegments
					if arg == lastArg then
						segments[#segments] = replace
					end

					local argText = arg.Prefix .. table.concat(segments, ",")

					-- Put auto completion options in quotation marks if they have a space
					if argText:find(" ") or argText == "" then
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
	else
		self:ClearHistoryState()
	end
end

-- Hook events
Entry.TextBox.FocusLost:Connect(function(submit)
	return Window:LoseFocus(submit)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	return Window:BeginInput(input, gameProcessed)
end)

Entry.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
	Gui.CanvasPosition = Vector2.new(0, Gui.AbsoluteCanvasSize.Y)

	if Entry.TextBox.Text:match("\t") then -- Eat \t
		Entry.TextBox.Text = Entry.TextBox.Text:gsub("\t", "")
		return
	end
	if Window.OnTextChanged then
		return Window.OnTextChanged(Entry.TextBox.Text)
	end
end)

Gui.ChildAdded:Connect(function()
	task.defer(Window.UpdateWindowHeight)
end)

return Window
