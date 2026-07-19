return {
	Name = "exit",
	Aliases = {},
	Description = "Exit the Cmdr window.",
	Group = "DefaultUtil",
	Args = {},
	ClientRun = function(context)
		context.Cmdr:Hide()
		return ""
	end,
}
