const ReplicatedStorage = game:GetService("ReplicatedStorage")

const BuiltInGuards = ReplicatedStorage.CmdrClient.Shared.BuiltInGuards
const HasCharacter = require(BuiltInGuards.HasCharacter) :: (number?) -> (any) -> string?

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
	Guards = {
		HasCharacter(),
	},

	ClientRun = function(context: any, extra: number): string
		-- We implement this here because player position is owned by the client.
		-- No reason to bother the server for this!

		const mouse = context.Executor:GetMouse() :: Mouse
		const character = context.Executor.Character :: Model
		const rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart

		const raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { character }
		raycastParams.IgnoreWater = true
		raycastParams.RespectCanCollide = true

		const raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, raycastParams)
		if raycastResult then
			const pos = rootPart.Position
			const diff = (raycastResult.Position - pos)
			const unitDirection = if diff.Magnitude > 0 then diff.Unit else Vector3.new()

			character:MoveTo((diff * 2) + (unitDirection * extra) + pos)
			return "Thru the wall!"
		else
			character:MoveTo(mouse.Hit.Position)
			return "Blinked (No wall found)!"
		end
	end,
}
