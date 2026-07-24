const RunService = game:GetService("RunService")

const Argument = require("./Argument")

const IS_SERVER = RunService:IsServer()
const IS_CLIENT = RunService:IsClient()

--[=[
	@class CommandContext
	Represents an individual command execution.
]=]

local Command = {}
Command.__index = Command

--[=[
	@within CommandContext
	@readonly

	@prop Dispatcher Dispatcher

	The dispatcher that created this command context.
]=]

--[=[
	@within CommandContext
	@readonly

	@prop Cmdr Cmdr | CmdrClient

	The Cmdr instance this command belongs to.
]=]

--[=[
	@within CommandContext
	@readonly

	@prop Name string

	The command name.
]=]

--[=[
	@within CommandContext
	@readonly

	@prop RawText string

	The original command text.
]=]

--[=[
	@within CommandContext
	@readonly

	@prop Object CommandDefinition

	The command definition.
]=]

--[=[
	@within CommandContext
	@readonly

	@prop Group any

	The command group.
]=]

--[=[
	@within CommandContext
	@prop State table

	Temporary state storage.
]=]

--[=[
	@within CommandContext
	@readonly

	@prop Aliases {string}

	Command aliases.
]=]

--[=[
	@within CommandContext
	@readonly

	@prop Alias string

	The alias used to invoke this command.
]=]

--[=[
	@within CommandContext
	@readonly

	@prop Description string

	The command description.
]=]

--[=[
	@within CommandContext
	@readonly

	@prop Executor Player

	The player who executed this command.
]=]

--[=[
	@within CommandContext
	@readonly

	@prop ArgumentDefinitions {ArgumentDefinition}

	The command argument definitions.
]=]

--[=[
	@within CommandContext
	@readonly

	@prop RawArguments {string}

	The raw command arguments.
]=]

--[=[
	@within CommandContext
	@readonly

	@prop Arguments {ArgumentContext}

	The parsed arguments.
]=]

--[=[
	@within CommandContext
	@prop Data any

	Command data.
]=]

--[=[
	@within CommandContext
	@readonly

	@prop Response string?

	The command response.
]=]

--[=[
	@within CommandContext
	@readonly

	@prop Guards { (CommandContext) -> string? }

	Command guards.
]=]

--[=[
	@within CommandContext
	@param options table
	@return CommandContext

	Creates a new command context.
]=]
function Command.new(options)
	local self = {
		Dispatcher = options.Dispatcher,
		Cmdr = options.Dispatcher.Cmdr,
		Name = options.CommandObject.Name,
		RawText = options.Text,
		Object = options.CommandObject,
		Group = options.CommandObject.Group,
		State = {},
		Aliases = options.CommandObject.Aliases,
		Alias = options.Alias,
		Description = options.CommandObject.Description,
		Executor = options.Executor,
		ArgumentDefinitions = options.CommandObject.Args,
		RawArguments = options.Arguments,
		Arguments = {},
		Data = options.Data,
		Response = nil,
		Guards = options.Guards,
	}

	setmetatable(self, Command)

	return self
end

--[=[
	@within CommandContext
	Parses command arguments.
]=]
function Command:Parse(allowIncompleteArguments: boolean?): (boolean, string?)
	local hadOptional = false
	for index, definition in ipairs(self.ArgumentDefinitions) do
		if type(definition) == "function" then
			definition = definition(self)

			if not definition then
				break
			end
		end

		const required = definition.Default == nil and definition.Optional ~= true
		assert(not (required and hadOptional), `[Cmdr] Command {self.Name} has required arguments after optional arguments.`)

		if not required then
			hadOptional = true
		end

		if self.RawArguments[index] == nil and required and not allowIncompleteArguments then
			return false, `Required argument #{index} {definition.Name} is missing.`
		end

		if self.RawArguments[index] or allowIncompleteArguments then
			self.Arguments[index] = Argument.new(self, definition, self.RawArguments[index] or "")
		end
	end

	return true
end

