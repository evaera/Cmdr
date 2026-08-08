const GENERATOR = Random.new()

return {
	Name = "rand",
	Description = "Returns a random number between min and max.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "integer",
			Name = "First number",
			Description = "If second number is nil, random number is between 1 and this value. If second number is provided, number is between this number and the second number.",
		},
		{
			Type = "integer",
			Name = "Second number",
			Description = "The upper bound.",
			Optional = true,
		},
	},

	ClientRun = function(_, firstNumber: number, secondNumber: number?): string
		const min = if secondNumber then math.min(firstNumber, secondNumber) else math.min(1, firstNumber)
		const max = if secondNumber then math.max(firstNumber, secondNumber) else math.max(1, firstNumber)

		return tostring(GENERATOR:NextInteger(min, max))
	end,
}
