local Util = require(script.Parent.Parent.Shared.Util)

local VALID_STORED_KEY_NAME_PATTERNS = {
	"^%a%w*$",
	"^%$%a%w*$",
	"^%.%a%w*$",
	"^%$%.%a%w*$",
}

local storedKeyType = {
	Validate = function(text)
		for _, pattern in ipairs(VALID_STORED_KEY_NAME_PATTERNS) do
			if text:match(pattern) then
				return true
			end
		end

		return false, "Key names must start with an optional modifier: . $ or $. and must begin with a letter."
	end;

	Parse = function(text)
		return text
	end;
}

return function (cmdr)
	cmdr:RegisterType("storedKey", storedKeyType)
	cmdr:RegisterType("storedKeys", Util.MakeListableType(storedKeyType))
end
