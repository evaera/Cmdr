return {
	Name = "run";
	Aliases = {">"};
	AutoExec = {
		"alias discard replace ${run $1} .* \\\"\\\""
	};
	Description = "Runs a given command string (replacing embedded commands).";
	Group = "DefaultUtil";
	Args = {
		{
			Type = "string";
			Name = "Command";
			Description = "The command string to run"
		},
	};

	Run = function(context, commandString)
		return context.Cmdr.Util.RunCommandString(context.Dispatcher, commandString)
	end
}