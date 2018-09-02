return {
	Name = "argTest";
	Aliases = {"t"};
	Description = "Tests all the different argument Types.";
	Args = {
		{
			Type = "string";
			Name = "text";
		},
		{
			Type = "number";
			Name = "number";
		},
		{
			Type = "integer";
			Name = "integer";
		},
		{
			Type = "boolean";
			Name = "true/false";
			Description = "Some  boolean";
			Optional = true;
		},
		{
			Type = "players";
			Name = "Many players";
		},
		{
			Type = "player";
			Name = "Single player";
		},
	};
}