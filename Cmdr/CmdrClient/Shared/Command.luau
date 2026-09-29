const RunService = game:GetService("RunService")

const Argument = require("./Argument")
const Util = require("./Util")

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
	const self = {
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
		assert(
			not (required and hadOptional),
			`[Cmdr] Command {self.Name} has required arguments after optional arguments.`
		)

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
	const values = {}

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

const function settle(value: any): (Util.PromiseStatus, any)
	if not Util.IsPromise(value) then
		return "Resolved", value
	end

	return Util.AwaitPromise(value)
end

const function failureText(status: Util.PromiseStatus, value: any): string
	if status == "Cancelled" then
		return "Command cancelled."
	end

	return if value == nil then "Command failed." else tostring(value)
end

const function isExecutionError(value: any): boolean
	return type(value) == "table" and (value :: any).kind == "ExecutionError" and type((value :: any).trace) == "string"
end

--[=[
	@within CommandContext
	@private

	@return (string, Color3?) -- The response, followed by the color the console should display it in.

	Reports an implementation whose promise didn't resolve.
]=]
function Command:_failureResponse(status: Util.PromiseStatus, value: any): (string, Color3?)
	if status == "Cancelled" then
		return failureText(status, value)
	end

	if isExecutionError(value) then
		warn(`[Cmdr] Error occurred while running the {self.Name} command\n{tostring(value)}`)
		return "An error occurred while running this command. Check the console for more information.", Util.ErrorColor
	end

	const response = failureText(status, value)
	warn(`[Cmdr] Error occurred while running the {self.Name} command\n{response}`)

	return response, Util.ErrorColor
end

--[=[
	@within CommandContext
	@private

	@param value -- The value an implementation returned, which may or may not be a promise.
	@param andThen -- The rest of the command.

	@return (Response, Color3?) -- The response, followed by the color the console should display it in.

	Continues the command once the given value has settled.
]=]
function Command:_settle(
	value: any,
	andThen: (Util.PromiseStatus, any) -> (Util.Response, Color3?)
): (Util.Response, Color3?)
	if not Util.IsPromise(value) then
		return andThen("Resolved", value)
	end

	if not self._output then
		return andThen(settle(value))
	end

	task.spawn(function()
		const success, response, responseColor = xpcall(function()
			const result, resultColor = andThen(Util.AwaitPromise(value))

			if result == Util.Pending then
				return Util.Pending
			end

			return self:_finish(result :: string?, resultColor)
		end, function(err)
			return debug.traceback(tostring(err))
		end)

		if not success then
			warn(`[Cmdr] Error occurred while running the {self.Name} command\n{response}`)
			self._output(
				"An error occurred while running this command. Check the console for more information.",
				Util.ErrorColor
			)
			return
		end

		if response == Util.Pending then
			return
		end

		self._output(response, responseColor)
	end)

	return Util.Pending
end

--[=[
	@within CommandContext
	@private

	@return (Response, Color3?) -- The response, followed by the color the console should display it in.

	Gathers data, then runs the implementation.
]=]
function Command:_runImplementation(): (Util.Response, Color3?)
	if not IS_SERVER and self.Object.Data and self.Data == nil then
		const values, length = self:GatherArgumentValues()

		return self:_settle(self.Object.Data(self, unpack(values, 1, length)), function(status, data)
			if status ~= "Resolved" then
				return self:_failureResponse(status, data)
			end

			self.Data = data

			return self:_runClientImplementation()
		end)
	end

	return self:_runClientImplementation()
end

--[=[
	@within CommandContext
	@private

	@return (Response, Color3?) -- The response, followed by the color the console should display it in.

	Runs the client implementation, falling back to the server one.
]=]
function Command:_runClientImplementation(): (Util.Response, Color3?)
	if IS_SERVER or not self.Object.ClientRun then
		return self:_runServerImplementation()
	end

	const values, length = self:GatherArgumentValues()

	return self:_settle(self.Object.ClientRun(self, unpack(values, 1, length)), function(status, response)
		if status ~= "Resolved" then
			return self:_failureResponse(status, response)
		end

		if response ~= nil then
			return response
		end

		return self:_runServerImplementation()
	end)
end

--[=[
	@within CommandContext
	@private

	@return (Response, Color3?) -- The response, followed by the color the console should display it in.

	Runs the server implementation.
]=]
function Command:_runServerImplementation(): (Util.Response, Color3?)
	if self.Object.Run then
		const values, length = self:GatherArgumentValues()

		return self:_settle(self.Object.Run(self, unpack(values, 1, length)), function(status, response)
			if status ~= "Resolved" then
				return self:_failureResponse(status, response)
			end

			return response
		end)
	end

	if IS_SERVER then
		if self.Object.ClientRun then
			warn(
				`[Cmdr] {self.Name} command fell back to the server because ClientRun returned nil, but there is no server implementation.`
			)
		else
			warn(`[Cmdr] {self.Name} command has no implementation!`)
		end

		return "No implementation."
	end

	return self.Dispatcher:Send(self.RawText, self.Data, self._output ~= nil)
end

--[=[
	@within CommandContext
	@private

	@return (string?, Color3?) -- The response, followed by the color the console should display it in.

	Records the response and runs the AfterRun hooks.
]=]
function Command:_finish(response: string?, responseColor: Color3?): (string?, Color3?)
	self.Response = response

	const afterRunHook = self.Dispatcher:RunHooks("AfterRun", self)
	if afterRunHook then
		return afterRunHook, responseColor
	end

	return self.Response, responseColor
end

--[=[
	@within CommandContext
	@return (string? | Pending, Color3?) -- The response, followed by the color the console should display it in. [Util.Pending] means the response will be given to the command's output callback instead.

	Runs the command.
]=]
function Command:Run(): (Util.Response, Color3?)
	assert(self._Validated, "[Cmdr] CommandContext must be validated before running.")

	const beforeRunHook = self.Dispatcher:RunHooks("BeforeRun", self)
	if beforeRunHook then
		return beforeRunHook, Util.ErrorColor
	end

	const guardResult = self.Dispatcher:RunGuards(self)
	if guardResult then
		return guardResult, Util.ErrorColor
	end

	const response, responseColor = self:_runImplementation()
	if response == Util.Pending then
		return Util.Pending
	end

	return self:_finish(response :: string?, responseColor)
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
		const status, data = settle(self.Object.Data(self))

		if status ~= "Resolved" then
			error(failureText(status, data), 0)
		end

		self.Data = data
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
