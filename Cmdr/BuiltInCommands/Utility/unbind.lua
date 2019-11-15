return {
	Name = "unbind";
	Aliases = {};
	Description = "Unbinds an input previously bound with Bind";
	Group = "DefaultUtil";
	Args = {
		{
			Type = "userInput ! bindableResource @ player";
			Name = "Input/Key";
			Description = "The key or input type you'd like to unbind."
		}
	};

	ClientRun = function(context, inputEnum)
		local binds = context:GetStore("CMDR_Binds")

		if binds[inputEnum] then
			binds[inputEnum]:Disconnect()
			binds[inputEnum] = nil
			return "Unbound command from input."
		else
			return "That input wasn't bound."
		end
	end
}