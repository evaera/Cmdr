const GuiService = game:GetService("GuiService")
const Players = game:GetService("Players")
const TextChatService = game:GetService("TextChatService")
const UserInputService = game:GetService("UserInputService")

const WINDOW_MAX_HEIGHT = 300
const MOUSE_TOUCH_INPUTS =
	{ Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.Touch }

const VALID_TEXT_COLOR = Color3.fromRGB(255, 255, 255)
const INVALID_TEXT_COLOR = Color3.fromRGB(255, 73, 73)
const PROCESSING_TEXT_COLOR = Color3.fromRGB(255, 223, 93)

const Player = Players.LocalPlayer

-- Checks if a screen position lies outside a given GUI bounds
const function isPositionOutsideGui(position: Vector3, gui: GuiObject): boolean
	local absolutePosition = gui.AbsolutePosition
	local absoluteSize = gui.AbsoluteSize
	return position.X < absolutePosition.X
		or position.X > absolutePosition.X + absoluteSize.X
		or position.Y < absolutePosition.Y
		or position.Y > absolutePosition.Y + absoluteSize.Y
end

-- Constructs auto-completed text string from command argument definitions
local function buildAutoCompleteText(command, lastArg, replace: string): string
	local newText = command.Alias
	for _, argument in command.Arguments do
		local segments = argument.RawSegments
		if argument == lastArg then
			segments[#segments] = replace
		end

		local argumentText = `{argument.Prefix}{table.concat(segments, ",")}`
		if argumentText:find(" ") or argumentText == "" then
			argumentText = ("%q"):format(argumentText)
		end

		newText = `{newText} {argumentText}`
		if argument == lastArg then
			break
		end
	end

	return newText
end

--[=[
	@class Window
	@ignore
	Handles the Cmdr command bar interface.
]=]

return function(CmdrClient, AutoComplete)
	const entryFrame = CmdrClient.Gui:WaitForChild("Frame")
	const Window = {
		_entry = entryFrame:WaitForChild("Entry") :: Frame,
		_lineTemplate = entryFrame:WaitForChild("Line") :: TextBox,

		_previousChatWindowEnabled = nil :: boolean?,
		_previousChatInputBarEnabled = nil :: boolean?,
		_previousChannelTabsEnabled = nil :: boolean?,
		_previousMouseBehavior = nil :: Enum.MouseBehavior?,

		_hasLostFocus = false,

		_valid = true,
		_errorText = nil :: string?,
		_historyState = nil :: { Position: number, InitialText: string }?,

		_pressCount = 0,
		_lastPressTime = 0,
	}

	--[=[
		@within Window
		Get the text entry label
	]=]
	function Window:GetLabelText()
		return self._entry.TextLabel.Text
	end

	--[=[
		@within Window
		Updates the command prompt label.
	]=]
	function Window:UpdateLabelText()
		const placeName = CmdrClient._placeName
		self._entry.TextLabel.Text = `{Player.Name}{if placeName and placeName ~= "" then `@{placeName}` else ""}$`
	end

	--[=[
		@within Window
		Recalculate the window height
	]=]
	function Window:UpdateWindowHeight()
		const layout = entryFrame.UIListLayout
		const padding = entryFrame.UIPadding
		const height = layout.AbsoluteContentSize.Y + padding.PaddingTop.Offset + padding.PaddingBottom.Offset

		const xSize = entryFrame.Size.X
		const clampedHeight = math.clamp(height, 0, WINDOW_MAX_HEIGHT)

		entryFrame.Size = UDim2.new(xSize.Scale, xSize.Offset, 0, clampedHeight)
		entryFrame.CanvasPosition = Vector2.new(0, height)
		AutoComplete:_updateContainerPosition()
	end

	--[=[
		@within Window
		@private

		Sets the command entry text.
	]=]
	function Window:_setEntryText(text: string)
		self._entry.TextBox.Text = text

		if self:IsVisible() then
			self._entry.TextBox.CursorPosition = #text + 1
			self:UpdateWindowHeight()
		end
	end

	--[=[
		@within Window
		Returns the current command prompt label.
	]=]
	function Window:GetEntryText(): string
		return self._entry.TextBox.Text:gsub("\t", "")
	end

	--[=[
		@within Window
		Adds a line to the command output.
	]=]
	function Window:AddLine(text: any, options: any)
		options = options or {}
		text = tostring(text)

		if typeof(options) == "Color3" then
			options = { Color = options }
		end

		if text == "" then
			self:UpdateWindowHeight()
			return
		end

		const line = self._lineTemplate:Clone()
		line.Text = CmdrClient.Util.EmulateTabstops(text, 8)
		line.TextColor3 = options.Color or line.TextColor3
		line.RichText = options.RichText or false
		line.Parent = entryFrame
	end

	--[=[
		@within Window
		@private

		Sets the visibility of the Roblox chat interface.
	]=]
	function Window:_setChatEnabled(enabled: boolean)
		if not enabled then
			-- Save previous state before disabling
			self._previousChatWindowEnabled = TextChatService.ChatWindowConfiguration.Enabled
			self._previousChatInputBarEnabled = TextChatService.ChatInputBarConfiguration.Enabled
			self._previousChannelTabsEnabled = TextChatService.ChannelTabsConfiguration.Enabled

			TextChatService.ChatWindowConfiguration.Enabled = false
			TextChatService.ChatInputBarConfiguration.Enabled = false
			TextChatService.ChannelTabsConfiguration.Enabled = false
		else
			-- Restore previous state
			TextChatService.ChatWindowConfiguration.Enabled = if self._previousChatWindowEnabled ~= nil
				then self._previousChatWindowEnabled
				else true
			TextChatService.ChatInputBarConfiguration.Enabled = if self._previousChatInputBarEnabled ~= nil
				then self._previousChatInputBarEnabled
				else true
			TextChatService.ChannelTabsConfiguration.Enabled = if self._previousChannelTabsEnabled ~= nil
				then self._previousChannelTabsEnabled
				else true
		end
	end

	--[=[
		@within Window
		@private

		Sets or restores the mouse behavior while Cmdr is open.
	]=]
	function Window:_setMouseUnlocked(unlock: boolean)
		if unlock then
			if not CmdrClient._activationUnlocksMouse then
				return
			end

			self._previousMouseBehavior = UserInputService.MouseBehavior
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		else
			if not self._previousMouseBehavior then
				return
			end

			UserInputService.MouseBehavior = self._previousMouseBehavior
			self._previousMouseBehavior = nil
		end
	end

	--[=[
		@within Window
		Sets whether the command bar is visible.
	]=]
	function Window:SetVisible(visible: boolean)
		entryFrame.Visible = visible

		if visible then
			self:_setChatEnabled(false)
			self:_setMouseUnlocked(true)

			self:_setEntryText("")
			self._entry.TextBox:CaptureFocus()
		else
			self:_setChatEnabled(true)
			self:_setMouseUnlocked(false)

			AutoComplete:Hide()
			self._entry.TextBox:ReleaseFocus()
		end

		CmdrClient.Toggled:Fire(visible)
	end

	--[=[
		@within Window
		Returns whether the command bar is currently visible.
	]=]
	function Window:IsVisible(): boolean
		return entryFrame.Visible
	end

	--[=[
		@within Window
		Hides the command bar.
	]=]
	function Window:Hide()
		self:SetVisible(false)
	end

	--[=[
		@within Window
		Shows the command bar.
	]=]
	function Window:Show()
		self:SetVisible(true)
	end

	--[=[
		@within Window
		@private

		Sets whether the current input is valid.
	]=]
	function Window:_setIsValidInput(isValid: boolean, errorText: string?)
		self._entry.TextBox.TextColor3 = if isValid then VALID_TEXT_COLOR else INVALID_TEXT_COLOR
		self._valid = isValid
		self._errorText = errorText
	end

	--[=[
		@within Window
		Clears the invalid input visual state.
	]=]
	function Window:HideInvalidState()
		self._entry.TextBox.TextColor3 = VALID_TEXT_COLOR
	end

	--[=[
		@within Window
		@private

		Navigates through the command history buffer using an index delta.
	]=]
	function Window:_traverseHistory(delta: number)
		const history = CmdrClient.Dispatcher:GetHistory()
		if not self._historyState then
			self._historyState = {
				Position = #history + 1,
				InitialText = self:GetEntryText(),
			}
		end

		self._historyState.Position = math.clamp(self._historyState.Position + delta, 1, #history + 1)
		self:_setEntryText(
			if self._historyState.Position == #history + 1
				then self._historyState.InitialText
				else history[self._historyState.Position]
		)
	end

	--[=[
		@within Window
		@private

		Resets the stored command history navigation state.
	]=]
	function Window:_clearHistoryState()
		self._historyState = nil
	end

	--[=[
		@within Window
		@private

		Handles vertical directional navigation.
	]=]
	function Window:_selectVertical(delta: number)
		if AutoComplete:IsVisible() and not self._historyState then
			AutoComplete:Select(delta)
		else
			self:_traverseHistory(delta)
		end
	end

	--[=[
		@within Window
		@private

		Trims the input command text.
	]=]
	function Window._processEntry(text: string)
		text = CmdrClient.Util.TrimString(text)

		if #text == 0 then
			return
		end

		Window:AddLine(`{Window:GetLabelText()} {text}`, PROCESSING_TEXT_COLOR)
		Window:AddLine(CmdrClient.Dispatcher:EvaluateAndRun(text, Player, { IsHuman = true }))
	end

	--[=[
		@within Window
		@private

		Handles user input when the box is focused.
	]=]
	function Window:_loseFocus(submit: boolean)
		if self._hasLostFocus then
			return
		end

		const text = self._entry.TextBox.Text
		self:_clearHistoryState()

		--[[
		NOTE: This behavior exists to recapture focus when pressing on anywhere within the UI.
		While I understand the purpose for this, it prevents users from copying text of previous output,
		and immediately recaptures the UI when closing it via escape. I have removed this for the time being.
		This might be worth revisiting sometime in the future if enough complaints appear however.

		if self:IsVisible() and not GuiService.MenuIsOpen and not UserInputService.TouchEnabled then
			self._entry.TextBox:CaptureFocus()
		else
		--]]

		if self:IsVisible() and GuiService.MenuIsOpen then
			self:Hide()
		end

		if submit then
			self._hasLostFocus = true

			if self._valid then
				self:_setEntryText("")
				self._processEntry(text)
			else
				self:AddLine(self._errorText, Color3.fromRGB(255, 153, 153))
			end

			self._hasLostFocus = false
		end
	end

	--[=[
		@within Window
		@private

		Process activation toggle keys.
	]=]
	function Window:_handleActivationKey()
		if not CmdrClient._enabled then
			return
		end

		const currentTime = os.clock()
		if CmdrClient._mashToEnable then
			-- Increment mash counter if pressed within 1 second window
			self._pressCount = if currentTime - self._lastPressTime < 1 then self._pressCount + 1 else 1
			self._lastPressTime = currentTime

			if self._pressCount >= 5 then
				self._pressCount = 0
				CmdrClient._mashToEnable = false
				self:SetVisible(true)
			end
		else
			self:SetVisible(not self:IsVisible())
		end
	end

	--[=[
		@within Window
		@private

		Handles Tab key auto-completion logic.
	]=]
	function Window:_handleTabCompletion()
		const item = AutoComplete:GetSelectedItem()
		const text = self:GetEntryText()

		if not item or (text:sub(#text, #text):match("%s") and AutoComplete.LastItem) then
			task.wait()
			self:_setEntryText(text)
			return
		end

		const replace = item[2]
		local newText
		local insertSpace = true

		const command = AutoComplete.Command
		if command then
			insertSpace = AutoComplete.NumArgs ~= #command.ArgumentDefinitions and not AutoComplete.IsPartial
			newText = buildAutoCompleteText(command, AutoComplete.Arg, replace)
		else
			newText = replace
		end

		task.wait()
		self:_setEntryText(`{newText}{if insertSpace then " " else ""}`)
	end

	--[=[
		@within Window
		@private

		Event handler for user input.
	]=]
	function Window:_beginInput(input: InputObject, gameProcessed: boolean)
		if GuiService.MenuIsOpen then
			self:Hide()
		end

		if gameProcessed and not self:IsVisible() then
			return
		end

		-- Check for activation shortcut keys
		if table.find(CmdrClient._activationKeys, input.KeyCode) then
			self:_handleActivationKey()
			return
		end

		-- Guard against disabled client state or hidden window
		if not CmdrClient._enabled then
			if self:IsVisible() then
				self:Hide()
			end

			return
		end

		if not self:IsVisible() then
			return
		end

		-- Check for mouse clicks outside window boundaries
		if CmdrClient._hideOnLostFocus and table.find(MOUSE_TOUCH_INPUTS, input.UserInputType) then
			if isPositionOutsideGui(input.Position, entryFrame) then
				self:Hide()
			end

			return
		end

		-- Key action mappings
		if input.KeyCode == Enum.KeyCode.Escape then
			self:Hide()
		elseif input.KeyCode == Enum.KeyCode.Backspace and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			self:_setEntryText("")
		elseif input.KeyCode == Enum.KeyCode.Down then
			self:_selectVertical(1)
		elseif input.KeyCode == Enum.KeyCode.Up then
			self:_selectVertical(-1)
		elseif input.KeyCode == Enum.KeyCode.Return then
			task.wait()
			self:_setEntryText(self:GetEntryText():gsub("\n", ""):gsub("\r", ""))
		elseif input.KeyCode == Enum.KeyCode.Tab then
			if self._entry.TextBox.IsFocused then
				self:_handleTabCompletion()
			else
				self._entry.TextBox:CaptureFocus()
			end
		else
			self:_clearHistoryState()
		end
	end

	--[=[
		@within Window
		@private

		Processes autocomplete for command arguments once a command name is active.
	]=]
	function Window._handleArgumentAutoComplete(
		command: any,
		arguments: { string },
		text: string,
		hasTrailingSpace: boolean,
		atEnd: boolean
	)
		const commandValid, commandError = command:Validate()
		Window:_setIsValidInput(commandValid, `Validation errors: {commandError or ""}`)

		const lastArgument = command:GetArgument(#arguments)
		if not lastArgument then
			return
		end

		const autocompleteItems = {}
		const typedText = lastArgument.TextSegmentInProgress
		local isPartial = false

		if lastArgument.RawSegmentsAreAutocomplete then
			for index, segment in ipairs(lastArgument.RawSegments) do
				autocompleteItems[index] = { segment, segment }
			end
		else
			local items, options = lastArgument:GetAutocomplete()
			options = options or {}
			isPartial = options.IsPartial or false

			for index, item in ipairs(items) do
				autocompleteItems[index] = { typedText, item }
			end
		end

		local argumentValid = true
		local argumentError

		if #typedText > 0 then
			argumentValid, argumentError = lastArgument:Validate()
		end

		if not atEnd and argumentValid then
			Window:HideInvalidState()
		end

		return AutoComplete:Show(autocompleteItems, {
			at = atEnd and #text - #typedText + (if hasTrailingSpace then -1 else 0),
			prefix = if #lastArgument.RawSegments == 1 then lastArgument.Prefix else "",
			isLast = #command.Arguments == #command.ArgumentDefinitions and #typedText > 0,
			numArgs = #arguments,
			command = command,
			arg = lastArgument,
			name = `{lastArgument.Name}{if lastArgument.Required then "" else "?"}`,
			type = lastArgument.Type.DisplayName,
			description = if argumentValid then lastArgument.Object.Description else argumentError,
			invalid = not argumentValid,
			isPartial = isPartial,
		})
	end

	--[=[
		@within Window
		@private

		Processes autocomplete for initial command name lookup.
	]=]
	function Window._handleCommandAutoComplete(commandText: string, command: any)
		Window:_setIsValidInput(true)

		const exactCommand = CmdrClient.Registry:GetCommand(commandText)
		local exactMatch

		if exactCommand and not exactCommand._isHidden then
			-- selene: allow(mixed_table)
			exactMatch = {
				exactCommand.Name,
				exactCommand.Name,
				options = {
					name = exactCommand.Name,
					description = exactCommand.Description,
				},
			}

			local argument = exactCommand.Args and exactCommand.Args[1]
			if type(argument) == "function" then
				argument = argument(command)
			end

			if argument and not argument.Optional and argument.Default == nil then
				Window:_setIsValidInput(false, "This command has required arguments.")
				Window:HideInvalidState()
			end
		else
			Window:_setIsValidInput(
				false,
				`{commandText} is not a valid command name. Use the help command to see all available commands.`
			)
		end

		const autocompleteItems = { exactMatch }
		-- selene: allow(mixed_table)
		for _, commandName in ipairs(CmdrClient.Registry:GetCommandNames(true)) do
			if commandText:lower() ~= commandName:lower():sub(1, #commandText) then
				continue
			end

			if exactMatch and exactMatch[1] == commandName then
				continue
			end

			const commandObject = CmdrClient.Registry:GetCommand(commandName)
			autocompleteItems[#autocompleteItems + 1] = {
				commandText,
				commandName,
				options = {
					name = commandObject.Name,
					description = commandObject.Description,
				},
			}
		end

		return AutoComplete:Show(autocompleteItems)
	end

	--[=[
		@within Window
		@private

		Fired whenever the command input text changes. Validates inputs and updates the autocomplete view.
	]=]
	function Window._onTextChanged(text: string)
		const command = CmdrClient.Dispatcher:Evaluate(text, Player, true)
		local arguments = CmdrClient.Util.SplitString(text)
		const commandText = table.remove(arguments, 1)

		const hasTrailingSpace = text:sub(#text, #text):match("%s") ~= nil
		local atEnd = false
		if command then
			arguments = CmdrClient.Util.MashExcessArguments(arguments, #command.Object.Args)
			atEnd = #arguments == #command.Object.Args
		end

		local entryComplete = commandText and #arguments > 0
		if hasTrailingSpace and not atEnd then
			entryComplete = true
			arguments[#arguments + 1] = ""
		end

		if command and entryComplete then
			Window._handleArgumentAutoComplete(command, arguments, text, hasTrailingSpace, atEnd)
			return
		end

		if commandText and #arguments == 0 then
			Window._handleCommandAutoComplete(commandText, command)
			return
		end

		Window:_setIsValidInput(false, "Use the help command to see all available commands.")
		AutoComplete:Hide()
	end

	Window._entry.TextBox.FocusLost:Connect(function(submit: boolean)
		Window:_loseFocus(submit)
	end)

	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		Window:_beginInput(input, gameProcessed)
	end)

	Window._entry.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
		entryFrame.CanvasPosition = Vector2.new(0, entryFrame.AbsoluteCanvasSize.Y)

		if Window._entry.TextBox.Text:match("\t") then
			Window._entry.TextBox.Text = Window._entry.TextBox.Text:gsub("\t", "")
			return
		end

		Window._onTextChanged(Window._entry.TextBox.Text)
	end)

	entryFrame.ChildAdded:Connect(function()
		task.defer(Window.UpdateWindowHeight, Window)
	end)

	Window._lineTemplate.Parent = script

	return Window
end
