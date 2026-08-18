const RunService = game:GetService("RunService")

return function(index: number)
	return function(context: any): string?
		const argContext = context:GetArgument(index)
		local key = if argContext then argContext:GetValue() else nil

		if type(key) ~= "string" then
			return nil
		end

		local saved = true

		if key:sub(1, 1) == "$" then
			key = key:sub(2)
		end

		if key:sub(1, 1) == "." then
			saved = false
		end

		if not saved then
			return nil
		end

		if RunService:IsClient() then
			if game.PlaceId == 0 then
				return "# You must publish this place to the web to use saved keys."
			end
		elseif not context.Cmdr.Util.GetDataStore() then
			return "# You must publish this place to the web to use saved keys."
		end

		return nil
	end
end
