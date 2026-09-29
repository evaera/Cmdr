const ContextActionService = game:GetService("ContextActionService")
const GuiService = game:GetService("GuiService")
const Players = game:GetService("Players")
const TextChatService = game:GetService("TextChatService")
const UserInputService = game:GetService("UserInputService")

const WINDOW_MAX_HEIGHT = 300
const MOUSE_TOUCH_INPUTS =
	{ Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.Touch }

const ACTION_PRIORITY = Enum.ContextActionPriority.High.Value
const ACTIVATION_ACTION = "CmdrActivation"
const REFOCUS_ACTION = "CmdrRefocus"
const CLICK_OUTSIDE_ACTION = "CmdrClickOutside"

const VALID_TEXT_COLOR = Color3.fromRGB(255, 255, 255)
const INVALID_TEXT_COLOR = Color3.fromRGB(255, 73, 73)
const PROCESSING_TEXT_COLOR = Color3.fromRGB(255, 223, 93)
const ERROR_TEXT_COLOR = Color3.fromRGB(255, 153, 153)

const Player = Players.LocalPlayer

-- Checks if a screen position lies outside a given GUI bounds
const function isPositionOutsideGui(position: Vector3, gui: GuiObject): boolean
	const topLeft = gui.AbsolutePosition
	const bottomRight = topLeft + gui.AbsoluteSize
	return position.X < topLeft.X or position.X > bottomRight.X or position.Y < topLeft.Y or position.Y > bottomRight.Y
end

