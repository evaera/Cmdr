local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Util = require(script.Parent.Util)
local Command = require(script.Parent.Command)

local HISTORY_SETTING_NAME = "CmdrCommandHistory"
local displayedBeforeRunHookWarning = false

--- The dispatcher handles creating and running commands during the game.
local Dispatcher = {
	Cmdr = nil;
	Registry = nil;
}

--- Takes in raw command information and generates a command out of it.
-- text and executor are required arguments.
-- allowIncompleteData, when true, will ignore errors about arguments missing so we can parse live as the user types.
-- data is for special networked Data about the command gathered on the client. Purely Optional.
-- returns the command if successful, or (false, errorText) if not
function Dispatcher:Evaluate (text, executor, allowIncompleteArguments, data)
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
			Data = data
		})
		local success, errorText = command:Parse(allowIncompleteArguments)

		if success then
			return command
		else
			return false, errorText
		end
	else
		return false, ("%q is not a valid command name. Use the help command to see all available commands."):format(tostring(commandName))
	end
end

--- A helper that evaluates and runs the command in one go.
-- Either returns any validation errors as a string, or the output of the command as a string. Definitely a string, though.
function Dispatcher:EvaluateAndRun (text, executor, options)
	executor = executor or Players.LocalPlayer
	options = options or {}

	if RunService:IsClient() and options.IsHuman then
		self:PushHistory(text)
	end

	local command, errorText = self:Evaluate(text, executor, nil, options.Data)

	if not command then
		return errorText
	end

	local ok, out = xpcall(function()
		local valid, errorText = command:Validate(true) -- luacheck: ignore

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

--- Send text as the local user to remote server to be evaluated there.
function Dispatcher:Send (text, data)
	if RunService:IsClient() == false then
		error("Dispatcher:Send can only be called from the client.")
	end

	return self.Cmdr.RemoteFunction:InvokeServer(text, {
		Data = data
	})
end

--- Invoke a command programmatically as the local user e.g. from a settings menu
-- Command should be the first argument, all arguments afterwards should be the arguments to the command.
function Dispatcher:Run (...)
	if not Players.LocalPlayer then
		error("Dispatcher:Run can only be called from the client.")
	end

	local args = {...}
	local text = args[1]

	for i = 2, #args do
		text = text .. " " .. tostring(args[i])
	end

	local command, errorText = self:Evaluate(text, Players.LocalPlayer)

	if not command then
		error(errorText) -- We do a full-on error here since this is code-invoked and they should know better.
	end

	local success, errorText = command:Validate(true) -- luacheck: ignore

	if not success then
		error(errorText)
	end

	return command:Run()
end

--- Runs hooks matching name and returns nil for ok or a string for cancellation
function Dispatcher:RunHooks(hookName, commandContext, ...)
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
				commandContext:Reply((RunService:IsServer() and "<Server>" or "<Client>") .. " Commands will not run in-game if no BeforeRun hook is configured. Learn more: https://eryn.io/Cmdr/guide/Hooks.html", Color3.fromRGB(255,228,26))
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

function Dispatcher:PushHistory(text)
	assert(RunService:IsClient(), "PushHistory may only be used from the client.")

	local history = self:GetHistory()

	-- Remove duplicates
	if Util.TrimString(text) == "" or text == history[#history] then
		return
	end

	history[#history + 1] = text

	TeleportService:SetTeleportSetting(HISTORY_SETTING_NAME, history)
end

function Dispatcher:GetHistory()
	assert(RunService:IsClient(), "GetHistory may only be used from the client.")

	return TeleportService:GetTeleportSetting(HISTORY_SETTING_NAME) or {}
end

return function (cmdr)
	Dispatcher.Cmdr = cmdr
	Dispatcher.Registry = cmdr.Registry

	return Dispatcher
end