local Util = require(script.Parent.Util)

local function unescapeOperators(text)
	for _, operator in ipairs({ "%.", "%?", "%*", "%*%*" }) do
		text = text:gsub("\\" .. operator, operator:gsub("%%", ""))
	end

	return text
end

--[=[
	@class ArgumentContext
	Represents an individual argument within an individual command execution.
]=]

local Argument = {}
Argument.__index = Argument

--[=[
	@prop Command CommandContext
	The command that this argument belongs to.
	@readonly
	@within ArgumentContext
]=]

--[=[
	@prop Type TypeDefinition
	The type definition for this argument.
	@readonly
	@within ArgumentContext
]=]

--[=[
	@prop Name string
	The name of this argument, shown on the autocomplete interface.
	@readonly
	@within ArgumentContext
]=]

--[=[
	@prop Object ArgumentDefinition
	The raw argument definition.
	@readonly
	@within ArgumentContext
]=]

--[=[
	@prop Required boolean
	Whether or not this argument was required.
	@readonly
	@within ArgumentContext
]=]

--[=[
	@prop Executor Player
	The player that ran the command that this argument belongs to.
	@readonly
	@within ArgumentContext
]=]

--[=[
	@prop RawValue string
	The raw, unparsed value for this argument.
	@readonly
	@within ArgumentContext
]=]

--[=[
	@prop RawSegments {string}
	An array of strings representing the values in a comma-separated list, if applicable.
	@readonly
	@within ArgumentContext
]=]

