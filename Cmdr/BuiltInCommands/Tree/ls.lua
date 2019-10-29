return {
	Name = "ls",
	Description = "Lists all of the children of the current working instance.",
	Group = "DefaultTree",
	Args = {
		{
			Type = "string",
			Name = "Instance",
			Description = "The instance to list the children of. Can be a relative path or afull path.",
			Optional = true
		}
	},
	Run = function(context, stringPath)
		local util = context.Cmdr.Util
		local treeView = context:GetStore("_TreeView")
		stringPath = stringPath or util.GetInstanceFullName(treeView.WorkingInstance)

		--[[ Changing active instance ]]--
		if treeView.View == "Client" then
			local Instance;
	
			if string.split(stringPath,".")[1] == "game" then -- Absolute path specified
				Instance = util.GetInstanceFromStringPath(stringPath)
			else -- Relative path specified
				if stringPath == ".." then -- Move up an Instance
					Instance = treeView.WorkingInstance.Parent
				elseif string.split(stringPath,".")[1] == "." then --Instance with reserved word specified
					Instance = util.GetInstanceFromStringPath(util.GetInstanceFullName(treeView.WorkingInstance).."."..stringPath:sub(1))
				else
					Instance = util.GetInstanceFromStringPath(util.GetInstanceFullName(treeView.WorkingInstance).."."..stringPath)
				end
			end
	
			if Instance == nil then
				return ("'%s' is not recognized as a valid Instance."):format(stringPath)
			else
				for _, Child in pairs(Instance:GetChildren()) do
					context:Reply(Child.Name)
				end

				return ""
			end
		end
	end
}