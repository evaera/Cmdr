local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local module = {}

if RunService:IsServer() then
	module.Cmdr = require(script.Parent.Cmdr)
end

if RunService:IsClient() then
	module.CmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient"))
end

return module
