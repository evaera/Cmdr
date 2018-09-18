local TYPE_DEFAULTS = {
	-- Make all `players` types also be able to match by team
	players = "players % teamPlayers";
}

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
		Required = argumentObject.Optional ~= true; -- If the argument is required or not.
		Executor = command.Executor; -- The player who is running the command
		RawValue = nil; -- The raw, unparsed value
		TransformedValue = nil; -- The transformed value (generated later)
		Prefix = nil; -- The prefix for this command (%Team)
	}

	local parsedType, parsedRawValue, prefix = Util.ParsePrefixedUnionType(
		TYPE_DEFAULTS[argumentObject.Type] or argumentObject.Type, value
	)

	self.Type = command.Dispatcher.Registry:GetType(parsedType)
	self.RawValue = parsedRawValue
	self.Prefix = prefix

	if self.Type == nil then
		error(string.format("%s has an unregistered type %q", self.Name or "<none>", parsedType or "<none>"))
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

	if self.Type.Transform then
		self.TransformedValue = {self.Type.Transform(self.RawValue, self.Executor)}
	else
		self.TransformedValue = {self.RawValue}
	end
end

--- Returns whatever the Transform method gave us.
function Argument:GetTransformedValue ()
	return unpack(self.TransformedValue)
end

--- Validates that the argument will work without any type errors.
function Argument:Validate ()
	if self.RawValue == nil or #self.RawValue == 0 and self.Required == false then
		return true
	end

	if self.Type.Validate then
		local valid, errorText = self.Type.Validate(self:GetTransformedValue())
		return valid, errorText or "Invalid value"
	else
		return true
	end
end

--- Gets a list of all possible values that could match based on the current value.
function Argument:GetAutocomplete ()
	if self.Type.Autocomplete then
		return self.Type.Autocomplete(self:GetTransformedValue())
	else
		return {}
	end
end

--- Returns the final value of the argument.
function Argument:GetValue ()
	if self.Type.Parse then
		return self.Type.Parse(self:GetTransformedValue())
	else
		return self:GetTransformedValue()
	end
end

return Argument