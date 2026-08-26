const VERSION = "v1.13.0-rc.4"

return {
	Name = "version",
	Description = "Shows the current version of Cmdr.",
	Group = "DefaultDebug",
	Args = {},

	ClientRun = function(): string
		return `Cmdr Version {VERSION}`
	end,
}
