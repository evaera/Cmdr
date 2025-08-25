local CollectionService = game:GetService("CollectionService")

for _, instance in workspace:GetDescendants() do
	if instance:IsA("BasePart") and not instance.CanCollide then
		instance:AddTag("RayBlacklist")
	end
end

workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("BasePart") and not descendant.CanCollide then
		descendant:AddTag("RayBlacklist")
	end
end)

return {
	Name = "blink",
	Aliases = { "b" },
	Description = "Teleports you to where your mouse is hovering.",
	Group = "DefaultDebug",
	Args = {},

	ClientRun = function(context)
		-- We implement this here because player position is owned by the client.
		-- No reason to bother the server for this!

		local mouse = context.Executor:GetMouse()
		local character = context.Executor.Character

		if not (character and character:FindFirstChild("HumanoidRootPart")) then
			return "You don't have a character."
		end

		character:AddTag("RayBlacklist")

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = CollectionService:GetTagged("RayBlacklist")
		raycastParams.IgnoreWater = true
		raycastParams.CollisionGroup = "Default"

		local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, raycastParams)

		character:MoveTo(if raycastResult then raycastResult.Position else mouse.Hit.Position)

		return "Blinked!"
	end,
}
