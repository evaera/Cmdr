const combinedInputEnums: { EnumItem } = {}
for _, enum: Enum.UserInputType in ipairs(Enum.UserInputType:GetEnumItems()) do
	combinedInputEnums[#combinedInputEnums + 1] = enum
end

for _, enum: Enum.KeyCode in ipairs(Enum.KeyCode:GetEnumItems()) do
	combinedInputEnums[#combinedInputEnums + 1] = enum
end

return function(registry: any)
	const userInputType = {
		Transform = function(text: string): { EnumItem }
			const findEnum = registry.Cmdr.Util.MakeFuzzyFinder(combinedInputEnums)
			return findEnum(text)
		end,

		Validate = function(enums: { EnumItem }): (boolean, string?)
			return #enums > 0
		end,

		Autocomplete = function(enums: { EnumItem }): { string }
			return registry.Cmdr.Util.GetNames(enums)
		end,

		Parse = function(enums: { EnumItem }): EnumItem?
			return enums[1]
		end,
	}

	registry:RegisterType("userInput", userInputType)
	registry:RegisterType("userInputs", registry.Cmdr.Util.MakeListableType(userInputType))
end
