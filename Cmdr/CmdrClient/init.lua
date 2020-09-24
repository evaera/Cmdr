local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Shared = script:WaitForChild("Shared")
local Util = require(Shared:WaitForChild("Util"))

if RunService:IsClient() == false then
	error("Server scripts cannot require the client library. Please require the server library to use Cmdr in your own code.")
end

local Cmdr do
	Cmdr = setmetatable({
		ReplicatedRoot = script;
		RemoteFunction = script:WaitForChild("CmdrFunction");
		RemoteEvent = script:WaitForChild("CmdrEvent");
		ActivationKeys = {[Enum.KeyCode.F2] = true};
		Enabled = true;
		MashToEnable = false;
		ActivationUnlocksMouse = false;
		HideOnLostFocus = true;
		PlaceName = "Cmdr";
		Util = Util;
		Events = {};
	}, {
		-- This sucks, and may be redone or removed
		-- Proxies dispatch methods on to main Cmdr object
		__index = function (self, k)
			local r = self.Dispatcher[k]
			if r and type(r) == "function" then
				return function (_, ...)
					return r(self.Dispatcher, ...)
				end
			end
		end
	})

	Cmdr.Registry = require(Shared.Registry)(Cmdr)
	Cmdr.Dispatcher = require(Shared.Dispatcher)(Cmdr)
end

if StarterGui:WaitForChild("Cmdr") and wait() and Player:WaitForChild("PlayerGui"):FindFirstChild("Cmdr") == nil then
	StarterGui.Cmdr:Clone().Parent = Player.PlayerGui
end

local Interface = require(script.CmdrInterface)(Cmdr)

--- Sets a list of keyboard keys (Enum.KeyCode) that can be used to open the commands menu
function Cmdr:SetActivationKeys (keysArray)
	self.ActivationKeys = Util.MakeDictionary(keysArray)
end

--- Sets the place name label on the interface
function Cmdr:SetPlaceName (name)
	self.PlaceName = name
	Interface.Window:UpdateLabel()
end

--- Sets whether or not the console is enabled
function Cmdr:SetEnabled (enabled)
	self.Enabled = enabled
end

--- Sets if activation will free the mouse.
function Cmdr:SetActivationUnlocksMouse (enabled)
	self.ActivationUnlocksMouse = enabled
end

--- Shows Cmdr window
function Cmdr:Show ()
	if not self.Enabled then
		return
	end

	Interface.Window:Show()
end

--- Hides Cmdr window
function Cmdr:Hide ()
	Interface.Window:Hide()
end

--- Toggles Cmdr window
function Cmdr:Toggle ()
	if not self.Enabled then
		return self:Hide()
	end

	Interface.Window:SetVisible(not Interface.Window:IsVisible())
end

--- Enables the "Mash to open" feature
function Cmdr:SetMashToEnable(isEnabled)
	self.MashToEnable = isEnabled

	if isEnabled then
		self:SetEnabled(false)
	end
end

--- Sets the hide on 'lost focus' feature.
function Cmdr:SetHideOnLostFocus(enabled)
	self.HideOnLostFocus = enabled
end

--- Sets the handler for a certain event type
function Cmdr:HandleEvent(name, callback)
	self.Events[name] = callback
end

-- Only register when we aren't in studio because don't want to overwrite what the server portion did
if RunService:IsServer() == false then
	Cmdr.Registry:RegisterTypesIn(script:WaitForChild("Types"))
	Cmdr.Registry:RegisterCommandsIn(script:WaitForChild("Commands"))
end

-- Hook up event listener
Cmdr.RemoteEvent.OnClientEvent:Connect(function(name, ...)
	if Cmdr.Events[name] then
		Cmdr.Events[name](...)
	end
end)

require(script.DefaultEventHandlers)(Cmdr)

return Cmdr
