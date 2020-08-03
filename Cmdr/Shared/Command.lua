local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Argument = require(script.Parent.Argument)

local IsServer = RunService:IsServer()

local Command = {}
Command.__index = Command

--- Returns a new CommandContext, an object which is created for every command validation.
-- This is also what's passed as the context to the "Run" functions in commands
function Command.new (options)
	local self = {
		Dispatcher = options.Dispatcher; -- The dispatcher that created this command context
		Cmdr = options.Dispatcher.Cmdr; -- A quick reference to Cmdr for command context
		Name = options.CommandObject.Name; -- The command name (not alias)
		RawText = options.Text; -- The raw text used to trigger this command
		Object = options.CommandObject; -- The command object (definition)
		Group = options.CommandObject.Group; -- The group this command is in
		State = {}; -- A table which will hold any custom command state information
		Aliases = options.CommandObject.Aliases;
		Alias = options.Alias; -- The command name that was used
		Description = options.CommandObject.Description;
		Executor = options.Executor; -- The player who ran the command
		ArgumentDefinitions = options.CommandObject.Args; -- The argument definitions from the command definition
		RawArguments = options.Arguments; -- Array of strings which are the unparsed values for the arguments
		Arguments = {}; -- A table which will hold ArgumentContexts for each argument
		Data = options.Data; -- A special container for any additional data the command needs to collect from the client
		Response = nil; -- Will be set at the very end when the command is run and a string is returned from the Run function.
	}

	setmetatable(self, Command)

	return self
end

--- Parses all of the command arguments into ArgumentContexts
-- Called by the command dispatcher automatically
-- allowIncompleteArguments: if true, will not throw an error for missing arguments
function Command:Parse (allowIncompleteArguments)
	local hadOptional = false
	for i, definition in ipairs(self.ArgumentDefinitions) do
		if type(definition) == "function" then
			definition = definition(self)

			if definition == nil then
				break
			end
		end

		local required = (definition.Default == nil and definition.Optional ~= true)

		if required and hadOptional then
			error(("Command %q: Required arguments cannot occur after optional arguments."):format(self.Name))
		elseif not required then
			hadOptional = true
		end

		if self.RawArguments[i] == nil and required and allowIncompleteArguments ~= true then
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
function Command:Validate (isFinal)
	self._Validated = true
	local errorText = ""
	local success = true

	for i, arg in pairs(self.Arguments) do
		local argSuccess, argErrorText = arg:Validate(isFinal)

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

	for i = 1, #self.ArgumentDefinitions do
		local arg = self.Arguments[i]
		if arg then
			values[i] = arg:GetValue()
		elseif type(self.ArgumentDefinitions[i]) == "table" then
			values[i] = self.ArgumentDefinitions[i].Default
		end
	end

	return values, #self.ArgumentDefinitions
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

	if not IsServer and self.Object.Data and self.Data == nil then
		local values, length = self:GatherArgumentValues()
		self.Data = self.Object.Data(self, unpack(values, 1, length))
	end

	if not IsServer and self.Object.ClientRun then
		local values, length = self:GatherArgumentValues()
		self.Response = self.Object.ClientRun(self, unpack(values, 1, length))
	end

	if self.Response == nil then
		if self.Object.Run then -- We can just Run it here on this machine
			local values, length = self:GatherArgumentValues()
			self.Response = self.Object.Run(self, unpack(values, 1, length))

		elseif IsServer then -- Uh oh, we're already on the server and there's no Run function.
			if self.Object.ClientRun then
				warn(self.Name, "command fell back to the server because ClientRun returned nil, but there is no server implementation! Either return a string from ClientRun, or create a server implementation for this command.")
			else
				warn(self.Name, "command has no implementation!")
			end

			self.Response = "No implementation."
		else -- We're on the client, so we send this off to the server to let the server see what it can do with it.
			self.Response = self.Dispatcher:Send(self.RawText, self.Data)
		end
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

-- Below are functions that are only meant to be used in command implementations --

--- Returns the extra data associated with this command.
-- This needs to be used instead of just context.Data for reliability when not using a remote command.
function Command:GetData ()
	if self.Data then
		return self.Data
	end

	if self.Object.Data and not IsServer then
		self.Data = self.Object.Data(self)
	end

	return self.Data
end

--- Sends an event message to a player
function Command:SendEvent(player, event, ...)
	assert(typeof(player) == "Instance", "Argument #1 must be a Player")
	assert(player:IsA("Player"), "Argument #1 must be a Player")
	assert(type(event) == "string", "Argument #2 must be a string")

	if IsServer then
		self.Dispatcher.Cmdr.RemoteEvent:FireClient(player, event, ...)
	elseif self.Dispatcher.Cmdr.Events[event] then
		assert(player == Players.LocalPlayer, "Event messages can only be sent to the local player on the client.")
		self.Dispatcher.Cmdr.Events[event](...)
	end
end

--- Sends an event message to all players
function Command:BroadcastEvent(...)
	if not IsServer then
		error("Can't broadcast event messages from the client.", 2)
	end

	self.Dispatcher.Cmdr.RemoteEvent:FireAllClients(...)
end

--- Alias of self:SendEvent(self.Executor, "AddLine", text)
function Command:Reply(...)
	return self:SendEvent(self.Executor, "AddLine", ...)
end

--- Alias of Registry:GetStore(...)
function Command:GetStore(...)
	return self.Dispatcher.Cmdr.Registry:GetStore(...)
end

--- Returns true if the command has an implementation on the caller's machine.
function Command:HasImplementation()
	return ((RunService:IsClient() and self.Object.ClientRun) or self.Object.Run) and true or false
end

return Command
