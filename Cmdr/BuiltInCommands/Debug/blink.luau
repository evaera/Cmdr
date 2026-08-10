const ReplicatedStorage = game:GetService("ReplicatedStorage")

const BuiltInGuards = ReplicatedStorage.CmdrClient.Shared.BuiltInGuards
const HasCharacter = require(BuiltInGuards.HasCharacter) :: (number?) -> (any) -> string?

return {
	Name = "blink",
	Aliases = { "b" },
	Description = "Teleports you to where your mouse is hovering.",
	Group = "DefaultDebug",
	Args = {},
	Guards = {
		HasCharacter(),
	},

	ClientRun = function(context: any): string
		-- We implement this here because player position is owned by the client.
		-- No reason to bother the server for this!

		const mouse = context.Executor:GetMouse() :: Mouse
		const character = context.Executor.Character :: Model

		const raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { character }
		raycastParams.IgnoreWater = true
		raycastParams.RespectCanCollide = true

		const raycastResult = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, raycastParams)
		const targetPosition = if raycastResult then raycastResult.Position else mouse.Hit.Position
		character:MoveTo(targetPosition)

		return "Blinked!"
	end,
}
