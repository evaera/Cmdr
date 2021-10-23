return {
	Name = "ls",
	Description = "Lists the instances in the current path.",
	Group = "DefaultDebug",
	Args = {
		{
			Type = "instance",
			Name = "Instance",
			Description = "The path of the target relative to the cd.",
			Optional = true
		}
	},
	ClientRun = function(context, instance)
		local cmdr = context.Cmdr
		local Directory = cmdr.Directory

		-- Get the instance at the current directory
		if not instance then
			instance = Directory:GetInstance("./")

			if not instance then
				return "# The current directory is invalid."
			end
		end

		local results = {}
		for _, child in ipairs(instance:GetChildren()) do
			local success, name = pcall(tostring, child)
			if success then
				table.insert(results, name)
			end
		end
		return table.concat(results, "\n")
	end
} 