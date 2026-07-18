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

		if not character or not character:FindFirstChild("HumanoidRootPart") then
			return "You don't have a character."
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { character }
		raycastParams.IgnoreWater = true
		raycastParams.RespectCanCollide = true

		local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, raycastParams)

		if raycastResult then
			local pos = character.HumanoidRootPart.Position
			local diff = (raycastResult.Position - pos)

			local unitDirection = if diff.Magnitude > 0 then diff.Unit else Vector3.new()
			character:MoveTo((diff * 2) + (unitDirection * extra) + pos)
			return "Thru the wall!"
		else
			character:MoveTo(mouse.Hit.Position)
			return "Blinked (No wall found)!"
		end
	end,
}
