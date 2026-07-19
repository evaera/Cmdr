local RunService = game:GetService("RunService")

local Shared = script:WaitForChild("Shared")
local Util = require(Shared:WaitForChild("Util"))
local CreateGui = require(script.CreateGui)

if RunService:IsClient() == false then
	error(
		"[Cmdr] Server scripts cannot require the client library. Please require the server library from the server to use Cmdr in your own code."
	)
end

local function CreateSignal()
	local event = Instance.new("BindableEvent")

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
	@prop Registry Registry
	@readonly
	Refers to the current command Registry.
]=]

--[=[
	@within CmdrClient
	@prop Dispatcher Dispatcher
	@readonly
	Refers to the current command Dispatcher.
]=]

--[=[
	@within CmdrClient
	@prop Util Util
	@readonly
	Refers to a table containing many useful utility functions.
]=]

--[=[
	@within CmdrClient
	@prop Enabled boolean
	@readonly
	Whether or not Cmdr is enabled (will show via the defined activation keys). Use [`CmdrClient:SetEnabled`](#SetEnabled) to change.
]=]

--[=[
	@within CmdrClient
	@prop PlaceName string
	@readonly
	The current place name, displayed on the interface. Use [`CmdrClient:SetPlaceName`](#SetPlaceName) to change.
]=]

--[=[
	@within CmdrClient
	@prop ActivationKeys { [Enum.KeyCode] = true }
	@readonly
	The list of key codes that will show or hide Cmdr. Use [`CmdrClient:SetActivationKeys`](#SetActivationKeys) to change.
]=]

--[=[
	@within CmdrClient
	@prop Gui ScreenGui
	@readonly
	Refers to the current Cmdr GUI.
]=]

--[=[
	@within CmdrClient
	@prop Toggled { Connect: (self: ToggleSignal, callback: (visible: boolean) -> ()) -> RBXScriptConnection, Fire: (self: ToggleSignal, visible: boolean) -> () }
	@readonly
	A signal that fires when the Cmdr window is toggled.
]=]

local Cmdr
do
	Cmdr = setmetatable({
		ReplicatedRoot = script,
		RemoteFunction = script:WaitForChild("CmdrFunction"),
		RemoteEvent = script:WaitForChild("CmdrEvent"),
		ActivationKeys = { [Enum.KeyCode.F2] = true },
		Enabled = true,
		MashToOpen = false,
		ActivationUnlocksMouse = false,
		HideOnLostFocus = true,
		PlaceName = "Cmdr",
		Util = Util,
		Gui = CreateGui(),
		Toggled = CreateSignal(),
		Events = {},
	}, {
		-- This sucks, and may be redone or removed
		-- Proxies dispatch methods on to main Cmdr object
		__index = function(self, k)
			local r = self.Dispatcher[k]
			if r and type(r) == "function" then
				return function(_, ...)
					return r(self.Dispatcher, ...)
				end
			end
		end,
	})

	Cmdr.Registry = require(Shared.Registry)(Cmdr)
	Cmdr.Dispatcher = require(Shared.Dispatcher)(Cmdr)
end

local Interface = require(script.CmdrInterface)(Cmdr)

--[=[
	Sets the key codes that will used to show or hide Cmdr.

	@within CmdrClient
]=]
function Cmdr:SetActivationKeys(keys: { Enum.KeyCode })
	self.ActivationKeys = Util.MakeDictionary(keys)
end

--[=[
	Sets the place name label on the interface. This is useful for a quick way to tell what game you're playing in a universe game.

	@within CmdrClient
]=]
function Cmdr:SetPlaceName(name: string)
	self.PlaceName = name
	Interface.Window:UpdateLabel()
end

--[=[
	Sets whether or not Cmdr can be shown via the defined activation keys. Useful for when you want users to opt-in to show the console, for instance in a settings menu.

	@within CmdrClient
]=]
function Cmdr:SetEnabled(enabled: boolean)
	self.Enabled = enabled
end

--[=[
	Sets if activation will free the mouse.

	@within CmdrClient
]=]
function Cmdr:SetActivationUnlocksMouse(enabled: boolean)
	self.ActivationUnlocksMouse = enabled
end

--[=[
	Shows the Cmdr window. Does nothing if Cmdr isn't enabled.

	@within CmdrClient
]=]
function Cmdr:Show()
	if not self.Enabled then
		return
	end

	Interface.Window:Show()
end

--[=[
	Hides the Cmdr window.

	@within CmdrClient
]=]
function Cmdr:Hide()
	Interface.Window:Hide()
end

--[=[
	Toggles the Cmdr window. Does nothing if Cmdr isn't enabled.

	@within CmdrClient
]=]
function Cmdr:Toggle()
	if not self.Enabled then
		self:Hide()
		return
	end

	Interface.Window:SetVisible(not Interface.Window:IsVisible())
end

--[=[
	Enables the "Mash to open" feature.
	This feature, when enabled, requires the [activation key](#SetActivationKeys) to be pressed 5 times within a second to open Cmdr.
	This may be helpful to guard against mispresses from opening the window, for example.
	Once opened, mashing will be disabled for 10 seconds since it was last closed for convenience.

	@within CmdrClient
]=]
function Cmdr:SetMashToOpen(enabled: boolean)
	self.MashToOpen = enabled
end

--[=[
	@deprecated v1.13.0 -- This method was renamed to SetMashToOpen in v1.13.0. The old name exists for backwards compatibility and should not be used for new work.
	@within CmdrClient
]=]
function Cmdr:SetMashToEnable(enabled: boolean)
	Util:_emitDeprecationWarning("SetMashToEnable")
	self:SetMashToOpen(enabled)
end

Util:_registerDeprecationWarning(
	"SetMashToEnable",
	"This method was renamed to SetMashToOpen in v1.13.0. The old name exists for backwards compatibility and should not be used for new work."
)

--[=[
	Sets the hide on 'lost focus' feature.
	This feature, which is enabled by default, will cause Cmdr to [hide](#Hide) when the user clicks off the window.

	@within CmdrClient
]=]
function Cmdr:SetHideOnLostFocus(enabled: boolean)
	self.HideOnLostFocus = enabled
end

--[=[
	Sets the [network event handler](/docs/networkeventhandlers) for a certain event type.

	@within CmdrClient
]=]
function Cmdr:HandleEvent(name: string, callback: (...any) -> ())
	self.Events[name] = callback
end

-- Register built-in types and commands
local TypesFolder = script:WaitForChild("Types") :: Folder
local CommandsFolder = script:WaitForChild("Commands") :: Folder

Cmdr.Registry:RegisterTypesIn(TypesFolder)
Cmdr.Registry:RegisterCommandsIn(CommandsFolder)

TypesFolder.ChildAdded:Connect(function(child: Instance)
	if child:IsA("ModuleScript") then
		require(child)(Cmdr.Registry)
	else
		warn(`[Cmdr] Ignored non-module child in Types: {child.Name}`)
	end
end)

CommandsFolder.ChildAdded:Connect(function(child: Instance)
	if child:IsA("ModuleScript") then
		Cmdr.Registry:RegisterCommand(child)
	else
		warn(`[Cmdr] Ignored non-module child in Commands: {child.Name}`)
	end
end)

-- Hook up event listener
Cmdr.RemoteEvent.OnClientEvent:Connect(function(name, ...)
	if Cmdr.Events[name] then
		Cmdr.Events[name](...)
	end
end)

require(script.DefaultEventHandlers)(Cmdr)

return Cmdr
