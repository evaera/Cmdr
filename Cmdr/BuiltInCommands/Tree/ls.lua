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
	ClientRun = function(context, stringPath)
		local util = context.Cmdr.Util
		local treeView = context:GetStore("_TreeView")
		stringPath = stringPath or ""

		--[[ Changing active instance ]]--
		if treeView.View == "Client" then
			local Instance;
			
			if string.split(stringPath,".")[1] == "game" then -- Absolute path specified
				Instance = util.GetInstanceFromStringPath(stringPath)
			else -- Relative path specified
				local StartingInstance;
				if not game:IsAncestorOf(treeView.WorkingInstance) and treeView.WorkingInstance ~= game then --Instance is in a detached state from the datamodel
					context:Reply("The current working instance has been destroyed, unexpected behavior may occur!\n")
					StartingInstance = util.GetInstanceRootAncestor(treeView.WorkingInstance)
					context.Cmdr:SetPrompt(("%s.%s:%s"):format(game.Name, treeView.View, util.GetInstanceFullName(treeView.WorkingInstance)))
				end

				if stringPath == ".." then -- Move up an Instance
					Instance = treeView.WorkingInstance.Parent
				elseif stringPath:sub(1,1) == "." then --Instance with reserved word specified
					Instance = util.GetInstanceFromStringPath(util.GetInstanceFullName(treeView.WorkingInstance)..stringPath, StartingInstance)
				else
					Instance = util.GetInstanceFromStringPath(util.GetInstanceFullName(treeView.WorkingInstance).."."..stringPath, StartingInstance)
				end
			end
	
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