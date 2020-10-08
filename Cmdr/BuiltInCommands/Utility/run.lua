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

	Run = function(context, fullCommand)
		fullCommand = fullCommand
			:gsub("&&&", "___!CMDR_SPLIT!___")
			:gsub("|||", "___!CMDR_DOUBLE_PIPE!___")
		local commands = fullCommand:split("&&")

		local output = ""
		for i, command in ipairs(commands) do
			command = command
				:gsub("||", output:find("%s") and ("%q"):format(output) or output)
				:gsub("___!CMDR_SPLIT!___", "&&")
				:gsub("___!CMDR_DOUBLE_PIPE!___", "||")
			output = tostring(context.Dispatcher:EvaluateAndRun(context.Cmdr.Util.RunEmbeddedCommands(context.Dispatcher, command)))

			if i == #commands then
				return output
			end
		end
	end
}