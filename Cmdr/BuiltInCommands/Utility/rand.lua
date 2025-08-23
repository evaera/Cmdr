local generator = Random.new()

return {
	Name = "rand",
	Aliases = {},
	Description = "Returns a random number between min and max",
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

	ClientRun = function(_, firstNumber, secondNumber)
		return tostring(
			if secondNumber
				then generator:NextInteger(firstNumber, secondNumber)
				else generator:NextInteger(1, firstNumber)
		)
	end,
}
