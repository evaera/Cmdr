return {
	Name = "history";
	Aliases = {};
	AutoExec = {
		"alias ! run ${history $1}";
		"alias ^ run ${run replace ${history -1} $1 $2}";
		"alias !! ! -1";
	};
	Description = "Displays previous commands from history.";
	Group = "DefaultUtil";
	Args = {
		{
			Type = "integer";
			Name = "Line Number";
			Description = "Command line number (can be negative to go from end)"
		},
	};

	ClientRun = function(context, line)
		local history = context.Dispatcher:GetHistory()

		if line <= 0 then
			line = #history + line
		end

		return history[line] or ""
	end
}