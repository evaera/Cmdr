const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")

const IS_SERVER_CONTAINER = script:FindFirstAncestorWhichIsA("ServerScriptService")
	or script:FindFirstAncestorWhichIsA("ServerStorage")
const IS_SERVER = RunService:IsServer()

if not IS_SERVER_CONTAINER then
	warn(
		"[Cmdr] The package should be kept within a server-side location. Future versions of Cmdr will require the server library be kept within ServerScriptService or ServerStorage."
	)
end

assert(
	IS_SERVER,
	"[Cmdr] The Cmdr server library cannot be required by the client. Please require the client libary instead."
)

const Dispatcher = require("@self/CmdrClient/Shared/Dispatcher")
const Registry = require("@self/CmdrClient/Shared/Registry")
const Util = require("@self/CmdrClient/Shared/Util")

const function createObject(className: string, name: string, parent: Instance): Instance
	const object = Instance.new(className)
	object.Name = name
	object.Parent = parent

	return object
end

--[=[
	@class Cmdr
	@server

	The Cmdr server singleton and entry point.
]=]

--[=[
	@within Cmdr
	@readonly

	@prop Registry Registry

	Refers to the command Registry.
]=]

--[=[
	@within Cmdr
	@readonly

	@prop Dispatcher Dispatcher

	Refers to the command Dispatcher.
]=]

--[=[
	@within Cmdr
	@readonly

	@prop Util Util

	Refers to a table containing many useful utility functions.
]=]

--[=[
	@within Cmdr
	@readonly
	@private

	@prop _remoteEvent RemoteEvent

	Refers to the CmdrEvent RemoteEvent found within CmdrClient.
]=]

--[=[
	@within Cmdr
	@readonly
	@private

	@prop _remoteFunction RemoteFunction

	Refers to the CmdrFunction RemoteFunction found within CmdrClient.
]=]

--[=[
	@within Cmdr
	@readonly
	@private

	@prop _replicatedRoot ModuleScript
	
	Refers to the CmdrClient modulescript containing all shared functionality.
]=]

--[=[
	@within Cmdr
	@readonly
	@private

	@prop _defaultCommandsFolder Folder

	Refers to the BuiltInCommands folder containing all default commands.
]=]

--[=[
	@within Cmdr
	@readonly
	@private

	@prop _defaultTypesFolder Folder

	Refers to the BuiltInTypes folder containing all default types.
]=]

const Cmdr = {
	Registry = nil :: Registry.Registry?,
	Dispatcher = nil :: any,
	Util = Util,

	_remoteEvent = nil :: RemoteEvent?,
	_remoteFunction = nil :: RemoteFunction?,

	_replicatedRoot = nil :: ModuleScript?,
	_defaultCommandsFolder = script.BuiltInCommands,
	_defaultTypesFolder = script.BuiltInTypes,
}

-- Initialize Cmdr
const function initialize()
	Cmdr.Registry = Registry(Cmdr)
	Cmdr.Dispatcher = Dispatcher(Cmdr)

	createObject("Folder", "Commands", script.CmdrClient)
	createObject("Folder", "Types", script.CmdrClient)

	Cmdr._replicatedRoot = script.CmdrClient
	Cmdr._replicatedRoot.Parent = ReplicatedStorage

	Cmdr._remoteEvent = createObject("RemoteEvent", "CmdrEvent", Cmdr._replicatedRoot)
	Cmdr._remoteFunction = createObject("RemoteFunction", "CmdrFunction", Cmdr._replicatedRoot)

	Cmdr._remoteFunction.OnServerInvoke = function(player: Player, text: string, options: any)
		if #text > 10000 then
			return "Input too long"
		end

		return Cmdr.Dispatcher:EvaluateAndRun(text, player, options)
	end

	Cmdr.Registry:RegisterTypesIn(Cmdr._defaultTypesFolder)

	script.BuiltInTypes:Destroy()
	script.BuiltInCommands.Name = "Server commands"
end

initialize()

-- Export Cmdr
return setmetatable(Cmdr, {
	__index = function(self, key)
		const registry = rawget(self, "Registry")
		const value = registry and registry[key]
		assert(value, `[Cmdr] Registry has no method or property "{key}".`)

		if type(value) == "function" then
			if not self._replicatedRoot:GetAttribute("HasShownProxyCallWarning") then
				warn(
					debug.traceback(
						`[Cmdr] [APIUsage::ProxyCalls] Method calls should be performed by their respective modules rather than the Cmdr object.`,
						2
					)
				)
				self._replicatedRoot:SetAttribute("HasShownProxyCallWarning", true)
			end

			return function(_, ...)
				return value(registry, ...)
			end
		end

		return nil
	end,
	__newindex = function(_, key)
		error(`[Cmdr] Cannot assign key "{key}"; the Cmdr singleton is read-only.`)
	end,
})
