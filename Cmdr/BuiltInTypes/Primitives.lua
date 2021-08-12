local Util = require(script.Parent.Parent.Shared.Util)

local stringType = {
	Validate = function (value)
		return value ~= nil
	end;

	Parse = function (value)
		return tostring(value)
	end;
}

local numberType = {
	Transform = function (text)
		return tonumber(text)
	end;

	Validate = function (value)
		return value ~= nil
	end;

	Parse = function (value)
		return value
	end;
}

local intType = {
	Transform = function (text)
		return tonumber(text)
	end;

	Validate = function (value)
		return value ~= nil and value == math.floor(value), "Only whole numbers are valid."
	end;

	Parse = function (value)
		return value
	end
}

local boolType do
	local booleanEnum = Util.MakeEnumType("boolean", {"true", "false"})

	booleanEnum.Parse = function(value)
		if value == "true" then
			return true
		elseif value == "false" then
			return false
		else
			return nil
		end
	end

	boolType = booleanEnum
end

return function (cmdr)
	cmdr:RegisterType("string", stringType)
	cmdr:RegisterType("number", numberType)
	cmdr:RegisterType("integer", intType)
	cmdr:RegisterType("boolean", boolType)

	cmdr:RegisterType("strings", Util.MakeListableType(stringType))
	cmdr:RegisterType("numbers", Util.MakeListableType(numberType))
	cmdr:RegisterType("integers", Util.MakeListableType(intType))
	cmdr:RegisterType("booleans", Util.MakeListableType(boolType))
end
