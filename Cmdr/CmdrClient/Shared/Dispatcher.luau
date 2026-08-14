const Players = game:GetService("Players")
const RunService = game:GetService("RunService")
const TeleportService = game:GetService("TeleportService")

const Command = require("./Command")
const Util = require("./Util")

const IS_SERVER = RunService:IsServer()
const IS_CLIENT = RunService:IsClient()
const IS_STUDIO = RunService:IsStudio()

const WARNING_COLOR = Color3.fromRGB(255, 228, 26)
const HISTORY_SETTING_NAME = "CMDR_COMMAND_HISTORY"

const Player = Players.LocalPlayer

local hasDisplayedBeforeRunHookWarning = false

--[=[
	@class Dispatcher
	The dispatcher handles parsing, validating, and evaluating commands.
]=]

--[=[
	@within Dispatcher
	@readonly

	@prop Cmdr Cmdr | CmdrClient

	A reference to Cmdr. This may either be the server or client version of Cmdr depending on where the code is running.
]=]

--[=[
	@within Dispatcher
	@readonly

	@prop Registry Registry

	Refers to the command Registry.

]=]

const Dispatcher = {
	Cmdr = nil :: any,
	Registry = nil :: any,
}

--[=[
	@within Dispatcher
	@private

	@param allowIncompleteArguments -- When true, will ignore errors about arguments missing so we can parse live as the user types
	@param data -- Used for special networked Data about the command gathered on the client, purely optional.

	@return (CommandContext) | (false, string) -- If unsuccessful, returns false and the error text

	Takes in raw command information and generates a command out of it.
]=]
function Dispatcher:Evaluate(
	text: string,
	executor: Player,
	allowIncompleteArguments: boolean?,
	data: any?
): (typeof(Command.new()) | false, string?)
	assert(
		IS_SERVER or IS_CLIENT and executor == Players.LocalPlayer,
		"[Cmdr] Can't evaluate a command that isn't sent by the local player."
	)
	if typeof(text) ~= "string" or Util.TrimString(text) == "" then
		return false, "Command cannot be empty."
	end

	local arguments = Util.SplitString(text)
	const commandName = table.remove(arguments, 1)
	const commandObject = self.Registry:GetCommand(commandName)
	if not commandObject then
		return false,
			`{tostring(commandName)} is not a valid command name. Use the help command to see all available commands.`
	end

	arguments = Util.MashExcessArguments(arguments, #commandObject.Args)

	const commandContext = Command.new({
		Dispatcher = self,
		Text = text,
		CommandObject = commandObject,
		Alias = commandName,
		Executor = executor,
		Arguments = arguments,
		Data = data,
	})

	const success, errorText = commandContext:Parse(allowIncompleteArguments)
	if not success then
		return false, errorText
	end

	return commandContext
end

--[=[
	@within Dispatcher

	Runs a command as the given player. Executor is optional when running on the client.
	If `options.Data` is given, it will be available on the server with CommandContext.GetData
	If `options.IsHuman` is true and this function is called on the client, then the `text` will be inserted into the window history.
]=]
function Dispatcher:EvaluateAndRun(
	text: string,
	executor: Player?,
	options: {
		Data: any?,
		IsHuman: boolean?,
	}?
): string
	executor = executor or Players.LocalPlayer
	options = options or {}

	if IS_CLIENT and (options :: any).IsHuman then
		self:_pushHistory(text)
	end

	const commandContext, errorText = self:Evaluate(text, executor, nil, (options :: any).Data)
	if not commandContext then
		return errorText
	end

	const success, result = xpcall(function()
		const isValid, validationError = commandContext:Validate(true)

		if not isValid then
			return validationError
		end

		return commandContext:Run() or "Command executed."
	end, function(err)
		return debug.traceback(tostring(err))
	end)

	if not success then
		warn(`[Cmdr] Error occurred while evaluating command string {("%q"):format(text)}\n{result}`)
		return "An error occurred while running this command. Check the console for more information."
	end

	return result
end

--[=[
	@within Dispatcher
	@private
	@client

	Send text as the local user to remote server to be evaluated there.
]=]
function Dispatcher:Send(text: string, data: any?): string
	assert(IS_CLIENT, "[Cmdr] [Dispatcher::Send] can only be called from the client.")
	return self.Cmdr._remoteFunction:InvokeServer(text, { Data = data })
end

--[=[
	@within Dispatcher
	Sends an event to a player.
]=]
function Dispatcher:SendEvent(player: Player, event: string, ...: any)
	assert(typeof(player) == "Instance" and player:IsA("Player"), "[Cmdr] Argument #1 must be a Player")
	assert(typeof(event) == "string", "[Cmdr] Argument #2 must be a string")

	if IS_SERVER then
		self.Cmdr._remoteEvent:FireClient(player, event, ...)
	elseif self.Cmdr._events[event] then
		assert(
			player == Players.LocalPlayer,
			"[Cmdr] Event messages can only be sent to the local player on the client."
		)
		self.Cmdr._events[event](...)
	end
end

--[=[
	@within Dispatcher
	Broadcasts an event to all clients.
]=]
function Dispatcher:BroadcastEvent(event: string, ...: any)
	assert(IS_SERVER, "[Cmdr] Can't broadcast event messages from the client.")
	assert(typeof(event) == "string", "[Cmdr] Argument #1 must be a string")
	self.Cmdr._remoteEvent:FireAllClients(event, ...)
end

--[=[
	@within Dispatcher
	@client

	Invokes a command programmatically as the local player.
	Accepts a variable number of arguments, which are all joined with spaces before being run; the command should be the first argument.
	This function will raise an error if any validations occur, since it's only for hard-coded (or generated) commands.
]=]
function Dispatcher:Run(...: any): string
	assert(IS_CLIENT, "[Cmdr] [Dispatcher::Run] can only be called from the client.")

	const arguments = { ... }
	local text = tostring(arguments[1])
	for index = 2, #arguments do
		text ..= ` {arguments[index]}`
	end

	const commandContext, errorText = self:Evaluate(text, Players.LocalPlayer)
	assert(commandContext, errorText)

	const valid, validationError = commandContext:Validate(true)
	assert(valid, validationError)

	return commandContext:Run()
end

--[=[
	@within Dispatcher
	@private

	@param commandContext CommandContext
	@param ... ArgumentContext...

	Runs command-specific guard methods.
]=]
function Dispatcher:RunGuards(commandContext: any, ...: any): string?
	const guardMethods = commandContext.Object.Guards
	if not guardMethods then
		return nil
	end

	const guardMethodsType = typeof(guardMethods)
	assert(guardMethodsType == "table", `expected a table for Command.Guards, got {guardMethodsType}`)

	for _, guardMethod in ipairs(guardMethods) do
		const guardMethodType = typeof(guardMethod)
		assert(
			guardMethodType == "function",
			`expected a function for a value in Command.Guards, got {guardMethodType}`
		)

		const result = guardMethod(commandContext, ...)
		if result ~= nil then
			return tostring(result)
		end
	end

	return nil
end

--[=[
	@within Dispatcher
	@private

	@param hookName HookType
	@param commandContext CommandContext

	@return string? -- nil for success, string for cancellation.

	Runs hooks matching the specified hook name.
]=]
function Dispatcher:RunHooks(hookName: string, commandContext: any, passExactValue: boolean?): string?
	const hooks = self.Registry._hooks[hookName]
	assert(hooks, `[Cmdr] Invalid hook name: {hookName}`)
	assert(
		not (IS_SERVER and hookName == "BeforeCommandRegister"),
		"[Cmdr] The BeforeCommandRegister hook can only be run by the client."
	)

	if
		hookName == "BeforeRun"
		and #hooks == 0
		and commandContext.Group ~= "DefaultUtil"
		and commandContext.Group ~= "UserAlias"
		and commandContext:HasImplementation()
	then
		if not IS_STUDIO then
			return "Command blocked for security as no BeforeRun hook is configured."
		end

		if not hasDisplayedBeforeRunHookWarning then
			const environment = if IS_SERVER then "<Server>" else "<Client>"
			commandContext:Reply(
				`{environment} Commands will not run in-game if no BeforeRun hook is configured. Learn more: https://eryn.io/Cmdr/docs/reference/hooks`,
				WARNING_COLOR
			)
			hasDisplayedBeforeRunHookWarning = true
		end
	end

	for _, hook in ipairs(hooks) do
		const result = hook.callback(commandContext)
		if result ~= nil then
			return if passExactValue == true then result else tostring(result)
		end
	end

	return nil
end

--[=[
	@within Dispatcher
	@private
	@client

	@param commandObject CommandDefinition

	@return string? -- nil for success, string for cancellation.

	Runs all BeforeCommandRegister Hooks on the specified CommandDefinition.
]=]
function Dispatcher:_runBeforeCommandRegisterHookForCommand(commandObject: any): string?
	assert(
		IS_CLIENT,
		"[Cmdr] [Dispatcher::_runBeforeCommandRegisterHookForCommand] can only be called from the client."
	)

	const commandName = commandObject.Name:lower()
	const commandContext = Command.new({
		Dispatcher = self,
		Text = nil,
		CommandObject = commandObject,
		Alias = commandName,
		Executor = Player,
		Arguments = {},
		Data = nil,
	})

	const result = self:RunHooks("BeforeCommandRegister", commandContext, true)
	assert(not result, "[Cmdr] BeforeCommandRegister hook must return nil or false.")
	return result
end

--[=[
	@within Dispatcher
	@param player Player? -- The player to run the hook for. This argument is required when the method is called from the server, and must be `nil`` on the client.

	Runs all BeforeCommandRegister Hooks on the client.
]=]
function Dispatcher:RunBeforeCommandRegisterHooks(player: Player?)
	assert(
		IS_CLIENT or IS_SERVER and typeof(player) == "Instance" and player:IsA("Player"),
		"[Cmdr] Argument #1 must be a Player when called on the Server."
	)
	assert(IS_CLIENT and player == nil, "[Cmdr] Argument #1 must be omitted when calling on the Client.")
	if IS_SERVER and player then
		self:SendEvent(player, "RunBeforeCommandRegisterHooks")
		return
	end

	for _, commandObject: any in pairs(self.Registry:GetCommands()) do
		const beforeCommandRegisterHook = self:_runBeforeCommandRegisterHookForCommand(commandObject)
		commandObject._isHidden = beforeCommandRegisterHook ~= nil and beforeCommandRegisterHook ~= true
	end
end

--[=[
	@within Dispatcher
	@client

	Returns an array of the user's command history. Most recent commands are inserted at the end of the array.
]=]
function Dispatcher:GetHistory(): { string }
	assert(IS_CLIENT, "[Cmdr] [Dispatcher::GetHistory] may only be used from the client.")
	return TeleportService:GetTeleportSetting(HISTORY_SETTING_NAME) or {}
end

--[=[
	@within Dispatcher
	@private
	@client

	Inserts the string into the window history
]=]
function Dispatcher:_pushHistory(text: string)
	assert(IS_CLIENT, "[Cmdr] [Dispatcher::PushHistory] may only be used from the client.")

	const history = self:GetHistory()
	if Util.TrimString(text) == "" or text == history[#history] then
		return
	end

	history[#history + 1] = text
	TeleportService:SetTeleportSetting(HISTORY_SETTING_NAME, history)
end

-- Export Dispatcher
Dispatcher.__index = Dispatcher
Dispatcher.__newindex = Dispatcher

export type Dispatcher = typeof(setmetatable(Dispatcher, Dispatcher))

return function(Cmdr): Dispatcher
	const ProtectedDispatcher = { Cmdr = Cmdr, Registry = Cmdr.Registry }
	return setmetatable(ProtectedDispatcher, {
		__index = function(_, key)
			if Util._deprecationWarnings[key] then
				Util:_emitDeprecationWarning(key)
			end

			const value = Dispatcher[key]
			assert(value, `[Cmdr] Dispatcher has no method or property "{key}".`)
			return value
		end,
		__newindex = function(_, key)
			error(`[Cmdr] Cannot assign key "{key}"; the Dispatcher is read-only.`)
		end,
	}) :: Dispatcher
end
