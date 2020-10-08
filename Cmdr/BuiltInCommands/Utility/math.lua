return {
	Name = "math";
	Aliases = {};
	Description = "Perform a math operation on 2 values.";
	Group = "DefaultUtil";
	Args = {
		{
			Type = "string";
			Name = "Operation";
			Description = "A math operation (/ * ^ + - % rand)"
		},
		{
			Type = "number";
			Name = "Value";
			Description = "A number value"
		},
		{
			Type = "number";
			Name = "Value";
			Description = "A number value"
		},
	};
	
	ClientRun = function(_, op, value1, value2)
		local result = ""
		if op == "/" then
			result = value1 / value2
		elseif op == "*" then
			result = value1 * value2
		elseif op == "^" then
			result = value1 ^ value2
		elseif op == "+" then
			result = value1 + value2
		elseif op == "-" then
			result = value1 - value2
		elseif op == "%" then
			result = value1 % value2
		elseif op == "rand" and value1 <= value2 then
			result = math.random(value1, value2)
		end
		return tostring(result)
	end
}