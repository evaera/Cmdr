return {
	name = "announce";
	aliases = {"m"};
	description = "Makes a server-wide announcement.";
	args = {
		{
			type = "string";
			name = "text";
			description = "The announcement text.";
		},
	};
}