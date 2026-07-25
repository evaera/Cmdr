return {
	Name = "exit",
	Aliases = { "escape" },
	Description = "Exit the Cmdr window",
	Group = "DefaultUtil",
	Args = {},
	ClientRun = function(context): string
		context.Cmdr:Hide()
		return ""
	end,
}
