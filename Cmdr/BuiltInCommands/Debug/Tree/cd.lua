return {
	Name = "cd",
	Description = "Changes the current working directory, or outputs it.",
	Group = "DefaultDebug",
	Args = {
		{
			Type = "pathname",
			Name = "Instance",
			Description = "The instance to change the cd to. Can be a relative path or a full path. If omitted, outputs the cd.",
			Optional = true
		}
	},
	AutoExec = {
		"cd ~"
	},
	ClientRun = function(context, pathname)
		local cmdr = context.Cmdr
		local Directory = cmdr.Directory

		if pathname then
			Directory:SetCD(pathname)
		end
		return Directory:GetCD()
	end
} 