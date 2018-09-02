local RunService = game:GetService("RunService")
local Shared = script:WaitForChild("Shared")
local Util = require(Shared:WaitForChild("Util"))

if RunService:IsClient() == false then
	error("Server scripts cannot require the client library. Please require the server library to use Cmdr in your own code.")
end

local Cmdr do
	Cmdr = setmetatable({
		ReplicatedRoot = script;
		RemoteFunction = script:WaitForChild("CmdrFunction");
		ActivationKeys = {[Enum.KeyCode.Semicolon] = true};
		Enabled = true;
		PlaceName = "place";
		Util = Util;
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

-- Only register when we aren't in studio because don't want to overwrite what the server portion did
if RunService:IsServer() == false then
	Cmdr.Registry:RegisterTypesIn(script:WaitForChild("Types"))
	Cmdr.Registry:RegisterCommandsIn(script:WaitForChild("Commands"))
end

return Cmdr