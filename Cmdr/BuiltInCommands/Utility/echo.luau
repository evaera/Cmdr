return {
	Name = "echo",
	Aliases = { "=" },
	Description = "Echoes your text back to you.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "string",
			Name = "Text",
			Description = "The text to echo.",
		},
	},

	ClientRun = function(_, text: string): string
		return text
	end,
}