-- Constructs auto-completed text string from command argument definitions
const function buildAutoCompleteText(command, lastArg, replace: string): string
	const parts = { command.Alias }
	for _, argument in command.Arguments do
		local segments = argument.RawSegments
		if argument == lastArg then
			segments = table.clone(segments)
			segments[#segments] = replace
		end

		const argumentText = `{argument.Prefix}{table.concat(segments, ",")}`
		const needsQuotes = argumentText == "" or argumentText:find(" ", 1, true) ~= nil
		table.insert(parts, if needsQuotes then ("%q"):format(argumentText) else argumentText)

		if argument == lastArg then
			break
		end
	end

	return table.concat(parts, " ")
end

-- Acting on release keeps the key's own character out of a TextBox focused in response to it
const function onKeyReleased(callback: () -> ())
	local pressed = false

	return function(_, state: Enum.UserInputState): Enum.ContextActionResult
		if state == Enum.UserInputState.Begin then
			pressed = true
		elseif state == Enum.UserInputState.End and pressed then
			pressed = false
			callback()
		else
			pressed = false
		end

		return Enum.ContextActionResult.Pass
	end
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
		_backdrop = CmdrClient.Gui:WaitForChild("Backdrop") :: Frame,
		_mouseUnlocker = CmdrClient.Gui:WaitForChild("MouseUnlocker") :: TextButton,

		_previousChatStates = {} :: { [any]: boolean },
		_visibleInputConnection = nil :: RBXScriptConnection?,
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
		Returns the current command entry text.
	]=]
	function Window:GetEntryText(): string
		return (self._entry.TextBox.Text:gsub("\t", ""))
	end

	--[=[
		@within Window
		Adds a line to the command output.
	]=]
	function Window:AddLine(text: any, options: any)
		const lineText = tostring(text)
		const lineOptions = if typeof(options) == "Color3" then { Color = options } else options or {}

		if lineText == "" then
			self:UpdateWindowHeight()
			return
		end

		const line = self._lineTemplate:Clone()
		line.Text = CmdrClient.Util.EmulateTabstops(lineText, 8)
		line.TextColor3 = lineOptions.Color or line.TextColor3
		line.RichText = lineOptions.RichText or false
		line.Parent = entryFrame
	end

	--[=[
		@within Window
		@private

		Sets the visibility of the Roblox chat interface.
	]=]
	function Window:_setChatEnabled(enabled: boolean)
		if enabled then
			for configuration, wasEnabled in self._previousChatStates do
				configuration.Enabled = wasEnabled
			end

			table.clear(self._previousChatStates)
			return
		end

		const configurations = {
			TextChatService.ChatWindowConfiguration,
			TextChatService.ChatInputBarConfiguration,
			TextChatService.ChannelTabsConfiguration,
		}

		for _, configuration in configurations do
			self._previousChatStates[configuration] = configuration.Enabled
			configuration.Enabled = false
		end
	end

	--[=[
		@within Window
		Unlocks the mouse while the command bar is visible, if activation is set to unlock it.
	]=]
	function Window:UpdateMouseUnlock()
		self._mouseUnlocker.Visible = self:IsVisible() and CmdrClient._activationUnlocksMouse
	end

	--[=[
		@within Window
		Sets whether the command bar is visible.
	]=]
	function Window:SetVisible(visible: boolean)
		if entryFrame.Visible == visible then
			return
		end

		entryFrame.Visible = visible
		self:_setChatEnabled(not visible)
		self:_setInputBound(visible)
		self:UpdateMouseUnlock()

		if visible then
			self._entry.TextBox:CaptureFocus()
			self:_setEntryText("")
		else
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
	function Window:_processEntry(text: string)
		const trimmedText = CmdrClient.Util.TrimString(text)

		if #trimmedText == 0 then
			return
		end

		self:AddLine(`{self:GetLabelText()} {trimmedText}`, PROCESSING_TEXT_COLOR)
		self:AddLine(CmdrClient.Dispatcher:EvaluateAndRun(trimmedText, Player, { IsHuman = true }))
	end

	--[=[
		@within Window
		@private

		Handles the entry losing focus, hiding on escape and running the entry when submitted.
	]=]
	function Window:_loseFocus(submit: boolean, cause: InputObject?)
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

		if cause and cause.KeyCode == Enum.KeyCode.Escape then
			self:Hide()
		elseif submit then
			self._hasLostFocus = true

			task.defer(function()
				if self:IsVisible() then
					self._entry.TextBox:CaptureFocus()
				end
			end)

			if self._valid then
				self:_setEntryText("")
				self:_processEntry(text)
			else
				self:AddLine(self._errorText, ERROR_TEXT_COLOR)
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

		if not item or (AutoComplete.LastItem and text:match("%s$")) then
			self:_setEntryText(text)
			return
		end

		const command = AutoComplete.Command
		const newText = if command then buildAutoCompleteText(command, AutoComplete.Arg, item[2]) else item[2]
		const insertSpace = not command
			or (AutoComplete.NumArgs ~= #command.ArgumentDefinitions and not AutoComplete.IsPartial)

		self:_setEntryText(if insertSpace then `{newText} ` else newText)
	end

	function Window:_handlePointerInput(input: InputObject)
		if
			CmdrClient._hideOnLostFocus
			and table.find(MOUSE_TOUCH_INPUTS, input.UserInputType)
			and isPositionOutsideGui(input.Position, entryFrame)
		then
			self:Hide()
		end
	end

	function Window:_handleVisibleInput(input: InputObject, gameProcessed: boolean)
		const keyCode = input.KeyCode

		if table.find(CmdrClient._activationKeys, keyCode) then
			if gameProcessed then
				self:Hide()
			end
		elseif keyCode == Enum.KeyCode.Backspace and input:IsModifierKeyDown(Enum.ModifierKey.Ctrl) then
			self:_setEntryText("")
		elseif keyCode == Enum.KeyCode.Down then
			self:_selectVertical(1)
		elseif keyCode == Enum.KeyCode.Up then
			self:_selectVertical(-1)
		elseif input.UserInputType == Enum.UserInputType.Keyboard and keyCode ~= Enum.KeyCode.Tab then
			self:_clearHistoryState()
		end
	end

	const activationAction = onKeyReleased(function()
		Window:_handleActivationKey()
	end)

	const refocusAction = onKeyReleased(function()
		Window._entry.TextBox:CaptureFocus()
	end)

	const function clickOutsideAction(_, state: Enum.UserInputState, input: InputObject): Enum.ContextActionResult
		if state == Enum.UserInputState.Begin then
			Window:_handlePointerInput(input)
		end

		return Enum.ContextActionResult.Pass
	end

	function Window:BindActivationKeys()
		ContextActionService:UnbindAction(ACTIVATION_ACTION)

		if #CmdrClient._activationKeys == 0 then
			return
		end

		ContextActionService:BindActionAtPriority(
			ACTIVATION_ACTION,
			activationAction,
			false,
			ACTION_PRIORITY,
			table.unpack(CmdrClient._activationKeys)
		)
	end

	function Window:_setInputBound(bound: boolean)
		self._backdrop.Visible = bound

		if bound then
			ContextActionService:BindActionAtPriority(
				REFOCUS_ACTION,
				refocusAction,
				false,
				ACTION_PRIORITY,
				Enum.KeyCode.Tab
			)
			ContextActionService:BindActionAtPriority(
				CLICK_OUTSIDE_ACTION,
				clickOutsideAction,
				false,
				ACTION_PRIORITY,
				table.unpack(MOUSE_TOUCH_INPUTS)
			)

			self._visibleInputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				self:_handleVisibleInput(input, gameProcessed)
			end)
		else
			ContextActionService:UnbindAction(REFOCUS_ACTION)
			ContextActionService:UnbindAction(CLICK_OUTSIDE_ACTION)

			if self._visibleInputConnection then
				self._visibleInputConnection:Disconnect()
				self._visibleInputConnection = nil
			end
		end
	end

	--[=[
		@within Window
		@private

		Processes autocomplete for command arguments once a command name is active.
	]=]
	function Window:_handleArgumentAutoComplete(
		command: any,
		arguments: { string },
		text: string,
		hasTrailingSpace: boolean,
		atEnd: boolean
	)
		const commandValid, commandError = command:Validate()
		self:_setIsValidInput(commandValid, `Validation errors: {commandError or ""}`)

		const lastArgument = command:GetArgument(#arguments)
		if not lastArgument then
			return
		end

		const autocompleteItems = {}
		const typedText = lastArgument.TextSegmentInProgress
		local isPartial = false

		if lastArgument.RawSegmentsAreAutocomplete then
			for index, segment in lastArgument.RawSegments do
				autocompleteItems[index] = { segment, segment }
			end
		else
			const items, options = lastArgument:GetAutocomplete()
			isPartial = options and options.IsPartial or false

			for index, item in items do
				autocompleteItems[index] = { typedText, item }
			end
		end

		local argumentValid, argumentError = true, nil
		if #typedText > 0 then
			argumentValid, argumentError = lastArgument:Validate()
		end

		if not atEnd and argumentValid then
			self:HideInvalidState()
		end

		AutoComplete:Show(autocompleteItems, {
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
	function Window:_handleCommandAutoComplete(commandText: string, command: any)
		self:_setIsValidInput(true)

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
				self:_setIsValidInput(false, "This command has required arguments.")
				self:HideInvalidState()
			end
		else
			self:_setIsValidInput(
				false,
				`{commandText} is not a valid command name. Use the help command to see all available commands.`
			)
		end

		const loweredText = commandText:lower()
		const autocompleteItems = { exactMatch }
		-- selene: allow(mixed_table)
		for _, commandName in CmdrClient.Registry:GetCommandNames(true) do
			if commandName:lower():sub(1, #loweredText) ~= loweredText then
				continue
			end

			if exactMatch and exactMatch[1] == commandName then
				continue
			end

			const commandObject = CmdrClient.Registry:GetCommand(commandName)
			table.insert(autocompleteItems, {
				commandText,
				commandName,
				options = {
					name = commandObject.Name,
					description = commandObject.Description,
				},
			})
		end

		AutoComplete:Show(autocompleteItems)
	end

	--[=[
		@within Window
		@private

		Fired whenever the command input text changes. Validates inputs and updates the autocomplete view.
	]=]
	function Window:_onTextChanged(text: string)
		const command = CmdrClient.Dispatcher:Evaluate(text, Player, true)
		local arguments = CmdrClient.Util.SplitString(text)
		const commandText = table.remove(arguments, 1)

		const hasTrailingSpace = text:match("%s$") ~= nil
		local atEnd = false
		if command then
			arguments = CmdrClient.Util.MashExcessArguments(arguments, #command.Object.Args)
			atEnd = #arguments == #command.Object.Args
		end

		local entryComplete = commandText and #arguments > 0
		if hasTrailingSpace and not atEnd then
			entryComplete = true
			table.insert(arguments, "")
		end

		if command and entryComplete then
			self:_handleArgumentAutoComplete(command, arguments, text, hasTrailingSpace, atEnd)
		elseif commandText and #arguments == 0 then
			self:_handleCommandAutoComplete(commandText, command)
		else
			self:_setIsValidInput(false, "Use the help command to see all available commands.")
			AutoComplete:Hide()
		end
	end

	const entryTextBox = Window._entry.TextBox

	entryTextBox.FocusLost:Connect(function(submit: boolean, cause: InputObject?)
		Window:_loseFocus(submit, cause)
	end)

	entryTextBox:GetPropertyChangedSignal("Text"):Connect(function()
		const text = entryTextBox.Text
		entryFrame.CanvasPosition = Vector2.new(0, entryFrame.AbsoluteCanvasSize.Y)

		if text:find("\t", 1, true) then
			Window:_handleTabCompletion()
		elseif text:find("[\r\n]") then
			Window:_setEntryText((text:gsub("[\r\n]", "")))
		else
			Window:_onTextChanged(text)
		end
	end)

	Window._backdrop.InputBegan:Connect(function(input: InputObject)
		Window:_handlePointerInput(input)
	end)

	GuiService.MenuOpened:Connect(function()
		Window:Hide()
	end)

	entryFrame.ChildAdded:Connect(function()
		task.defer(Window.UpdateWindowHeight, Window)
	end)

	Window._lineTemplate.Parent = script
	Window:BindActivationKeys()

	return Window
end
