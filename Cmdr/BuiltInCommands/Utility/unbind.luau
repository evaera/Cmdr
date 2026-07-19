return {
	Name = "unbind",
	Aliases = {},
	Description = "Unbinds an input previously bound with Bind",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "userInput ! bindableResource @ player",
			Name = "Input/Key",
			Description = "The key or input type you'd like to unbind.",
		},
	},

	ClientRun = function(context, bind)
		local binds = context:GetStore("CMDR_Binds")

		if binds[bind] then
			if typeof(binds[bind]) == "RBXScriptConnection" then
				binds[bind]:Disconnect()
			end

			binds[bind] = nil
			return "Unbound command from input."
		else
			return "That input wasn't bound."
		end
	end,
}
