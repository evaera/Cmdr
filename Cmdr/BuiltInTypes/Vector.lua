local Util = require(script.Parent.Parent.Shared.Util)

local function validateVector(value, i)
	if value == nil then
		return false, `Invalid or missing number at position {i} in Vector type.`
	end

	return true
end

local vector3Type = Util.MakeSequenceType({
	ValidateEach = validateVector,
	TransformEach = tonumber,
	Constructor = Vector3.new,
	Length = 3,
})

local vector2Type = Util.MakeSequenceType({
	ValidateEach = validateVector,
	TransformEach = tonumber,
	Constructor = Vector2.new,
	Length = 2,
})

local relativeVector3Type = {
	Transform = function(text, executor)
		local currentPosition = executor.Character:GetPivot().Position

		return Util.Map(Util.SplitPrioritizedDelimeter(text, { ",", "%s" }), function(value, index)
			if value:sub(1, 1) ~= "~" then
				return tonumber(value)
			end

			local currentComponent =
				currentPosition[if index == 1 then "X" elseif index == 2 then "Y" elseif index == 3 then "Z" else 0]

			return currentComponent + if value == "~" then 0 else tonumber(value:sub(2))
		end)
	end,

	Validate = function(components)
		if #components > 3 then
			return false, "Maximum of 3 values allowed in sequence"
		end

		for i = 1, 3 do
			local valid, reason = validateVector(components[i], i)

			if not valid then
				return false, reason
			end
		end

		return true
	end,

	Parse = function(components)
		return Vector3.new(unpack(components))
	end,
}

return function(cmdr)
	cmdr:RegisterType("vector3", vector3Type)
	cmdr:RegisterType("vector3s", Util.MakeListableType(vector3Type))

	cmdr:RegisterType("vector2", vector2Type)
	cmdr:RegisterType("vector2s", Util.MakeListableType(vector2Type))

	cmdr:RegisterType("relativeVector3", relativeVector3Type)
	cmdr:RegisterType("relativeVector3s", Util.MakeListableType(relativeVector3Type))
end
