const VALID_TEXT_COLOR = Color3.fromRGB(255, 255, 255)
const INVALID_TEXT_COLOR = Color3.fromRGB(255, 73, 73)
const TEXT_MEASUREMENT_SIZE = Vector2.new(1000, 1000)

--[=[
	@class AutoComplete
	@ignore
	Handles the Cmdr suggestions interface.
]=]

return function(CmdrClient)
	const autoCompleteFrame = CmdrClient.Gui:WaitForChild("Autocomplete") :: ScrollingFrame
	const defaultBarThickness = autoCompleteFrame.ScrollBarThickness

	const AutoComplete = {
		_autoItem = autoCompleteFrame:WaitForChild("TextButton") :: TextButton,
		_title = autoCompleteFrame:WaitForChild("Title") :: TextLabel,
		_description = autoCompleteFrame:WaitForChild("Description") :: TextLabel,
		_entry = CmdrClient.Gui.Frame:WaitForChild("Entry") :: Frame,

		Items = {},
		SelectedItem = 1,

		Prefix = "",
		LastItem = false,

		Command = nil,
		Arg = nil,
		NumArgs = nil,
		IsPartial = false,
	}

	-- Updates the size of the container.
	const function updateContainerSize()
		const xOffset = math.max(AutoComplete._title.Field.TextBounds.X + AutoComplete._title.Field.Type.TextBounds.X, autoCompleteFrame.Size.X.Offset)
		const yOffset = math.min(autoCompleteFrame.UIListLayout.AbsoluteContentSize.Y, autoCompleteFrame.Parent.AbsoluteSize.Y - autoCompleteFrame.AbsolutePosition.Y - 10)
		autoCompleteFrame.Size = UDim2.fromOffset(xOffset, yOffset)
	end

	--[=[
		@within AutoComplete
		@private

		Updates the position of the container.
	]=]
	function AutoComplete:_updateContainerPosition(offset: number?)
		const xOffset = offset and self._entry.TextBox.AbsolutePosition.X - 10 + offset or self._entry.TextBox.AbsolutePosition.X
		const yOffset = self._entry.TextBox.AbsolutePosition.Y + 30
		autoCompleteFrame.Position = UDim2.fromOffset(xOffset, yOffset)
	end

	--[=[
		@within AutoComplete
		@private

		Sets the text of the provided object.
	]=]
	function AutoComplete:_setText(object: GuiObject, textObject: TextLabel, text: string?, sizeFromContents: boolean)
		object.Visible = text ~= nil
		textObject.Text = text or ""

		if sizeFromContents then
			const textSize = CmdrClient.Util.GetTextSize(text or "", textObject, TEXT_MEASUREMENT_SIZE)
			textObject.Size = UDim2.new(0, textSize.X, object.Size.Y.Scale, object.Size.Y.Offset)
		end
	end

	--[=[
		@within AutoComplete
		@private

		Updates the displayed auto completion info.
	]=]
	function AutoComplete:_updateInfoDisplay(options: any)
		self:_setText(self._title, self._title.Field, options.name, true)
		self:_setText(self._title.Field.Type, self._title.Field.Type, options.type and ": " .. options.type:sub(1, 1):upper() .. options.type:sub(2))
		self:_setText(self._description, self._description.Label, options.description)

		self._description.Label.TextColor3 = options.invalid and INVALID_TEXT_COLOR or VALID_TEXT_COLOR
		self._description.Size = UDim2.new(1, 0, 0, 40)

		while not self._description.Label.TextFits do
			self._description.Size = self._description.Size + UDim2.fromOffset(0, 2)

			if self._description.Size.Y.Offset > 500 then
				break
			end
		end

		task.wait()
		updateContainerSize()
		autoCompleteFrame.UIListLayout:ApplyLayout()
		autoCompleteFrame.ScrollBarThickness = defaultBarThickness
	end

	--[=[
		@within AutoComplete
		Shows the autocomplete menu.
	]=]
	function AutoComplete:Show(items: any, options: any)
		options = options or {}

		for _, item in ipairs(self.Items) do
			if item.gui then
				item.gui:Destroy()
			end
		end

		self.SelectedItem = 1
		self.Items = items

		self.Prefix = options.prefix or ""
		self.LastItem = options.isLast or false

		self.Command = options.command
		self.Arg = options.arg
		self.NumArgs = options.numArgs
		self.IsPartial = options.isPartial

		local autocompleteWidth = 200
		autoCompleteFrame.ScrollBarThickness = 0

		for index, item in ipairs(items) do
			const typedText = item[1]
			const suggestionText = item[2]
			const button = self._autoItem:Clone()
			button.Name = typedText .. suggestionText
			button.BackgroundTransparency = if index == self.SelectedItem then 0.5 else 1

			local start, stop = suggestionText:lower():find(typedText:lower(), 1, true)
			if not start then
				start = 1
				stop = #suggestionText
			end

			button.Typed.Text = string.rep(" ", start - 1) .. typedText
			button.Suggest.Text = suggestionText:sub(1, start - 1) .. string.rep(" ", #typedText) .. suggestionText:sub(stop + 1)

			button.LayoutOrder = index
			button.Parent = autoCompleteFrame

			local maxBounds = math.max(button.Typed.TextBounds.X, button.Suggest.TextBounds.X) + 20
			autocompleteWidth = math.max(autocompleteWidth, maxBounds)

			item.gui = button
		end

		autoCompleteFrame.UIListLayout:ApplyLayout()

		const text = self._entry.TextBox.Text
		local words = CmdrClient.Util.SplitString(text)
		if text:sub(#text, #text) == " " and not options.at then
			words[#words + 1] = "e"
		end

		table.remove(words, #words)

		local offset = (options.at or (#table.concat(words, " ") + 1)) * 7
		self:_updateContainerPosition(offset)
		autoCompleteFrame.Size = UDim2.fromOffset(autocompleteWidth, autoCompleteFrame.UIListLayout.AbsoluteContentSize.Y)
		autoCompleteFrame.Visible = true

		self:_updateInfoDisplay(self.Items[1] and self.Items[1].options or options)
	end

	--[=[
		@within AutoComplete
		Returns the selected autocomplete item.
	]=]
	function AutoComplete:GetSelectedItem()
		if not autoCompleteFrame.Visible then
			return nil
		end

		return self.Items[self.SelectedItem]
	end

	--[=[
		@within AutoComplete
		Hides the autocomplete menu.
	]=]
	function AutoComplete:Hide()
		autoCompleteFrame.Visible = false
	end

	--[=[
		@within AutoComplete
		Returns whether autocomplete is visible.
	]=]
	function AutoComplete:IsVisible()
		return autoCompleteFrame.Visible
	end

	--[=[
		@within AutoComplete
		Changes the current selection.
	]=]
	function AutoComplete:Select(delta: number)
		if not autoCompleteFrame.Visible then
			return
		end

		self.SelectedItem += delta

		if self.SelectedItem > #self.Items then
			self.SelectedItem = 1
		elseif self.SelectedItem < 1 then
			self.SelectedItem = #self.Items
		end

		for index, item in ipairs(self.Items) do
			item.gui.BackgroundTransparency = if index == self.SelectedItem then 0.5 else 1
		end

		const headerHeight = self._title.Size.Y.Offset + self._description.Size.Y.Offset
		const itemPosition = self.SelectedItem * self._autoItem.Size.Y.Offset
		const ySize = headerHeight + itemPosition - autoCompleteFrame.Size.Y.Offset
		autoCompleteFrame.CanvasPosition = Vector2.new(0, math.max(0, ySize))

		const selectedItem = self.Items[self.SelectedItem]
		if selectedItem and selectedItem.options then
			self:_updateInfoDisplay(selectedItem.options)
		end
	end

	AutoComplete._autoItem.Parent = nil
	autoCompleteFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateContainerSize)

	return AutoComplete
end
