return {
	Name = "run";
	Aliases = {};
	Description = "Runs a given command string (replacing ambient arguments).";
	Group = "DefaultUtil";
	Args = {
		{
			Type = "string";
			Name = "Command";
			Description = "The command string to run"
		},
	};

	Run = function(context, command)
		return context.Dispatcher:EvaluateAndRun(context.Cmdr.Util.RunEmbeddedCommands(context.Dispatcher, context.Cmdr.Util.SubstituteAmbientArgs(command)))
	end
}