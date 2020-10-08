local Util = require(script.Parent.Parent.Shared.Util)

return function (cmdr)
	local typeType = {
		Transform = function (text)
			local findCommand = Util.MakeFuzzyFinder(cmdr:GetTypeNames())

			return findCommand(text)
		end;

		Validate = function (commands)
			return #commands > 0, "No type with that name could be found."
		end;

		Autocomplete = function (commands)
			return commands
		end;

		Parse = function (commands)
			return commands[1]
		end;
	}

	cmdr:RegisterType("type", typeType)
	cmdr:RegisterType("types", Util.MakeListableType(typeType))
end