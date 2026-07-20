return {
	Name = "announce",
	Aliases = { "m" },
	Description = "Makes a server-wide announcement.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "string",
			Name = "Text",
			Description = "The announcement text",
		},
	},
}
