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

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { character }
		raycastParams.IgnoreWater = true
		raycastParams.RespectCanCollide = true

		local raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, raycastParams)
		local targetPosition = if raycastResult then raycastResult.Position else mouse.Hit.Position

		character:MoveTo(targetPosition)

		return "Blinked!"
	end,
}
