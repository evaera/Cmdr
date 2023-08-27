local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Util = require(script.Parent.Util)
local Command = require(script.Parent.Command)

local HISTORY_SETTING_NAME = "CmdrCommandHistory"
local displayedBeforeRunHookWarning = false

--[=[
	@class Dispatcher

	The dispatcher handles parsing, validating, and evaluating commands.
]=]

--[=[
	@prop Cmdr Cmdr | CmdrClient
	@within Dispatcher
	@readonly
	A reference to Cmdr. This may either be the server or client version of Cmdr depending on where the code is running.
]=]

--[=[
	@prop Registry Registry
	@within Dispatcher
	@readonly
]=]

local Dispatcher = {
	Cmdr = nil,
	Registry = nil,
}

--[=[
	@within Dispatcher
	@private

	Takes in raw command information and generates a command out of it.

	@param allowIncompleteArguments -- when true, will ignore errors about arguments missing so we can parse live as the user types
	@param data -- is for special networked Data about the command gathered on the client, purely optional.

	@return (command) | (false, string) -- if unsuccessful, returns false and the error text
]=]
function Dispatcher:Evaluate(text: string, executor: Player, allowIncompleteArguments: boolean?, data: any?)
	if RunService:IsClient() == true and executor ~= Players.LocalPlayer then
		error("Can't evaluate a command that isn't sent by the local player.")
	end

	local arguments = Util.SplitString(text)
	local commandName = table.remove(arguments, 1)
	local commandObject = self.Registry:GetCommand(commandName)

	if commandObject then
		-- No need to continue splitting when there are no more arguments. We'll just mash any additional arguments into the last one.
		arguments = Util.MashExcessArguments(arguments, #commandObject.Args)

		-- Create the CommandContext and parse it.
		local command = Command.new({
			Dispatcher = self,
			Text = text,
			CommandObject = commandObject,
			Alias = commandName,
			Executor = executor,
			Arguments = arguments,
			Data = data,
		})
		local success, errorText = command:Parse(allowIncompleteArguments)

		if success then
			return command
		else
			return false, errorText
		end
	else
		return false,
			("%q is not a valid command name. Use the help command to see all available commands."):format(
				tostring(commandName)
			)
	end
end

--[=[
	@within Dispatcher

	Runs a command as the given player. Executor is optional when running on the client.

	If `options.Data` is given, it will be available on the server with CommandContext.GetData

	If `options.IsHuman` is true and this function is called on the client, then the `text` will be inserted into the window history.

	@return string -- Command output or error message
]=]
function Dispatcher:EvaluateAndRun(
	text: string,
	executor: Player?,
	options: {
		Data: any?,
		IsHuman: boolean?,
	}?
)
	executor = executor or Players.LocalPlayer
	options = options or {}

	if RunService:IsClient() and (options :: any).IsHuman then
		self:PushHistory(text)
	end

	local command, errorText = self:Evaluate(text, executor, nil, (options :: any).Data)

	if not command then
		return errorText
	end

	local ok, out = xpcall(function()
		local valid, errorText = command:Validate(true)

		if not valid then
			return errorText
		end

		return command:Run() or "Command executed."
	end, function(value)
		return debug.traceback(tostring(value))
	end)

	if not ok then
		warn(("Error occurred while evaluating command string %q\n%s"):format(text, tostring(out)))
	end

	return ok and out or "An error occurred while running this command. Check the console for more information."
end

--[=[
	@within Dispatcher
	@private
	@client

	Send text as the local user to remote server to be evaluated there.

	@param data -- is for special networked Data about the command gathered on the client, purely optional.
	@return string -- Command output or error message
]=]
function Dispatcher:Send(text: string, data: any?)
	if RunService:IsClient() == false then
		error("Dispatcher:Send can only be called from the client.")
	end

	return self.Cmdr.RemoteFunction:InvokeServer(text, {
		Data = data,
	})
end

--[=[
	@within Dispatcher
	@client
	@param ... string...
	@return string

	Invokes a command programmatically as the local player.
	Accepts a variable number of arguments, which are all joined with spaces before being run; the command should be the first argument.
	This function will raise an error if any validations occur, since it's only for hard-coded (or generated) commands.
]=]
function Dispatcher:Run(...): string
	if not Players.LocalPlayer then
		error("Dispatcher:Run can only be called from the client.")
	end

	local args = { ... }
	local text = args[1]

	for i = 2, #args do
		text = text .. " " .. tostring(args[i])
	end

	local command, errorText = self:Evaluate(text, Players.LocalPlayer)

	if not command then
		error(errorText) -- We do a full-on error here since this is code-invoked and they should know better.
	end

	local success, errorText = command:Validate(true)

	if not success then
		error(errorText)
	end

	return command:Run()
end

--[=[
	@within Dispatcher
	@private
	Runs command-specific guard methods
	@param commandContext CommandContext
	@param ... ArgumentContext...

	@return nil | string -- nil for ok, string (errorText) for cancellation
]=]
function Dispatcher:RunGuards(commandContext, ...)
	local guardMethods = commandContext.Object.Guards
	if guardMethods == nil then
		return
	end

	local typeofGuardMethods = typeof(guardMethods)
	assert(typeofGuardMethods == "table", `expected a table for Command.Guards, got {typeofGuardMethods}`)

	for _, guardMethod in pairs(guardMethods) do
		local typeofGuardMethod = typeof(guardMethod)
		assert(
			typeofGuardMethod == "function",
			`expected a function for a value in Command.Guards, got {typeofGuardMethod}`
		)

		local guardResult = guardMethod(commandContext, ...)
		if guardResult == nil then
			continue
		end

		return tostring(guardResult)
	end
	return
end

--[=[
	@within Dispatcher
	@private
	Runs hooks matching the specified HookName
	@param hookName HookType
	@param commandContext CommandContext
	@param ... ArgumentContext...

	@return nil | string -- nil for ok, string (errorText) for cancellation
]=]
function Dispatcher:RunHooks(hookName: string, commandContext, ...)
	if not self.Registry.Hooks[hookName] then
		error(("Invalid hook name: %q"):format(hookName), 2)
	end

	if
		hookName == "BeforeRun"
		and #self.Registry.Hooks[hookName] == 0
		and commandContext.Group ~= "DefaultUtil"
		and commandContext.Group ~= "UserAlias"
		and commandContext:HasImplementation()
	then
		if RunService:IsStudio() then
			if displayedBeforeRunHookWarning == false then
				commandContext:Reply(
					-- FIXME: This link will need to be updated when new docs are deployed
					(RunService:IsServer() and "<Server>" or "<Client>")
						.. " Commands will not run in-game if no BeforeRun hook is configured. Learn more: https://eryn.io/Cmdr/guide/Hooks.html",
					Color3.fromRGB(255, 228, 26)
				)
				displayedBeforeRunHookWarning = true
			end
		else
			return "Command blocked for security as no BeforeRun hook is configured."
		end
	end

	for _, hook in ipairs(self.Registry.Hooks[hookName]) do
		local value = hook.callback(commandContext, ...)

		if value ~= nil then
			return tostring(value)
		end
	end
end

--[=[
	@within Dispatcher
	@private
	@client
	Inserts the string into the window history
]=]
function Dispatcher:PushHistory(text: string)
	assert(RunService:IsClient(), "PushHistory may only be used from the client.")

	local history = self:GetHistory()

	-- Remove duplicates
	if Util.TrimString(text) == "" or text == history[#history] then
		return
	end

	history[#history + 1] = text

	TeleportService:SetTeleportSetting(HISTORY_SETTING_NAME, history)
end

--[=[
	@within Dispatcher
	@client

	Returns an array of the user's command history. Most recent commands are inserted at the end of the array.
]=]
function Dispatcher:GetHistory(): { string }
	assert(RunService:IsClient(), "GetHistory may only be used from the client.")

	return TeleportService:GetTeleportSetting(HISTORY_SETTING_NAME) or {}
end

return function(cmdr)
	Dispatcher.Cmdr = cmdr
	Dispatcher.Registry = cmdr.Registry

	return Dispatcher
end
