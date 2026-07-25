const CONDITIONS = {
	startsWith = function(text, arg)
		return text:sub(1, #arg) == arg and text:sub(#arg + 1)
	end,

	contains = function(text, arg)
		return text:find(arg, 1, true) and text
	end,

	endsWith = function(text, arg)
		return text:sub(-#arg) == arg and text:sub(1, -#arg - 1)
	end,

	pattern = function(text, arg)
		return text:match(arg) and text
	end,

	equals = function(text, arg)
		return text == arg and text
	end,

	notEquals = function(text, arg)
		return text ~= arg and text
	end,

	greaterThan = function(text, arg)
		return tonumber(arg) > tonumber(text) and text
	end,

	lessThan = function(text, arg)
		return tonumber(arg) < tonumber(text) and text
	end,

	greaterThanOrEqual = function(text, arg)
		return tonumber(arg) >= tonumber(text) and text
	end,

	lessThanOrEqual = function(text, arg)
		return tonumber(arg) <= tonumber(text) and text
	end,

	length = function(text, arg)
		return #text == tonumber(arg) and text
	end,
}

local conditionNames = {}
for name in pairs(CONDITIONS) do
	conditionNames[#conditionNames + 1] = name
end

return {
	Name = "runif",
	Description = "Runs a given command string if a certain condition is met.",
	Group = "DefaultUtil",
	Args = {
		function(context)
			return {
				Type = context.Cmdr.Util.MakeEnumType("ConditionFunction", conditionNames),
				Name = "Condition",
				Description = "The condition function.",
			}
		end,
		{
			Type = "string",
			Name = "Argument",
			Description = "The argument to the condition function.",
		},
		{
			Type = "string",
			Name = "Test against",
			Description = "The text to test against.",
		},
		{
			Type = "string",
			Name = "Command",
			Description = "The command string to run if requirements are met. If omitted, return value from condition function is used.",
			Optional = true,
		},
	},

	ClientRun = function(context: any, condition: string, arg: string, testAgainst: string, command: string): string
		const conditionFunc = CONDITIONS[condition]
		const success, text = pcall(conditionFunc, testAgainst, arg)
		if success and text then
			return context.Dispatcher:EvaluateAndRun(context.Cmdr.Util.RunEmbeddedCommands(context.Dispatcher, command or text))
		end

		return ""
	end,
}
