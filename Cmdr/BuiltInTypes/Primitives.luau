const TRUTHY_VALUES = { "true", "t", "yes", "y", "on", "enable", "enabled", "1", "+" }
const FALSY_VALUES = { "false", "f", "no", "n", "off", "disable", "disabled", "0", "-" }

type NumberTransformer = {
	Transform: (text: string) -> number?,
	Validate: (value: number?) -> (boolean, string?),
	Parse: (value: number) -> number,
}

const stringType = {
	Validate = function(value: unknown): (boolean, string?)
		return value ~= nil
	end,

	Parse = function(value: unknown): string
		return tostring(value)
	end,
}

const numberType: NumberTransformer = {
	Transform = function(text: string): number?
		return tonumber(text)
	end,

	Validate = function(value: number?): (boolean, string?)
		return value ~= nil
	end,

	Parse = function(value: number): number
		return value
	end,
}

const intType: NumberTransformer = {
	Transform = function(text: string): number?
		return tonumber(text)
	end,

	Validate = function(value: number?): (boolean, string?)
		return value ~= nil and value == math.floor(value), "Only whole numbers are valid."
	end,

	Parse = function(value: number): number
		return value
	end,
}

const positiveIntType: NumberTransformer = {
	Transform = function(text: string): number?
		return tonumber(text)
	end,

	Validate = function(value: number?): (boolean, string?)
		return value ~= nil and value == math.floor(value) and value > 0, "Only positive whole numbers are valid."
	end,

	Parse = function(value: number): number
		return value
	end,
}

const nonNegativeIntType: NumberTransformer = {
	Transform = function(text: string): number?
		return tonumber(text)
	end,

	Validate = function(value: number?): (boolean, string?)
		return value ~= nil and value == math.floor(value) and value >= 0, "Only non-negative whole numbers are valid."
	end,

	Parse = function(value: number): number
		return value
	end,
}

const byteType: NumberTransformer = {
	Transform = function(text: string): number?
		return tonumber(text)
	end,

	Validate = function(value: number?): (boolean, string?)
		return value ~= nil and value == math.floor(value) and value >= 0 and value <= 255, "Only bytes are valid."
	end,

	Parse = function(value: number): number
		return value
	end,
}

const digitType: NumberTransformer = {
	Transform = function(text: string): number?
		return tonumber(text)
	end,

	Validate = function(value: number?): (boolean, string?)
		return value ~= nil and value == math.floor(value) and value >= 0 and value <= 9, "Only digits are valid."
	end,

	Parse = function(value: number): number
		return value
	end,
}

return function(registry: any)
	const truthy: { [string]: boolean } = registry.Cmdr.Util.MakeDictionary(TRUTHY_VALUES)
	const falsy: { [string]: boolean } = registry.Cmdr.Util.MakeDictionary(FALSY_VALUES)

	const boolType = {
		Transform = function(text: string): string
			return text:lower()
		end,

		Validate = function(value: string): (boolean, string?)
			return truthy[value] ~= nil or falsy[value] ~= nil, "Please use true/yes/on or false/no/off."
		end,

		Parse = function(value: string): boolean?
			if truthy[value] then
				return true
			elseif falsy[value] then
				return false
			end

			return nil
		end,
	}

	registry:RegisterType("string", stringType)
	registry:RegisterType("number", numberType)
	registry:RegisterType("integer", intType)
	registry:RegisterType("positiveInteger", positiveIntType)
	registry:RegisterType("nonNegativeInteger", nonNegativeIntType)
	registry:RegisterType("byte", byteType)
	registry:RegisterType("digit", digitType)
	registry:RegisterType("boolean", boolType)

	registry:RegisterType("strings", registry.Cmdr.Util.MakeListableType(stringType))
	registry:RegisterType("numbers", registry.Cmdr.Util.MakeListableType(numberType))
	registry:RegisterType("integers", registry.Cmdr.Util.MakeListableType(intType))
	registry:RegisterType("positiveIntegers", registry.Cmdr.Util.MakeListableType(positiveIntType))
	registry:RegisterType("nonNegativeIntegers", registry.Cmdr.Util.MakeListableType(nonNegativeIntType))
	registry:RegisterType("bytes", registry.Cmdr.Util.MakeListableType(byteType))
	registry:RegisterType("digits", registry.Cmdr.Util.MakeListableType(digitType))
	registry:RegisterType("booleans", registry.Cmdr.Util.MakeListableType(boolType))
end
