local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local CreateGui = require(script.Parent.CreateGui)

--- Handles initial preparation of the game server-side.
return function (cmdr)
	local ReplicatedRoot, RemoteFunction, RemoteEvent

	local function Create (class, name, parent)
		local object = Instance.new(class)
		object.Name = name
		object.Parent = parent or ReplicatedRoot

		return object
	end

	ReplicatedRoot = script.Parent.CmdrClient

	if ReplicatedStorage:FindFirstChild("Resources") and
		ReplicatedStorage.Resources:FindFirstChild("Libraries") then -- If using RoStrap
		-- ReplicatedRoot.Name = "Cmdr"
		ReplicatedRoot.Parent = ReplicatedStorage.Resources.Libraries
	else
		ReplicatedRoot.Parent = ReplicatedStorage
	end

	RemoteFunction = Create("RemoteFunction", "CmdrFunction")
	RemoteEvent = Create("RemoteEvent", "CmdrEvent")

	Create("Folder", "Commands")
	Create("Folder", "Types")

	script.Parent.Shared.Parent = ReplicatedRoot

	cmdr.ReplicatedRoot = ReplicatedRoot
	cmdr.RemoteFunction = RemoteFunction
	cmdr.RemoteEvent = RemoteEvent

	cmdr:RegisterTypesIn(script.Parent.BuiltInTypes)

	script.Parent.BuiltInTypes:Destroy()
	script.Parent.BuiltInCommands.Name = "Server commands"

	if StarterGui:FindFirstChild("Cmdr") == nil then
		CreateGui()
	end
end
