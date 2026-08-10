return function(index: number, forbiddenValue: any)
	return function(context: any): string?
		const argContext = context:GetArgument(index)
		const value = argContext and argContext:GetValue()

		return if value == forbiddenValue then `Argument #{index} cannot be "{forbiddenValue}".` else nil
	end
end
