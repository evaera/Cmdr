local ResolvePath;

return {
	Name = "ls",
	Description = "Lists all of the children of the current working instance.",
	Group = "DefaultTree",
	Args = {
		{
			Type = "string",
			Name = "Instance",
			Description = "The instance to list the children of. Can be a relative path or a full path.",
			Optional = true
		}
	},
	ClientRun = function(context, stringPath)
		ResolvePath = require(context.Cmdr.ReplicatedRoot.Shared.ResolvePath)
		local util = context.Cmdr.Util
		local treeView = context:GetStore("_TreeView")
		stringPath = stringPath or "."

		--[[ Changing active instance ]]--
		if treeView.View == "Client" then
			local instance = ResolvePath(context, stringPath, treeView.WorkingInstance)
	
			if instance == nil then
				return ("'%s' is not recognized as a valid Instance."):format(stringPath)
			else
				for _, Child in pairs(instance:GetChildren()) do
					context:Reply(Child.Name)
				end

				return ""
			end
		else
			return nil
		end
	end
}
