return function(registry: any)
	const commandType = {
		Transform = function(text: string): { [number]: string }
			const findCommand = registry.Cmdr.Util.MakeFuzzyFinder(registry:GetCommandNames())
			return findCommand(text)
		end,

		Validate = function(commands: { [number]: string }): (boolean, string?)
			return #commands > 0, "No command with that name could be found."
		end,

		Autocomplete = function(commands: { [number]: string }): { [number]: string }
			return commands
		end,

		Parse = function(commands: { [number]: string }): string
			return commands[1]
		end,
	}

	registry:RegisterType("command", commandType)
	registry:RegisterType("commands", registry.Cmdr.Util.MakeListableType(commandType))
end
