return function(registry: any)
	registry:RegisterType(
		"mathOperator",
		registry.Cmdr.Util.MakeEnumType("Math Operator", {
			{
				Name = "+",
				Perform = function(a: number, b: number): number
					return a + b
				end,
			},
			{
				Name = "-",
				Perform = function(a: number, b: number): number
					return a - b
				end,
			},
			{
				Name = "*",
				Perform = function(a: number, b: number): number
					return a * b
				end,
			},
			{
				Name = "/",
				Perform = function(a: number, b: number): number
					return a / b
				end,
			},
			{
				Name = "**",
				Perform = function(a: number, b: number): number
					return a ^ b
				end,
			},
			{
				Name = "%",
				Perform = function(a: number, b: number): number
					return a % b
				end,
			},
		})
	)
end
