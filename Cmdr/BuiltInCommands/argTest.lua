return {
	name = "argTest";
	aliases = {"t"};
	description = "Tests all the different argument types.";
	args = {
		{
			type = "string";
			name = "text";
		},
		{
			type = "number";
			name = "number";
		},
		{
			type = "integer";
			name = "integer";
		},
		{
			type = "boolean";
			name = "true/false";
			description = "Some  boolean";
			optional = true;
		},
		{
			type = "players";
			name = "Many players";
		},
		{
			type = "player";
			name = "Single player";
		},
	};
}