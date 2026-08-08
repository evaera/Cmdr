return function(registry: any)
	const typeType = {
		Transform = function(text: string): { string }
			const findType = registry.Cmdr.Util.MakeFuzzyFinder(registry:GetTypeNames())
			return findType(text)
		end,

		Validate = function(types: { string }): (boolean, string?)
			return #types > 0, "No type with that name could be found."
		end,

		Autocomplete = function(types: { string }): { string }
			return types
		end,

		Parse = function(types: { string }): string?
			return types[1]
		end,
	}

	registry:RegisterType("type", typeType)
	registry:RegisterType("types", registry.Cmdr.Util.MakeListableType(typeType))
end
