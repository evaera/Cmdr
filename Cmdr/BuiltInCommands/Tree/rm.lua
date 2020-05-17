return {
	Name = "rm",
	Description = "Destroys the specified instance.",
	Group = "DefaultTree",
	Args = {
		{
			Type = "string",
			Name = "Instance",
			Description = "The instance to destroy. Can be a relative path or a full path.",
			Optional = true
		}
	},
	ClientRun = function(context, stringPath)
		local ResolvePath = require(context.Cmdr.ReplicatedRoot.Shared.ResolvePath)
		local treeView = context:GetStore("_TreeView")
		stringPath = stringPath or "."

		if treeView.View == "Client" then
			local instance = ResolvePath(context, stringPath, treeView.WorkingInstance)
	
			if instance == nil then
				return ("'%s' is not recognized as a valid Instance."):format(stringPath)
			else
				local success,error = pcall(function()
					instance:Destroy()
				end)

				if not success then
					return "Could not destroy instance '"..instance.Name.."' : "..error
				else
					return ""
				end
			end
		else
			return nil
		end
	end
}
