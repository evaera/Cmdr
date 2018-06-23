local Argument = {}
Argument.__index = Argument

--- Returns a new ArgumentContext, an object that handles parsing and validating arguments
function Argument.new(command, argumentObject, value)
	local self = {
		Command = command; -- The command that owns this argument
		Type = command.Dispatcher.Registry:GetType(argumentObject.type); -- The type definition
		Name = argumentObject.name; -- The name for this specific argument
		Object = argumentObject; -- The raw ArgumentObject (definition)
		Required = argumentObject.optional ~= true; -- If the argument is required or not.
		Executor = command.Executor; -- The player who is running the command
		RawValue = value; -- The raw, unparsed value
		TransformedValue = nil; -- The transformed value (generated later)
	}

	if self.Type == nil then
		error(("%s has an unregistered type %q"):format(self.Name, argumentObject.type))
	end

	setmetatable(self, Argument)

	self:Transform()

	return self
end

--- Calls the transform function on this argument.
-- The return value(s) from this function are passed to all of the other argument methods.
-- Called automatically at instantiation
function Argument:Transform()
	if self.TransformedValue ~= nil then
		return
	end

	if self.Type.transform then
		self.TransformedValue = {self.Type.transform(self.RawValue, self.Executor)}
	else
		self.TransformedValue = {self.RawValue}
	end
end

--- Returns whatever the transform method gave us.
function Argument:GetTransformedValue()
	return unpack(self.TransformedValue)
end

--- Validates that the argument will work without any type errors.
function Argument:Validate()
	if self.RawValue == nil or #self.RawValue == 0 and self.Required == false then
		return true
	end

	if self.Type.validate then
		local valid, errorText = self.Type.validate(self:GetTransformedValue())
		return valid, errorText or "Invalid value"
	else
		return true
	end
end

--- Gets a list of all possible values that could match based on the current value.
function Argument:GetAutocomplete()
	if self.Type.autocomplete then
		return self.Type.autocomplete(self:GetTransformedValue())
	else
		return {}
	end
end

--- Returns the final value of the argument.
function Argument:GetValue()
	if self.Type.parse then
		return self.Type.parse(self:GetTransformedValue())
	else
		return self:GetTransformedValue()
	end
end

return Argument
