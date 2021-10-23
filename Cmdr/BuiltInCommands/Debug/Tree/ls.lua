return {
	Name = "ls",
	Description = "Lists the instances in the current path.",
	Group = "DefaultDebug",
	Args = {
		{
			Type = "pathname",
			Name = "Instance",
			Description = "The path of the target relative to the cd.",
			Optional = true
		}
	},
	ClientRun = function(context, pathname)
		-- Get the local directory for the player
		local Directory = context.Directory

		-- Get the instance
		local instance = pathname and Directory:GetInstance(pathname)

		-- Get the instance at the current directory
		if not instance then
			instance = Directory:GetInstance("./")

			if not instance then
				return "# The current directory is invalid."
			end
		end

		-- List all children
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