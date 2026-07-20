local Util = require(script.Parent.Parent.Shared.Util)

local AXES = { "X", "Y", "Z" }

local function validateVector(value, index)
	if value == nil then
		return false, `Invalid or missing number at position {index} in Vector type.`
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

local positionVector3Type = Util.MakeSequenceType({
	Transform = function(text, executor)
		local character = executor.Character
		local currentPosition = if character then character:GetPivot().Position else Vector3.zero

		return Util.Map(Util.SplitPrioritizedDelimeter(text, { ",", "%s" }), function(value, index)
			if value:sub(1, 1) ~= "~" then
				return tonumber(value)
			end

			local axis = AXES[index]
			local currentComponent = if axis then currentPosition[axis] else 0

			local offset = tonumber(value:sub(2))

			return if value == "~" then currentComponent elseif offset then currentComponent + offset else nil
		end)
	end,
	ValidateEach = validateVector,
	Constructor = Vector3.new,
	Length = 3,
})

return function(cmdr)
	cmdr:RegisterType("vector3", vector3Type)
	cmdr:RegisterType("vector3s", Util.MakeListableType(vector3Type))

	cmdr:RegisterType("vector2", vector2Type)
	cmdr:RegisterType("vector2s", Util.MakeListableType(vector2Type))

	cmdr:RegisterType("positionVector3", positionVector3Type)
	cmdr:RegisterType("positionVector3s", Util.MakeListableType(positionVector3Type))
end
