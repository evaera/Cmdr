const RunService = game:GetService("RunService")

const IS_CLIENT = RunService:IsClient()
assert(
	IS_CLIENT,
	"[Cmdr] The Cmdr client library cannot be required by the server. Please require the server libary instead."
)

const Dispatcher = require("@self/Shared/Dispatcher")
const Registry = require("@self/Shared/Registry")
const Util = require("@self/Shared/Util")

const CmdrInterface = require("@self/CmdrInterface")
const DefaultEventHandlers = require("@self/DefaultEventHandlers")

const TYPES_FOLDER = script:WaitForChild("Types") :: Folder
const COMMANDS_FOLDER = script:WaitForChild("Commands") :: Folder

type Signal = {
	Fire: (self: Signal, ...any) -> (),
	Connect: (self: Signal, callback: (...any) -> ()) -> RBXScriptConnection,
}

const function createSignal(): Signal
	const event = Instance.new("BindableEvent")

	return {
		Fire = function(_, ...)
			event:Fire(...)
		end,

		Connect = function(_, callback)
			return event.Event:Connect(callback)
		end,
	}
end

--[=[
	@class CmdrClient
	@client

	The Cmdr client singleton and entry point.
]=]

--[=[
	@within CmdrClient
	@readonly

	@prop Registry Registry

	Refers to the command Registry.
]=]

--[=[
	@within CmdrClient
	@readonly

	@prop Dispatcher Dispatcher

	Refers to the command Dispatcher.
]=]

--[=[
	@within CmdrClient
	@readonly

	@prop Util Util

	Refers to a table containing many useful utility functions.
]=]

--[=[
	@within CmdrClient
	@readonly

	@prop Gui ScreenGui

	Refers to the current Cmdr GUI.
]=]

--[=[
	@within CmdrClient
	@readonly

	@prop Toggled { Connect: (self: Toggled, callback: (visible: boolean) -> ()) -> RBXScriptConnection, Fire: (self: Toggled, visible: boolean) -> () }

	A signal that fires when the Cmdr window is toggled.
]=]

--[=[
	@within CmdrClient
	@readonly
	@private

	@prop _interface CmdrInterface

	Refers to the CmdrInterface object.
]=]

--[=[
	@within Cmdr
	@readonly
	@private

	@prop _replicatedRoot ModuleScript

	Refers to the CmdrClient modulescript containing all shared functionality.
]=]

--[=[
	@within CmdrClient
	@readonly
	@private

	@prop _remoteEvent RemoteEvent

	Refers to the CmdrEvent RemoteEvent found within CmdrClient.
]=]

--[=[
	@within CmdrClient
	@readonly
	@private

	@prop _remoteFunction RemoteFunction

	Refers to the CmdrFunction RemoteFunction found within CmdrClient.
]=]

