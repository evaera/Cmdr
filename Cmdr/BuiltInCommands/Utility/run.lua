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

	Run = function(context, fullCommand)
		local commands = fullCommand:split("&&")

		for i, command in ipairs(commands) do
			local output = context.Dispatcher:EvaluateAndRun(context.Cmdr.Util.RunEmbeddedCommands(context.Dispatcher, command))

			if i == #commands then
				return output
			end
		end
	end
}