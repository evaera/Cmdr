return function(index: number, maxLength: number)
	return function(context: any): string?
		const argContext = context:GetArgument(index)
		const value = argContext and argContext:GetValue()

		return if typeof(value) == "string" and #value > maxLength
			then `Argument #{index} exceeds the maximum character limit of {maxLength}`
			else nil
	end
end
