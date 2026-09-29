const ContextActionService = game:GetService("ContextActionService")

return {
	Name = "unbind",
	Description = "Unbinds an input previously bound with Bind.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "userInput @ player",
			Name = "Input/Key",
			Description = "The key or input type you'd like to unbind.",
		},
	},

	ClientRun = function(context: any, bind: Enum.UserInputType | Enum.KeyCode | Player): string
		const binds = context:GetStore("CMDR_Binds")
		const existingBind = binds[bind]

		if not existingBind then
			return "That input wasn't bound."
		end

		if type(existingBind) == "string" then
			ContextActionService:UnbindAction(existingBind)
		end

		binds[bind] = nil
		return "Unbound command from input."
	end,
}
