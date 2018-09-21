local Util = require(script.Parent.Parent.Shared.Util)

return function (cmdr)
	local commandType = {
		Transform = function (text)
			local findCommand = Util.MakeFuzzyFinder(cmdr:GetCommandsAsStrings())

			return findCommand(text)
		end;

		Validate = function (commands)
			return #commands > 0, "No command with that name could be found."
		end;

		Autocomplete = function (commands)
			return commands
		end;

		Parse = function (commands)
			return commands[1]
		end;
	}

	cmdr:RegisterType("command", commandType)
	cmdr:RegisterType("commands", Util.MakeListableType(commandType))
end