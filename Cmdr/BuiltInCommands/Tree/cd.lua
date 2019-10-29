return {
	Name = "cd",
	Description = "Changes the current working instance to the specified instance.",
	Group = "DefaultTree",
	Args = {
		{
			Type = "string",
			Name = "Instance",
			Description = "The instance to change to. Can be a relative path or a full path."
		}
	},
	AutoExec={
		"cd game"
	},
	Run = function(context, stringPath)
		local util = context.Cmdr.Util
		local treeView = context:GetStore("_TreeView")

		--[[ Initializing state ]]--
		if treeView.View == nil then
			treeView.View = "Client"
		end

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
				treeView.WorkingInstance = Instance
				context.Cmdr:SetPrompt(("%s.%s:%s"):format(game.Name, treeView.View, util.GetInstanceFullName(Instance)))
				return "Directory changed to "..util.GetInstanceFullName(treeView.WorkingInstance)
			end
		end
	end
}