--[=[
	@prop Prefix string
	The prefix used in this argument (like `%` in `%Team`). Empty string if no prefix was used. See [Prefixed Union Types](/docs/commands#prefixed-union-types) for more details.
	@readonly
	@within ArgumentContext
]=]

--[=[
	@prop TextSegmentInProgress any
	The text of the raw segment the user is currently typing.
	@private
	@within ArgumentContext
]=]

--[=[
	@prop RawSegmentsAreAutocomplete boolean
	@private
	@within ArgumentContext
]=]

--[=[
	@prop TransformedValues {any}
	The transformed value (generated later).
	@private
	@within ArgumentContext
]=]

--[=[
	Returns a new ArgumentContext, an object that handles parsing and validating arguments
	@private

	@param command CommandContext -- The command that owns this argument
	@param argumentDefinition ArgumentDefinition -- The raw argument definition
	@param value any -- The raw, unparsed value
	@return ArgumentContext

	@within ArgumentContext
]=]
function Argument.new(command, argumentDefinition, value)
	local self = {
		Command = command,
		Type = nil,
		Name = argumentDefinition.Name,
		Object = argumentDefinition,
		Required = argumentDefinition.Default == nil and argumentDefinition.Optional ~= true,
		Executor = command.Executor,
		RawValue = value,
		RawSegments = {},
		TransformedValues = {},
		Prefix = "",
		TextSegmentInProgress = "",
		RawSegmentsAreAutocomplete = false,
	}

	if type(argumentDefinition.Type) == "table" then
		self.Type = argumentDefinition.Type
	else
		local parsedType, parsedRawValue, prefix =
			Util.ParsePrefixedUnionType(command.Cmdr.Registry:GetTypeName(argumentDefinition.Type), value)

		self.Type = command.Dispatcher.Registry:GetType(parsedType)
		self.RawValue = parsedRawValue
		self.Prefix = prefix

		if self.Type == nil then
			error((`[Cmdr] {self.Name or "none"} has an unregistered type %q`):format(parsedType or "<none>"))
		end
	end

	setmetatable(self, Argument)

	self:Transform()

	return self
end

--[=[
	@private
	@return any
	@within ArgumentContext
]=]
function Argument:GetDefaultAutocomplete()
	if self.Type.Autocomplete then
		local strings, options = self.Type.Autocomplete(self:TransformSegment(""))
		return strings, options or {}
	end

	return {}
end

--[=[
	Calls the transform function on this argument.
	The return value(s) from this function are passed to all of the other argument methods.
	Called automatically at instantiation.

	@private
	@within ArgumentContext
]=]
function Argument:Transform()
	if #self.TransformedValues ~= 0 then
		return
	end

	local rawValue = self.RawValue
	if self.Type.ArgumentOperatorAliases then
		rawValue = self.Type.ArgumentOperatorAliases[rawValue] or rawValue
	end

	if rawValue == "." and self.Type.Default then
		rawValue = self.Type.Default(self.Executor) or ""
		self.RawSegmentsAreAutocomplete = true
	end

	if rawValue == "?" and self.Type.Autocomplete then
		local strings, options = self:GetDefaultAutocomplete()

		if not options.IsPartial and #strings > 0 then
			rawValue = strings[math.random(1, #strings)]
			self.RawSegmentsAreAutocomplete = true
		end
	end

	if self.Type.Listable and #self.RawValue > 0 then
		local randomMatch = rawValue:match("^%?(%d+)$")
		if randomMatch then
			local maxSize = tonumber(randomMatch)

			if maxSize and maxSize > 0 then
				local items = {}
				local remainingItems, options = self:GetDefaultAutocomplete()

				if not options.IsPartial and #remainingItems > 0 then
					for _ = 1, math.min(maxSize, #remainingItems) do
						table.insert(items, table.remove(remainingItems, math.random(1, #remainingItems)))
					end

					rawValue = table.concat(items, ",")
					self.RawSegmentsAreAutocomplete = true
				end
			end
		elseif rawValue == "*" or rawValue == "**" then
			local strings, options = self:GetDefaultAutocomplete()

			if not options.IsPartial and #strings > 0 then
				if rawValue == "**" and self.Type.Default then
					local defaultString = self.Type.Default(self.Executor) or ""

					for i, string in ipairs(strings) do
						if string == defaultString then
							table.remove(strings, i)
						end
					end
				end

				rawValue = table.concat(strings, ",")
				self.RawSegmentsAreAutocomplete = true
			end
		end

		rawValue = unescapeOperators(rawValue)

		local rawSegments = Util.SplitStringSimple(rawValue, ",")

		if #rawSegments == 0 then
			rawSegments = { "" }
		end

		if rawValue:sub(#rawValue, #rawValue) == "," then
			rawSegments[#rawSegments + 1] = "" -- makes auto complete tick over right after pressing ,
		end

		for i, rawSegment in ipairs(rawSegments) do
			self.RawSegments[i] = rawSegment
			self.TransformedValues[i] = { self:TransformSegment(rawSegment) }
		end

		self.TextSegmentInProgress = rawSegments[#rawSegments]
	else
		rawValue = unescapeOperators(rawValue)

		self.RawSegments[1] = unescapeOperators(rawValue)
		self.TransformedValues[1] = { self:TransformSegment(rawValue) }
		self.TextSegmentInProgress = self.RawValue
	end
end

--[=[
	@param rawSegment any
	@private
	@within ArgumentContext
]=]
function Argument:TransformSegment(rawSegment): any
	if self.Type.Transform then
		return self.Type.Transform(rawSegment, self.Executor)
	else
		return rawSegment
	end
end

--[=[
	Returns the transformed value from this argument, see Types.
	@within ArgumentContext
]=]
function Argument:GetTransformedValue(segment: number): ...any
	return unpack(self.TransformedValues[segment])
end

--[=[
	Validates that the argument will work without any type errors.

	@param isFinal any
	@private
	@within ArgumentContext
]=]
function Argument:Validate(isFinal: boolean?): (boolean, string?)
	if self.RawValue == nil or #self.RawValue == 0 and self.Required == false then
		return true
	end

	if self.Required and (self.RawSegments[1] == nil or #self.RawSegments[1] == 0) then
		return false, "This argument is required."
	end

	if self.Type.Validate or self.Type.ValidateOnce then
		for i = 1, #self.TransformedValues do
			if self.Type.Validate then
				local valid, errorText = self.Type.Validate(self:GetTransformedValue(i))

				if not valid then
					return valid, errorText or "Invalid value"
				end
			end

			if isFinal and self.Type.ValidateOnce then
				local validOnce, errorTextOnce = self.Type.ValidateOnce(self:GetTransformedValue(i))

				if not validOnce then
					return validOnce, errorTextOnce
				end
			end
		end

		return true
	else
		return true
	end
end

--[=[
	Gets a list of all possible values that could match based on the current value.

	@return any
	@private
	@within ArgumentContext
]=]
function Argument:GetAutocomplete()
	if self.Type.Autocomplete then
		return self.Type.Autocomplete(self:GetTransformedValue(#self.TransformedValues))
	else
		return {}
	end
end

--[=[
	@return any
	@private
	@within ArgumentContext
]=]
function Argument:ParseValue(i: number)
	if self.Type.Parse then
		return self.Type.Parse(self:GetTransformedValue(i))
	else
		return self:GetTransformedValue(i)
	end
end

--
--[=[
	Returns the parsed (final) value for this argument.
	@within ArgumentContext
]=]
function Argument:GetValue(): any
	if #self.RawValue == 0 and not self.Required and self.Object.Default ~= nil then
		return self.Object.Default
	end

	if not self.Type.Listable then
		return self:ParseValue(1)
	end

	local values = {}

	for i = 1, #self.TransformedValues do
		local parsedValue = self:ParseValue(i)

		if type(parsedValue) ~= "table" then
			error(`[Cmdr] Listable types must return a table from Parse {self.Type.Name}`)
		end

		for _, value in pairs(parsedValue) do
			values[value] = true -- Put them into a dictionary to ensure uniqueness
		end
	end

	local valueArray = {}

	for value in pairs(values) do
		valueArray[#valueArray + 1] = value
	end

	return valueArray
end

return Argument
