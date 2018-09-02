if false then while true do end end

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local Player = game.Players.LocalPlayer

local CmdrRoot = ReplicatedStorage:WaitForChild("CmdrClient")
local Cmdr = require(CmdrRoot)
local Util = require(CmdrRoot:WaitForChild("Shared"):WaitForChild("Util"))

local Window = require(script:WaitForChild("Window"))
local AutoComplete = require(script:WaitForChild("AutoComplete"))
Window.AutoComplete = AutoComplete

-- Sets the Window.ProcessEntry callbac so that we can dispatch our commands out
function Window.ProcessEntry(text)
	local text = Util.TrimString(text)

	if #text == 0 then return end

	Window:AddLine(Window:GetLabel() .. " " .. text)

	Window:AddLine(Cmdr.Dispatcher:EvaluateAndRun(text, Player))
end

-- Sets the Window.OnTextChanged callback so we can update the auto complete
function Window.OnTextChanged (text)
	local command = Cmdr.Dispatcher:Evaluate(text, Player, true)
	local arguments = Util.SplitString(text)
	local commandText = table.remove(arguments, 1)
	local atEnd = false
	if command then
		arguments = Util.MashExcessArguments(arguments, #command.Object.Args)

		atEnd = #arguments == #command.Object.Args
	end

	local entryComplete = commandText and #arguments > 0

	if text:sub(#text, #text):match("%s") and not atEnd then
		entryComplete = true
		arguments[#arguments + 1] = ""
	end

	if command and entryComplete then
		local commandValid, errorText = command:Validate()

		Window:SetIsValidInput(commandValid, ("Validation errors: %s"):format(errorText or ""))

		local acItems = {}

		local lastArgument = command:GetArgument(#arguments)
		if lastArgument then
			local items, leftChop = lastArgument:GetAutocomplete()
			for i, item in pairs(items) do
				acItems[i] = {lastArgument.RawValue, item}
			end

			local valid, errorText = true, nil

			if #lastArgument.RawValue > 0 then
				valid, errorText = lastArgument:Validate()
			end

			return AutoComplete:Show(acItems, {
				leftChop = leftChop;
				at = atEnd and #text - #lastArgument.RawValue + (text:sub(#text, #text):match("%s") and -1 or 0);
				name = lastArgument.Name;
				type = lastArgument.Object.Type;
				description = (valid == false and errorText) or lastArgument.Object.Description;
				invalid = not valid;
			})
		end
	elseif commandText then
		Window:SetIsValidInput(true)
		local exactCommand = Cmdr.Registry:GetCommand(commandText)
		local exactMatch
		if exactCommand then
			exactMatch = {exactCommand.Name, exactCommand.Name, options = {
				name = exactCommand.Name;
				description = exactCommand.Description;
			}}
		end

		local acItems = {exactMatch}
		for _, cmd in pairs(Cmdr.Registry:GetCommandsAsStrings()) do
			if commandText:lower() == cmd:lower():sub(1, #commandText) and (exactMatch == nil or exactMatch[1] ~= commandText) then
				local commandObject = Cmdr.Registry:GetCommand(cmd)
				acItems[#acItems + 1] = {commandText, cmd, options = {
					name = commandObject.Name;
					description = commandObject.Description;
				}}
			end
		end

		return AutoComplete:Show(acItems)
	end

	AutoComplete:Hide()
end

Window:UpdateLabel()
Window:UpdateWindowHeight()