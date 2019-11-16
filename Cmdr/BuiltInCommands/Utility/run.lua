return {
	Name = "run";
	Aliases = {};
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

	ClientRun = function(context, command)
		return context.Dispatcher:EvaluateAndRun(context.Cmdr.Util.RunEmbeddedCommands(context.Dispatcher, command))
	end
}