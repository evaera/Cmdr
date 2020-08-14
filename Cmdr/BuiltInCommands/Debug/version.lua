local version = "v1.6.0"

return {
	Name = "version",
	Args = {},
	Description = "Shows the current version of Cmdr",
	Group = "DefaultDebug",

	ClientRun = function()
		return ("Cmdr Version %s"):format(version)
	end
}
