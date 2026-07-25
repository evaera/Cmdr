const Util = require("./Util")

const function unescapeOperators(text: string): string
	for _, operator in ipairs({ "%.", "%?", "%*", "%*%*" }) do
		text = text:gsub("\\" .. operator, operator:gsub("%%", ""))
	end

	return text
end

--[=[
	@class ArgumentContext
	Represents an individual argument within an individual command execution.
]=]

const Argument = {}
Argument.__index = Argument

--[=[
	@within ArgumentContext
	@readonly
	@prop Command CommandContext

	The command that this argument belongs to.
]=]

--[=[
	@within ArgumentContext
	@readonly
	@prop Type TypeDefinition

	The type definition for this argument.
]=]

--[=[
	@within ArgumentContext
	@readonly
	@prop Name string

	The name of this argument, shown on the autocomplete interface.
]=]

--[=[
	@within ArgumentContext
	@readonly
	@prop Object ArgumentDefinition

	The raw argument definition.
]=]

--[=[
	@within ArgumentContext
	@readonly
	@prop Required boolean

	Whether or not this argument was required.
]=]

--[=[
	@within ArgumentContext
	@readonly
	@prop Executor Player

	The player that ran the command that this argument belongs to.
]=]

--[=[
	@within ArgumentContext
	@readonly
	@prop RawValue string

	The raw, unparsed value for this argument.
]=]

--[=[
	@within ArgumentContext
	@readonly
	@prop RawSegments {string}

	An array of strings representing the values in a comma-separated list, if applicable.
]=]

