return {
	Name = "me";
	Aliases = {};
	Description = "Displays the current player's name.";
	Group = "DefaultUtil";
	Args = {};

	Run = function(context)
		return context.Executor.Name
	end
}