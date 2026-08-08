return {
	Name = "history",
	AutoExec = {
		'alias "!|Displays previous command from history." run ${history $1{number|Line Number}}',
		'alias "^|Runs the previous command, replacing all occurrences of A with B." run ${run replace ${history -1} $1{string|A} $2{string|B}}',
		'alias "!!|Reruns the last command." ! -1',
	},
	Description = "Displays previous commands from history.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "integer",
			Name = "Line Number",
			Description = "Command line number (can be negative to go from end)",
		},
	},

	ClientRun = function(context: any, line: number): string
		const history = context.Dispatcher:GetHistory()

		if line <= 0 then
			line = #history + line
		end

		return history[line] or ""
	end,
}