--[=[
	@within ArgumentContext
	@readonly
	@prop Prefix string

	The prefix used in this argument (like `%` in `%Team`). Empty string if no prefix was used. See [Prefixed Union Types](/docs/commands-reference/commands#prefixed-union-types) for more details.
]=]

--[=[
	@within ArgumentContext
	@private
	@prop TextSegmentInProgress any

	The text of the raw segment the user is currently typing.
]=]

--[=[
	@within ArgumentContext
	@private
	@prop RawSegmentsAreAutocomplete boolean

	Whether the raw segments were generated from autocomplete.
]=]

--[=[
	@within ArgumentContext
	@private
	@prop TransformedValues {any}

	The transformed value (generated later).
]=]

--[=[
	@within ArgumentContext
	@private

	@param command CommandContext -- The command that owns this argument
	@param argumentDefinition ArgumentDefinition -- The raw argument definition
	@param value any -- The raw, unparsed value
	@return ArgumentContext

	Returns a new ArgumentContext, an object that handles parsing and validating arguments.
]=]
function Argument.new(command: any, argumentDefinition: any, value: any)
	const self = {
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
		const parsedType, parsedRawValue, prefix = Util.ParsePrefixedUnionType(command.Cmdr.Registry:GetTypeName(argumentDefinition.Type), value)
		const existingType = command.Dispatcher.Registry:GetType(parsedType)
		assert(existingType, `[Cmdr] Argument "{self.Name or "none"}" has an unregistered type {parsedType or "<none>"}`)

		self.Type = existingType
		self.RawValue = parsedRawValue
		self.Prefix = prefix
	end

	setmetatable(self, Argument)

	self:Transform()

	return self
end

--[=[
	@within ArgumentContext
	@private

	Transforms a raw argument segment.
]=]
function Argument:TransformSegment(rawSegment: string): any
	if self.Type.Transform then
		return self.Type.Transform(rawSegment, self.Executor)
	end

	return rawSegment
end

--[=[
	@within ArgumentContext
	@private

	Returns the default autocomplete results.
]=]
function Argument:GetDefaultAutocomplete()
	if not self.Type.Autocomplete then
		return {}
	end

	const strings, options = self.Type.Autocomplete(self:TransformSegment(""))
	return strings, options or {}
end

--[=[
	@within ArgumentContext
	@private

	Calls the transform function on this argument.
	The return value(s) from this function are passed to all of the other argument methods.
	Called automatically at instantiation.
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
		const strings, options = self:GetDefaultAutocomplete()

		if not options.IsPartial and #strings > 0 then
			rawValue = strings[math.random(1, #strings)]
			self.RawSegmentsAreAutocomplete = true
		end
	end

	if self.Type.Listable and #self.RawValue > 0 then
		const randomMatch = rawValue:match("^%?(%d+)$")

		if randomMatch then
			const maxSize = tonumber(randomMatch)

			if maxSize and maxSize > 0 then
				const remainingItems, options = self:GetDefaultAutocomplete()
				const items = {}
				if not options.IsPartial and #remainingItems > 0 then
					for _ = 1, math.min(maxSize, #remainingItems) do
						table.insert(items, table.remove(remainingItems, math.random(1, #remainingItems)))
					end

					rawValue = table.concat(items, ",")
					self.RawSegmentsAreAutocomplete = true
				end
			end
		elseif rawValue == "*" or rawValue == "**" then
			const strings, options = self:GetDefaultAutocomplete()
			if not options.IsPartial and #strings > 0 then
				if rawValue == "**" and self.Type.Default then
					const defaultString = self.Type.Default(self.Executor) or ""

					for index, string in ipairs(strings) do
						if string == defaultString then
							table.remove(strings, index)
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

		for index, rawSegment in ipairs(rawSegments) do
			self.RawSegments[index] = rawSegment
			self.TransformedValues[index] = { self:TransformSegment(rawSegment) }
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
	@within ArgumentContext

	Returns the transformed value from this argument, see Types.
]=]
function Argument:GetTransformedValue(segment: number): ...any
	return unpack(self.TransformedValues[segment])
end

--[=[
	@within ArgumentContext
	@private

	Validates that the argument will work without any type errors.
]=]
function Argument:Validate(isFinal: boolean?): (boolean, string?)
	if not self.RawValue or #self.RawValue == 0 and self.Required == false then
		return true
	end

	if self.Required and (not self.RawSegments[1] or #self.RawSegments[1] == 0) then
		return false, "This argument is required."
	end

	if self.Type.Validate or self.Type.ValidateOnce then
		for index = 1, #self.TransformedValues do
			if self.Type.Validate then
				const valid, errorText = self.Type.Validate(self:GetTransformedValue(index))
				if not valid then
					return valid, errorText or "Invalid value"
				end
			end

			if isFinal and self.Type.ValidateOnce then
				const validOnce, errorTextOnce = self.Type.ValidateOnce(self:GetTransformedValue(index))
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
	@within ArgumentContext
	@private

	Gets a list of all possible values that could match based on the current value.
]=]
function Argument:GetAutocomplete()
	if not self.Type.Autocomplete then
		return {}
	end

	return self.Type.Autocomplete(self:GetTransformedValue(#self.TransformedValues))
end

--[=[
	@within ArgumentContext
	@private

	Parses a transformed argument segment.
]=]
function Argument:_parseValue(segment: number)
	if self.Type.Parse then
		return self.Type.Parse(self:GetTransformedValue(segment))
	else
		return self:GetTransformedValue(segment)
	end
end

--[=[
	@within ArgumentContext

	Returns the parsed (final) value for this argument.
]=]
function Argument:GetValue(): any
	if #self.RawValue == 0 and not self.Required and self.Object.Default ~= nil then
		return self.Object.Default
	end

	if not self.Type.Listable then
		return self:_parseValue(1)
	end

	const values = {}
	for index = 1, #self.TransformedValues do
		const parsedValue = self:_parseValue(index)
		assert(type(parsedValue) == "table", `[Cmdr] Listable types must return a table from Parse {self.Type.Name}`)

		for _, value in pairs(parsedValue) do
			values[value] = true
		end
	end

	const valueArray = {}
	for value in pairs(values) do
		valueArray[#valueArray + 1] = value
	end

	return valueArray
end

return Argument