--[=[
	@within CmdrClient
	@readonly
	@private

	@prop _enabled boolean

	Whether or not Cmdr is enabled (will show via the defined activation keys). Use [`CmdrClient:SetEnabled`](#SetEnabled) to change.
]=]

--[=[
	@within CmdrClient
	@readonly
	@private

	@prop _activationKeys { [Enum.KeyCode] = true }

	The list of key codes that will show or hide Cmdr. Use [`CmdrClient:SetActivationKeys`](#SetActivationKeys) to change.
]=]

--[=[
	@within CmdrClient
	@readonly
	@private

	@prop _activationUnlocksMouse boolean

	Whether or not acitvating the Cmdr window will unlock the mouse.
]=]

--[=[
	@within CmdrClient
	@readonly
	@private

	@prop _mashToEnable boolean

	Whether or not mashing to enabled is enabled. Use [`CmdrClient:SetMashToEnable`](#SetMashToEnable) to change.
]=]

--[=[
	@within CmdrClient
	@readonly
	@private

	@prop _hideOnLostFocus boolean

	Whether or not loosing focus will hide the Cmdr window.
]=]

--[=[
	@within CmdrClient
	@readonly
	@private

	@prop _placeName string

	The current place name, displayed on the interface. Use [`CmdrClient:SetPlaceName`](#SetPlaceName) to change.
]=]

--[=[
	@within CmdrClient
	@readonly
	@private

	@prop _events { [string]: (any) -> () }

	A collection of event callbacks used by Cmdr.
]=]

const CmdrClient = {
	Registry = nil :: Registry.Registry?,
	Dispatcher = nil :: any,
	Util = Util,

	Gui = nil :: ScreenGui?,
	Toggled = createSignal(),

	_interface = nil :: any,

	_replicatedRoot = script,
	_remoteEvent = script:WaitForChild("CmdrEvent") :: RemoteEvent,
	_remoteFunction = script:WaitForChild("CmdrFunction") :: RemoteFunction,

	_enabled = true,
	_activationKeys = { Enum.KeyCode.F2 },
	_activationUnlocksMouse = false,
	_mashToEnable = false,
	_hideOnLostFocus = true,

	_placeName = "Cmdr",

	_events = {} :: { [string]: (any) -> () },
}

--[=[
	@within CmdrClient
	Sets whether or not Cmdr can be shown via the defined activation keys. Useful for when you want users to opt-in to show the console, for instance in a settings menu.
]=]
function CmdrClient:SetEnabled(enabled: boolean)
	self._enabled = enabled
end

--[=[
	@within CmdrClient
	Sets the key codes that will used to toggle Cmdr.
]=]
function CmdrClient:SetActivationKeys(keys: { Enum.KeyCode })
	self._activationKeys = keys
end

--[=[
	@within CmdrClient
	Sets if activation will free the mouse.
]=]
function CmdrClient:SetActivationUnlocksMouse(enabled: boolean)
	self._activationUnlocksMouse = enabled
end

--[=[
	@within CmdrClient
	Shows the Cmdr window. Does nothing if Cmdr isn't enabled.
]=]
function CmdrClient:Show()
	if not self._enabled then
		return
	end

	self._interface.Window:Show()
end

--[=[
	within CmdrClient
	Hides the Cmdr window.
]=]
function CmdrClient:Hide()
	self._interface.Window:Hide()
end

--[=[
	@within CmdrClient
	Toggles the Cmdr window. Does nothing if Cmdr isn't enabled.
]=]
function CmdrClient:Toggle()
	if not self._enabled then
		self:Hide()
		return
	end

	self._interface.Window:SetVisible(not self._interface.Window:IsVisible())
end

--[=[
	@within CmdrClient
	Enables the "Mash to enable" feature.
	This feature, when enabled, requires the [activation key](#SetActivationKeys) to be pressed 5 times within a second to enable Cmdr.
	This may be helpful to guard against mispresses from opening the window, for example.
]=]
function CmdrClient:SetMashToEnable(enabled: boolean)
	self._mashToEnable = enabled
end

--[=[
	@within CmdrClient
	Sets the hide on 'lost focus' feature.
	This feature, which is enabled by default, will cause Cmdr to [hide](#Hide) when the user clicks off the window.
]=]
function CmdrClient:SetHideOnLostFocus(enabled: boolean)
	self._hideOnLostFocus = enabled
end

--[=[
	@within CmdrClient
	Sets the place name label on the interface. This is useful for a quick way to tell what game you're playing in a universe game.
]=]
function CmdrClient:SetPlaceName(name: string)
	self._placeName = name
	self._interface.Window:UpdateLabelText()
end

--[=[
	@within CmdrClient
	Sets the [network event handler](/docs/reference/networkeventhandlers) for a certain event type.
]=]
function CmdrClient:HandleEvent(name: string, callback: (...any) -> ())
	self._events[name] = callback
end

-- Initialize CmdrClient
const function initialize()
	CmdrClient.Registry = Registry(CmdrClient)
	CmdrClient.Dispatcher = Dispatcher(CmdrClient)
	CmdrClient._interface = CmdrInterface(CmdrClient)

	CmdrClient._remoteEvent.OnClientEvent:Connect(function(eventName: string, ...)
		if not CmdrClient._events[eventName] then
			return
		end

		CmdrClient._events[eventName](...)
	end)

	CmdrClient.Registry:RegisterTypesIn(TYPES_FOLDER)
	CmdrClient.Registry:RegisterCommandsIn(COMMANDS_FOLDER)

	TYPES_FOLDER.ChildAdded:Connect(function(child: Instance)
		if not child:IsA("ModuleScript") then
			warn(`[Cmdr] Ignored non-module child in Types: {child.Name}`)
			return
		end

		require(child)(CmdrClient.Registry)
	end)

	COMMANDS_FOLDER.ChildAdded:Connect(function(child: Instance)
		if not child:IsA("ModuleScript") then
			warn(`[Cmdr] Ignored non-module child in Commands: {child.Name}`)
			return
		end

		CmdrClient.Registry:RegisterCommand(child)
	end)
end

initialize()
DefaultEventHandlers(CmdrClient)

-- Export CmdrClient
return setmetatable(CmdrClient, {
	__index = function(self, key)
		const dispatcher = rawget(self, "Dispatcher")
		const value = dispatcher and dispatcher[key]
		assert(value, `[Cmdr] Dispatcher has no method or property "{key}".`)

		if type(value) == "function" then
			if not script:GetAttribute("HasShownProxyCallWarning") then
				warn(
					debug.traceback(
						`[Cmdr] [APIUsage::ProxyCalls] Method calls should be performed by their respective modules rather than the Cmdr object.`,
						2
					)
				)
				script:SetAttribute("HasShownProxyCallWarning", true)
			end

			return function(_, ...)
				return value(dispatcher, ...)
			end
		end

		return nil
	end,
	__newindex = function(_, key)
		error(`[Cmdr] Cannot assign key "{key}"; the CmdrClient singleton is read-only.`)
	end,
})
