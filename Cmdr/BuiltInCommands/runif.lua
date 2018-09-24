local conditions = {
	startsWith = function (text, arg)
		if text:sub(1, #arg) == arg then
			return text:sub(#arg + 1)
		end
	end
}

return {
	Name = "runif";
	Aliases = {};
	Description = "Runs a given command string if a certain condition is met.";
	Group = "DefaultUtil";
	Args = {
		{
			Type = "string";
			Name = "Condition";
			Description = "The condition function"
		},
		{
			Type = "string";
			Name = "Argument";
			Description = "The argument to the condition function"
		},
		{
			Type = "string";
			Name = "Command";
			Description = "The command string to run if requirements are met"
		},
	};

	Run = function(context, condition, arg, command)
		local conditionFunc = conditions[condition]

		if not conditionFunc then
			return ("Condition %q is not valid."):format(condition)
		end

		local text = conditionFunc(command, arg)

		if text then
			context:Reply(context.Dispatcher:EvaluateAndRun(context.Cmdr.Util.SubstituteAmbientArgs(text)))
		end

		return ""
	end
}