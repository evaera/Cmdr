return function(context,stringPath,RelativeInstance)
	local util = context.Cmdr.Util

	local instance;

	if string.split(stringPath,".")[1] == "game" then -- Absolute path specified
		instance = util.GetInstanceFromStringPath(stringPath)
	else -- Relative path specified
		local StartingInstance;
		if not game:IsAncestorOf(RelativeInstance) and RelativeInstance ~= game then --Instance is in a detached state from the datamodel
			StartingInstance = util.GetInstanceRootAncestor(RelativeInstance)
			context:Reply("Warning: the current working instance has been detached from the Data Model\n")
		end

		if stringPath == ".." then -- Move up an Instance
			instance = RelativeInstance.Parent
		elseif stringPath:sub(1,1) == "." then --Instance with reserved word specified
			instance = util.GetInstanceFromStringPath(util.GetInstanceFullName(RelativeInstance)..stringPath, StartingInstance)
		else
			instance = util.GetInstanceFromStringPath(util.GetInstanceFullName(RelativeInstance).."."..stringPath, StartingInstance)
		end
	end

	return instance
end