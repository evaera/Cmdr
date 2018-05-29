local Util = require(script.Parent.Parent.Shared.Util)

local stringType = {
	validate = function (value)
		return value ~= nil
	end;

	parse = function (value)
		return tostring(value)
	end;
}

local numberType = {
	transform = function (text)
		return tonumber(text)
	end;

	validate = function (value)
		return value ~= nil
	end;

	parse = function (value)
		return value
	end;
}

local intType = {
	transform = function (text)
		return tonumber(text)
	end;

	validate = function (value)
		return value ~= nil and value == math.floor(value), "Only whole numbers are valid."
	end;

	parse = function (value)
		return value
	end
}

local boolType do
	local truthy = Util.MakeDictionary({"true", "t", "yes", "y", "on", "enable", "enabled", "1", "+"});
	local falsy = Util.MakeDictionary({"false"; "f"; "no"; "n"; "off"; "disable"; "disabled"; "0"; "-"});

	boolType = {
		transform = function (text)
			return text:lower()
		end;

		validate = function (value)
			return truthy[value] ~= nil or falsy[value] ~= nil, "Please use true/yes/on or false/no/off."
		end;

		parse = function (value)
			if truthy[value] then
				return true
			elseif falsy[value] then
				return false
			else
				error("Unknown boolean value.")
			end
		end;
	}
end

return function (cmdr)
	cmdr:RegisterType("string", stringType)
	cmdr:RegisterType("number", numberType)
	cmdr:RegisterType("integer", intType)
	cmdr:RegisterType("boolean", boolType)
end