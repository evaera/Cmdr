const VERSION = "v1.13.0-rc.2"

return {
	Name = "version",
	Aliases = { "v" },
	Description = "Shows the current version of Cmdr.",
	Group = "DefaultDebug",

	ClientRun = function(): string
		return `Cmdr Version {VERSION}`
	end,
}
