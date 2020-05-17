local ResolvePath;
local AncestryChanged;
local DETACHED_WARNING_MESSAGE = "Warning: the current working instance has been detached from the Data Model\n"
local DevPrompt;
local treeView;
local util;

local function SetPromptCallback(prompt)
	DevPrompt = prompt
	return ("%s (%s):%s"):format(prompt, treeView.View, util.GetInstanceFullName(treeView.WorkingInstance))
end

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
		ResolvePath = require(context.Cmdr.ReplicatedRoot.Shared.ResolvePath)
		util = context.Cmdr.Util
		treeView = context:GetStore("_TreeView")

		--[[ Initializing state ]]--
		if treeView.View == nil then
			treeView.View = "Client"
			treeView.WorkingInstance = game
		end
		if context.Cmdr:GetPromptchangeCallback() == nil then
			DevPrompt = context.Cmdr:GetPrompt()
			context.Cmdr:SetPromptchangeCallback(SetPromptCallback)
		end
		
		stringPath = stringPath or "."

		--[[ Changing active instance ]]--
		if treeView.View == "Client" then
			local instance = ResolvePath(context,stringPath,treeView.WorkingInstance)
	
			if instance == nil then
				return ("'%s' is not recognized as a valid Instance."):format(stringPath)
			else

				--[[ Updating view when/if instance is reparented/destroyed ]]--
				if AncestryChanged~=nil then
					AncestryChanged:Disconnect()
				end
				AncestryChanged = instance.AncestryChanged:connect(function(_,Parent)
					context.Cmdr:SetPrompt(
						("%s (%s):%s"):format(DevPrompt, treeView.View, util.GetInstanceFullName(instance)),
						true
					)
					
					if not game:IsAncestorOf(instance) and instance ~= game then
						context:Reply(DETACHED_WARNING_MESSAGE)
					end
				end)

				treeView.WorkingInstance = instance				
				context.Cmdr:SetPrompt(
					("%s (%s):%s"):format(DevPrompt, treeView.View, util.GetInstanceFullName(instance)),
					true
				)
				return "Directory changed to "..util.GetInstanceFullName(treeView.WorkingInstance)
			end
		else
			return nil
		end
	end
}