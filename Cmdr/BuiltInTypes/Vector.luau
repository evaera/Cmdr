const AXES: { string } = { "X", "Y", "Z" }

const function validateVector(value: number?, index: number): (boolean, string?)
	if value == nil then
		return false, `Invalid or missing number at position {index} in Vector type.`
	end

	return true
end

return function(registry: any)
	const vector3Type = registry.Cmdr.Util.MakeSequenceType({
		ValidateEach = validateVector,
		TransformEach = tonumber,
		Constructor = Vector3.new,
		Length = 3,
	})

	const vector2Type = registry.Cmdr.Util.MakeSequenceType({
		ValidateEach = validateVector,
		TransformEach = tonumber,
		Constructor = Vector2.new,
		Length = 2,
	})

	const positionVector3Type = registry.Cmdr.Util.MakeSequenceType({
		Transform = function(text: string, executor: Player): { number? }
			const character = executor.Character
			const currentPosition = if character then character:GetPivot().Position else Vector3.zero

			return registry.Cmdr.Util.Map(
				registry.Cmdr.Util.SplitPrioritizedDelimeter(text, { ",", "%s" }),
				function(value: string, index: number): number?
					if value:sub(1, 1) ~= "~" then
						return tonumber(value)
					end

					const axis = AXES[index]
					const currentComponent = if axis then currentPosition[axis] else 0
					const offset = tonumber(value:sub(2))
					return if value == "~" then currentComponent elseif offset then currentComponent + offset else nil
				end
			)
		end,
		ValidateEach = validateVector,
		Constructor = Vector3.new,
		Length = 3,
	})

	registry:RegisterType("vector3", vector3Type)
	registry:RegisterType("vector3s", registry.Cmdr.Util.MakeListableType(vector3Type))

	registry:RegisterType("vector2", vector2Type)
	registry:RegisterType("vector2s", registry.Cmdr.Util.MakeListableType(vector2Type))

	registry:RegisterType("positionVector3", positionVector3Type)
	registry:RegisterType("positionVector3s", registry.Cmdr.Util.MakeListableType(positionVector3Type))
end
