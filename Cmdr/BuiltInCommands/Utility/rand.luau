const GENERATOR = Random.new()

return {
	Name = "rand",
	Description = "Returns a random number between min and max",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "integer",
			Name = "First number",
			Description = "If second number is nil, random number is between 1 and this value. If second number is provided, number is between this number and the second number",
		},
		{
			Type = "integer",
			Name = "Second number",
			Description = "The upper bound",
			Optional = true,
		},
	},

	ClientRun = function(_, firstNumber: number, secondNumber: number): string
		return tostring(if secondNumber then GENERATOR:NextInteger(firstNumber, secondNumber) else GENERATOR:NextInteger(1, firstNumber))
	end,
}
