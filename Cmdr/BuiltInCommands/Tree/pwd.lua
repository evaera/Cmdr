return {
	Name = "pwd",
	Description = "Displays the path to the current working instance.",
	Group = "DefaultTree",
	Args = {},
	ClientRun = function(context)
		local util = context.Cmdr.Util
		local treeView = context:GetStore("_TreeView")

		if treeView.View == "Client" then
			return util.GetInstanceFullName(treeView.WorkingInstance)
		end
	end
}
