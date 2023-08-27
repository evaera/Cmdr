return {
	Name = "echo",
	Aliases = { "=" },
	Description = "Echoes your text back to you.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "string",
			Name = "Text",
			Description = "The text.",
		},
	},

	ClientRun = function(_, text)
		return text
	end,
}
