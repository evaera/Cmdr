local Util = require(script.Parent.Parent.Shared.Util)

local color3Type = Util.MakeSequenceType({
	Prefixes = "# hexColor3 ! brickColor3";
	ValidateEach = function(value, i)
		if value == nil then
			return false, ("Invalid or missing number at position %d in Color3 type."):format(i)
		elseif value < 0 or value > 255 then
			return false, ("Number out of acceptable range 0-255 at position %d in Color3 type."):format(i)
		elseif value % 1 ~= 0 then
			return false, ("Number is not an integer at position %d in Color3 type."):format(i)
		end

		return true
	end;
	TransformEach = tonumber;
	Constructor = Color3.fromRGB;
	Length = 3;
})

local function parseHexDigit(x)
	if #x == 1 then
		x = x .. x
	end

	return tonumber(x, 16)
end

local hexColor3Type = {
	Transform = function(text)
		local r, g, b = text:match("^#?(%x%x?)(%x%x?)(%x%x?)$")
		return Util.Each(parseHexDigit, r, g, b)
	end;

	Validate = function(r, g, b)
		return r ~= nil and g ~= nil and b ~= nil, "Invalid hex color"
	end;

	Parse = function(...)
		return Color3.fromRGB(...)
	end;
}

return function (cmdr)
	cmdr:RegisterType("color3", color3Type)
	cmdr:RegisterType("color3s", Util.MakeListableType(color3Type, {
		Prefixes = "# hexColor3s ! brickColor3s"
	}))

	cmdr:RegisterType("hexColor3", hexColor3Type)
	cmdr:RegisterType("hexColor3s", Util.MakeListableType(hexColor3Type))
end
