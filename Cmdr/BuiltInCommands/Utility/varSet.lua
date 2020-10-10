return {
	Name = "var=";
	Aliases = {};
	Description = "Sets a stored value.";
	Group = "DefaultUtil";
	Args = {
		{
			Type = "storedKey";
			Name = "Key";
			Description = "The key to set, saved in your user data store. Keys prefixed with . are not saved. Keys prefixed with $ are game-wide. Keys prefixed with $. are game-wide and non-saved.";
		},
		{
			Type = "string";
			Name = "Value";
			Description = "Value or values to set."
		}
	};

	ClientRun = function(context, key, value)
		context:GetStore("vars_used")[key] = true

		if key:sub(1, 1) == "$" then
			-- Global keys always need to run server side.
			return
		end

		if key:sub(1, 1) == "." then
			context:GetStore("var_local")[key] = value

			if type(value) == "table" then
				return table.concat(value, ",") or ""
			end

			return value or ""
		end
	end
}