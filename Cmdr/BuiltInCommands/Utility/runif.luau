local conditions = {
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

return {
	Name = "runif",
	Aliases = {},
	Description = "Runs a given command string if a certain condition is met.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "conditionFunction",
			Name = "Condition",
			Description = "The condition function",
		},
		{
			Type = "string",
			Name = "Argument",
			Description = "The argument to the condition function",
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

	ClientRun = function(context, condition, arg, testAgainst, command)
		local conditionFunc = conditions[condition]

		if not conditionFunc then
			return ("Condition %q is not valid."):format(condition)
		end

		local success, text = pcall(conditionFunc, testAgainst, arg)

		if success and text then
			return context.Dispatcher:EvaluateAndRun(
				context.Cmdr.Util.RunEmbeddedCommands(context.Dispatcher, command or text)
			)
		end

		return ""
	end,
}
