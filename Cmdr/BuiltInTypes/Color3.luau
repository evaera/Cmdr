const function parseHexDigit(x: string?): number?
	if not x then
		return nil
	end

	if #x == 1 then
		x = `{x}{x}`
	end

	return tonumber(x, 16)
end

return function(registry: any)
	const color3Type = registry.Cmdr.Util.MakeSequenceType({
		Prefixes = "# hexColor3 ! brickColor3",
		ValidateEach = function(value: number?, index: number): (boolean, string?)
			if value == nil then
				return false, `Invalid or missing number at position {index} in Color3 type.`
			elseif value < 0 or value > 255 then
				return false, `Number out of acceptable range 0-255 at position {index} in Color3 type.`
			elseif value % 1 ~= 0 then
				return false, `Number is not an integer at position {index} in Color3 type.`
			end

			return true
		end,

		TransformEach = function(value: string): number?
			return tonumber(value)
		end,

		Constructor = Color3.fromRGB,
		Length = 3,
	})

	const hexColor3Type = {
		Transform = function(text: string): (number?, number?, number?)
			const r, g, b = text:match("^#?(%x%x?)(%x%x?)(%x%x?)$")
			return registry.Cmdr.Util.Each(parseHexDigit, r, g, b)
		end,

		Validate = function(r: number?, g: number?, b: number?): (boolean, string?)
			return r ~= nil and g ~= nil and b ~= nil, "Invalid hex color"
		end,

		Parse = function(r: number, g: number, b: number): Color3
			return Color3.fromRGB(r, g, b)
		end,
	}

	registry:RegisterType("color3", color3Type)
	registry:RegisterType("color3s", registry.Cmdr.Util.MakeListableType(color3Type, { Prefixes = "# hexColor3s ! brickColor3s" }))

	registry:RegisterType("hexColor3", hexColor3Type)
	registry:RegisterType("hexColor3s", registry.Cmdr.Util.MakeListableType(hexColor3Type))
end
