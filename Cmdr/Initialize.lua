local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Util = require(script.Parent.Shared.Util)

--- Handles initial preparation of the game server-side.
return function (cmdr)
	local ReplicatedRoot, RemoteFunction

	local function Create (class, name, parent)
		local object = Instance.new(class)
		object.Name = name
		object.Parent = parent or ReplicatedRoot

		return object
	end

	ReplicatedRoot = script.Parent.Client.CmdrClient
	ReplicatedRoot.Parent = ReplicatedStorage

	RemoteFunction = Create("RemoteFunction", "CmdrFunction")

	Create("Folder", "Commands")
	Create("Folder", "Types")

	script.Parent.Shared.Parent = ReplicatedRoot
	script.Parent.Client.CmdrInterface.Parent = StarterGui:WaitForChild("Cmdr")
	script.Parent.Client:Destroy()

	cmdr.ReplicatedRoot = ReplicatedRoot
	cmdr.RemoteFunction = RemoteFunction

	cmdr:RegisterTypesIn(script.Parent.BuiltInTypes)
	--cmdr:RegisterCommandsIn(script.Parent.BuiltInCommands)

	script.Parent.BuiltInTypes:Destroy()
	script.Parent.BuiltInCommands.Name = "Server commands"
end
