return {
	Name = "var";
	Aliases = {};
	Description = "Gets a stored variable.";
	Group = "DefaultUtil";
	Args = {
		{
			Type = "storedKey";
			Name = "Key";
			Description = "The key to get, retrieved from your user data store. Keys prefixed with . are not saved. Keys prefixed with $ are game-wide. Keys prefixed with $. are game-wide and non-saved.";
		}
	};

	ClientRun = function(context, key)
		context:GetStore("vars_used")[key] = true

		if key:sub(1, 1) == "$" then
			-- Global keys always need to run server side.
			return
		end

		if key:sub(1, 1) == "." then
			local value = context:GetStore("var_local")[key]

			if type(value) == "table" then
				return table.concat(value, ",") or ""
			end

			return value or ""
		end
	end
}