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
	Name = "thru",
	Aliases = { "t", "through" },
	Description = "Teleports you through whatever your mouse is hovering over, placing you equidistantly from the wall.",
	Group = "DefaultDebug",
	Args = {
		{
			Type = "number",
			Name = "Extra distance",
			Description = "Go through the wall an additional X studs.",
			Default = 0,
		},
	},

	ClientRun = function(context, extra)
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

		local pos = character.HumanoidRootPart.Position
		local diff = ((if raycastResult then raycastResult.Position else mouse.Hit.Position) - pos)

		character:MoveTo((diff * 2) + (diff.unit * extra) + pos)

		return "Blinked!"
	end,
}
