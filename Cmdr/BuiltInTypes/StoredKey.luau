const VALID_STORED_KEY_NAME_PATTERNS: { string } = {
	"^%a[%w_]*$",
	"^%$%a[%w_]*$",
	"^%.%a[%w_]*$",
	"^%$%.%a[%w_]*$",
}

return function(registry: any)
	const storedKeyType = {
		Autocomplete = function(text: string): { string }
			const store = registry:GetStore("vars_used") or {}
			const find = registry.Cmdr.Util.MakeFuzzyFinder(registry.Cmdr.Util.DictionaryKeys(store))
			return find(text)
		end,

		Validate = function(text: string): (boolean, string?)
			for _, pattern: string in ipairs(VALID_STORED_KEY_NAME_PATTERNS) do
				if text:match(pattern) then
					return true
				end
			end

			return false, "Key names must start with an optional modifier: . $ or $. and must begin with a letter."
		end,

		Parse = function(text: string): string
			return text
		end,
	}

	registry:RegisterType("storedKey", storedKeyType)
	registry:RegisterType("storedKeys", registry.Cmdr.Util.MakeListableType(storedKeyType))
end
