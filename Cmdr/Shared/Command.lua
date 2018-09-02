local RunService = game:GetService("RunService")
local Argument = require(script.Parent.Argument)

local Command = {}
Command.__index = Command

--- Returns a new CommandContext, an object which is created for every command validation.
-- This is also what's passed as the context to the "Run" functions in commands
function Command.new (dispatcher, text, commandObject, executor, arguments, data)
	local self = {
		Dispatcher = dispatcher; -- The dispatcher that created this command context
		Name = commandObject.Name; -- The command name (not alias)
		RawText = text; -- The raw text used to trigger this command
		Object = commandObject; -- The command object (definition)
		Group = commandObject.Group;
		Aliases = commandObject.Aliases;
		Description = commandObject.Description;
		Executor = executor; -- The player who ran the command
		ArgumentDefinitions = commandObject.Args; -- The argument definitions from the command definition
		RawArguments = arguments; -- Array of strings which are the unparsed values for the arguments
		Arguments = {}; -- A table which will hold ArgumentContexts for each argument
		Data = data; -- A special container for any additional data the command needs to collect from the client
		Response = nil; -- Will be set at the very end when the command is run and a string is returned from the Run function.
	}

	setmetatable(self, Command)

	return self
end

--- Parses all of the command arguments into ArgumentContexts
-- Called by the command dispatcher automatically
-- allowIncompleteArguments: if true, will not throw an error for missing arguments
function Command:Parse (allowIncompleteArguments)
	for i, definition in pairs(self.ArgumentDefinitions) do
		if self.RawArguments[i] == nil and definition.Optional ~= true and allowIncompleteArguments ~= true then
			return false, ("Required argument #%d %s is missing."):format(i, definition.Name)
		elseif self.RawArguments[i] or allowIncompleteArguments then
			self.Arguments[i] = Argument.new(self, definition, self.RawArguments[i] or "")
		end
	end

	return true
end

--- Validates that all of the arguments are in a valid state.
-- This must be called before :Run() is called.
-- Returns boolean (true if ok), errorText
function Command:Validate ()
	self._Validated = true
	local errorText = ""
	local success = true

	for i, arg in pairs(self.Arguments) do
		local argSuccess, argErrorText = arg:Validate()

		if not argSuccess then
			success = false
			errorText = ("%s; #%d %s: %s"):format(errorText, i, arg.Name, argErrorText or "error")
		end
	end

	return success, errorText:sub(3)
end

--- Returns the last argument that has a value.
-- Useful for getting the autocomplete for the argument the user is working on.
function Command:GetLastArgument()
	for i = #self.Arguments, 1, -1 do
		if self.Arguments[i].RawValue then
			return self.Arguments[i]
		end
	end
end

--- Returns a table containing the parsed values for all of the arguments.
function Command:GatherArgumentValues ()
	local values = {}

	for i, arg in pairs(self.Arguments) do
		values[i] = arg:GetValue()
	end

	return values
end

--- Runs the command. Handles dispatching to the server if necessary.
-- Command:Validate() must be called before this is called or it will throw.
function Command:Run ()
	if self._Validated == nil then
		error("Must validate a command before running.")
	end

	local beforeRunHook = self.Dispatcher:RunHooks("BeforeRun", self)
	if beforeRunHook then
		return beforeRunHook
	end

	if self.Object.Run then -- We can just Run it here on this machine
		self.Response = self.Object.Run(self, self.Executor, unpack(self:GatherArgumentValues()))
	elseif RunService:IsServer() == true then -- Uh oh, we're already on the server and there's no Run function.
		warn(self.Name, "command has no implementation!")
		self.Response = "No implementation."
	else -- We're on the client, so we send this off to the server to let the server see what it can do with it.
		self.Response = self.Dispatcher:Send(self.RawText, self.Object.Data and self.Object.Data(self))
	end

	local afterRunHook = self.Dispatcher:RunHooks("AfterRun", self)
	if afterRunHook then
		return afterRunHook
	else
		return self.Response
	end
end

--- Returns an ArgumentContext for the specific index
function Command:GetArgument (index)
	return self.Arguments[index]
end

--- Returns the extra data associated with this command.
-- This needs to be used instead of just context.Data for reliability when not using a remote command.
function Command:GetData ()
	if self.Data then
		return self.Data
	end

	if self.Object.Data then
		self.Data = self.Object.Data(self)
	end

	return self.Data
end

return Command