local AncestryChanged;

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
	ClientRun = function(context, stringPath)
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
				local StartingInstance;
				if not game:IsAncestorOf(treeView.WorkingInstance) and treeView.WorkingInstance ~= game then --Instance is in a detached state from the datamodel
					context:Reply("The current working instance has been destroyed, unexpected behavior may occur!\n")
					StartingInstance = util.GetInstanceRootAncestor(treeView.WorkingInstance)
				end

				if stringPath == ".." then -- Move up an Instance
					Instance = treeView.WorkingInstance.Parent
				elseif stringPath:sub(1,1) == "." then --Instance with reserved word specified
					Instance = util.GetInstanceFromStringPath(util.GetInstanceFullName(treeView.WorkingInstance)..stringPath, StartingInstance)
				else
					Instance = util.GetInstanceFromStringPath(util.GetInstanceFullName(treeView.WorkingInstance).."."..stringPath, StartingInstance)
				end
			end
	
			if Instance == nil then
				return ("'%s' is not recognized as a valid Instance."):format(stringPath)
			else

				--[[ Updating view when/if instance is reparented/destroyed ]]--
				if AncestryChanged~=nil then
					AncestryChanged:Disconnect()
				end
				AncestryChanged = Instance.AncestryChanged:connect(function(_,Parent)
					context.Cmdr:SetPrompt(("%s.%s:%s"):format(game.Name, treeView.View, util.GetInstanceFullName(Instance)))
					if not game:IsAncestorOf(Instance) and Instance ~= game then
						context:Reply("The current working instance has been destroyed, unexpected behavior may occur!\n")
					end
				end)

				treeView.WorkingInstance = Instance				
				context.Cmdr:SetPrompt(("%s.%s:%s"):format(game.Name, treeView.View, util.GetInstanceFullName(Instance)))
				return "Directory changed to "..util.GetInstanceFullName(treeView.WorkingInstance)
			end
		else
			return nil
		end
	end
}