--[=[
	@within CommandContext
	@return ArgumentContext?

	Validates command arguments.
]=]
function Command:Validate(isFinal: boolean?): (boolean, string)
	self._Validated = true

	local errorText = ""
	local success = true
	for index, argument in pairs(self.Arguments) do
		const valid, message = argument:Validate(isFinal)

		if not valid then
			success = false
			errorText ..= `; #{index} {argument.Name}: {message or "error"}`
		end
	end

	return success, errorText:sub(3)
end

--[=[
	@within CommandContext
	Returns the last argument containing a value.
]=]
function Command:GetLastArgument()
	for index = #self.Arguments, 1, -1 do
		const argument = self.Arguments[index]
		if argument and argument.RawValue then
			return argument
		end
	end

	return
end

--[=[
	@within CommandContext
	Gathers parsed argument values.
]=]
function Command:GatherArgumentValues(): ({ any }, number)
	local values = {}

	for index = 1, #self.ArgumentDefinitions do
		const argument = self.Arguments[index]

		if argument then
			values[index] = argument:GetValue()
		elseif type(self.ArgumentDefinitions[index]) == "table" then
			values[index] = self.ArgumentDefinitions[index].Default
		end
	end

	return values, #self.ArgumentDefinitions
end

--[=[
	@within CommandContext
	Runs the command.
]=]
function Command:Run(): string?
	assert(self._Validated, "[Cmdr] Must validate a command before running.")

	const beforeRunHook = self.Dispatcher:RunHooks("BeforeRun", self)
	if beforeRunHook then
		return beforeRunHook
	end

	const guardResult = self.Dispatcher:RunGuards(self)
	if guardResult then
		return guardResult
	end

	if not IS_SERVER and self.Object.Data and self.Data == nil then
		const values, length = self:GatherArgumentValues()
		self.Data = self.Object.Data(self, unpack(values, 1, length))
	end

	if not IS_SERVER and self.Object.ClientRun then
		const values, length = self:GatherArgumentValues()
		self.Response = self.Object.ClientRun(self, unpack(values, 1, length))
	end

	if self.Response == nil then
		if self.Object.Run then
			const values, length = self:GatherArgumentValues()
			self.Response = self.Object.Run(self, unpack(values, 1, length))
		elseif IS_SERVER then
			if self.Object.ClientRun then
				warn(`[Cmdr] {self.Name} command fell back to the server because ClientRun returned nil, but there is no server implementation!`)
			else
				warn(`[Cmdr] {self.Name} command has no implementation!`)
			end

			self.Response = "No implementation."
		else
			self.Response = self.Dispatcher:Send(self.RawText, self.Data)
		end
	end

	const afterRunHook = self.Dispatcher:RunHooks("AfterRun", self)
	if afterRunHook then
		return afterRunHook
	end

	return self.Response
end

--[=[
	@within CommandContext
	@return ArgumentContext?

	Returns an argument by index.
]=]
function Command:GetArgument(index: number)
	return self.Arguments[index]
end

--[=[
	@within CommandContext
	@return any

	Returns command data.
]=]
function Command:GetData()
	if self.Data then
		return self.Data
	end

	if self.Object.Data and not IS_SERVER then
		self.Data = self.Object.Data(self)
	end

	return self.Data
end

--[=[
	@within CommandContext
	Sends an event to a player.
]=]
function Command:SendEvent(player: Player, event: string, ...: any)
	self.Dispatcher:SendEvent(player, event, ...)
end

--[=[
	@within CommandContext
	Broadcasts an event to all clients.
]=]
function Command:BroadcastEvent(event: string, ...: any)
	self.Dispatcher:BroadcastEvent(event, ...)
end

--[=[
	@within CommandContext
	Sends a reply to the executor.
]=]
function Command:Reply(text: string, options: any?): { any }
	return self:SendEvent(self.Executor, "AddLine", text, options)
end

--[=[
	@within CommandContext
	Returns a registry store.
]=]
function Command:GetStore(name: string)
	return self.Cmdr.Registry:GetStore(name)
end

--[=[
	@within CommandContext
	Checks if the command has an implementation.
]=]
function Command:HasImplementation(): boolean
	return ((IS_CLIENT and self.Object.ClientRun) or self.Object.Run) ~= nil
end

return Command
