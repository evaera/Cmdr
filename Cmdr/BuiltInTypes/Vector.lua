local Util = require(script.Parent.Parent.Shared.Util)

local function validateVector(value, i)
	if value == nil then
		return false, ("Invalid or missing number at position %d in Vector type."):format(i)
	end

	return true
end

local vector3Type = Util.MakeSequenceType({
	ValidateEach = validateVector;
	TransformEach = tonumber;
	Constructor = Vector3.new;
	Length = 3;
})

local vector2Type = Util.MakeSequenceType({
	ValidateEach = validateVector;
	TransformEach = tonumber;
	Constructor = Vector2.new;
	Length = 2;
})

return function (cmdr)
	cmdr:RegisterType("vector3", vector3Type)
	cmdr:RegisterType("vector3s", Util.MakeListableType(vector3Type))

	cmdr:RegisterType("vector2", vector2Type)
	cmdr:RegisterType("vector2s", Util.MakeListableType(vector2Type))
end