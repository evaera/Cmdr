local Util = require(script.Parent.Util)

local Argument = {}
Argument.__index = Argument

--- Returns a new ArgumentContext, an object that handles parsing and validating arguments
function Argument.new (command, argumentObject, value)
	local self = {
		Command = command; -- The command that owns this argument
		Type = nil; -- The type definition
		Name = argumentObject.Name; -- The name for this specific argument
		Object = argumentObject; -- The raw ArgumentObject (definition)
		Required = argumentObject.Default == nil and argumentObject.Optional ~= true; -- If the argument is required or not.
		Executor = command.Executor; -- The player who is running the command
		RawValue = value; -- The raw, unparsed value
		RawSegments = {}; -- The raw, unparsed segments (if the raw value was comma-sep)
		TransformedValues = {}; -- The transformed value (generated later)
		Prefix = ""; -- The prefix for this command (%Team)
	}

	if type(argumentObject.Type) == "table" then
		self.Type = argumentObject.Type
	else
		local parsedType, parsedRawValue, prefix = Util.ParsePrefixedUnionType(
			command.Cmdr.Registry:GetTypeName(argumentObject.Type),
			value
		)

		self.Type = command.Dispatcher.Registry:GetType(parsedType)
		self.RawValue = parsedRawValue
		self.Prefix = prefix

		if self.Type == nil then
			error(string.format("%s has an unregistered type %q", self.Name or "<none>", parsedType or "<none>"))
		end
	end

	setmetatable(self, Argument)

	self:Transform()

	return self
end

--- Calls the transform function on this argument.
-- The return value(s) from this function are passed to all of the other argument methods.
-- Called automatically at instantiation
function Argument:Transform()
	if #self.TransformedValues ~= 0 then
		return
	end

	if self.Type.Listable and #self.RawValue > 0 then
		local rawSegments = Util.SplitStringSimple(self.RawValue, ",")

		if self.RawValue:sub(#self.RawValue, #self.RawValue) == "," then
			rawSegments[#rawSegments + 1] = "" -- makes auto complete tick over right after pressing ,
		end

		for i, rawSegment in ipairs(rawSegments) do
			self.RawSegments[i] = rawSegment
			self.TransformedValues[i] = { self:TransformSegment(rawSegment) }
		end
	else
		self.RawSegments[1] = self.RawValue
		self.TransformedValues[1] = { self:TransformSegment(self.RawValue) }
	end
end

function Argument:TransformSegment(rawSegment)
	if self.Type.Transform then
		return self.Type.Transform(rawSegment, self.Executor)
	else
		return rawSegment
	end
end

--- Returns whatever the Transform method gave us.
function Argument:GetTransformedValue(segment)
	return unpack(self.TransformedValues[segment])
end

--- Validates that the argument will work without any type errors.
function Argument:Validate(isFinal)
	if self.RawValue == nil or #self.RawValue == 0 and self.Required == false then
		return true
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

--- Gets a list of all possible values that could match based on the current value.
function Argument:GetAutocomplete()
	if self.Type.Autocomplete then
		return self.Type.Autocomplete(self:GetTransformedValue(#self.TransformedValues))
	else
		return {}
	end
end

function Argument:ParseValue(i)
	if self.Type.Parse then
		return self.Type.Parse(self:GetTransformedValue(i))
	else
		return self:GetTransformedValue(i)
	end
end

--- Returns the final value of the argument.
function Argument:GetValue()
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
			error(("Listable types must return a table from Parse (%s)"):format(self.Type.Name))
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