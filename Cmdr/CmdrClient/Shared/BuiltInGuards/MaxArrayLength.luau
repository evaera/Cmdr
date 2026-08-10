return function(index: number, maxCount: number)
	return function(context: any): string?
		const argContext = context:GetArgument(index)
		const value = argContext and argContext:GetValue()

		return if typeof(value) == "table" and #value > maxCount
			then `Argument #{index} exceeds the maximum allowed limit of {maxCount} items.`
			else nil
	end
end
