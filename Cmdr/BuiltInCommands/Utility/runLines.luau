return {
	Name = "run-lines",
	Description = "Splits input by newlines and runs each line as its own command. This is used by the init-run command",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "string",
			Name = "Script",
			Description = "The script to parse",
			Default = "",
		},
	},

	ClientRun = function(context: any, text: string): string
		if #text == 0 then
			return ""
		end

		const shouldPrintOutput = context.Dispatcher:Run("var", "INIT_PRINT_OUTPUT") ~= ""
		const commands = text:gsub("\n+", "\n"):split("\n")
		for _, command: string in ipairs(commands) do
			if command:sub(1, 1) == "#" then
				continue
			end

			const output = context.Dispatcher:EvaluateAndRun(command)
			if shouldPrintOutput then
				context:Reply(output)
			end
		end

		return ""
	end,
}
