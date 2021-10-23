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
	ClientRun = function(context, pathname)
		-- Get the local directory for the player
		local Directory = context.Directory

		if pathname then
			Directory:SetCD(pathname)
		end
		return Directory:GetCD()
	end
} 