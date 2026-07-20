local conditions = {
	startsWith = function(text, arg)
		if text:sub(1, #arg) == arg then
			return text:sub(#arg + 1)
		end
	end,

	contains = function(text, arg)
		if text:find(arg, 1, true) then
			return text
		end
	end,

	endsWith = function(text, arg)
		if text:sub(-#arg) == arg then
			return text:sub(1, -#arg - 1)
		end
	end,

	pattern = function(text, arg)
		if text:match(arg) then
			return text
		end
	end,

	equals = function(text, arg)
		if text == arg then
			return text
		end
	end,

	notEquals = function(text, arg)
		if text ~= arg then
			return text
		end
	end,

	greaterThan = function(text, arg)
		if tonumber(text) > tonumber(arg) then
			return text
		end
	end,

	lessThan = function(text, arg)
		if tonumber(text) < tonumber(arg) then
			return text
		end
	end,

	greaterThanOrEqual = function(text, arg)
		if tonumber(text) >= tonumber(arg) then
			return text
		end
	end,

	lessThanOrEqual = function(text, arg)
		if tonumber(text) <= tonumber(arg) then
			return text
		end
	end,

	length = function(text, arg)
		if #text == tonumber(arg) then
			return text
		end
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
