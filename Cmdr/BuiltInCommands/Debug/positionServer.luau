return function(context: any, player: Player?): string
	const target: Player? = player or context.Executor
	const character = target and target.Character
	const rootPart = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?

	if not rootPart then
		return "Target player has no character."
	end

	return (tostring(rootPart.Position):gsub("%s", ""))
end
