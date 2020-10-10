return {
	Name = "math";
	Aliases = {};
	Description = "Perform a math operation on 2 values.";
	Group = "DefaultUtil";
	AutoExec = {
		"alias \"+|Perform a addition.\" math + $1{number|Number} $2{number|Number}";
		"alias \"-|Perform a subtraction.\" math - $1{number|Number} $2{number|Number}";
		"alias \"%|Perform a modulo.\" math % $1{number|Number} $2{number|Number}";
		"alias \"*|Perform a multiplication.\" math * $1{number|Number} $2{number|Number}";
		"alias \"/|Perform a division.\" math / $1{number|Number} $2{number|Number}";
	};
	Args = {
		{
			Type = "mathOperator";
			Name = "Operation";
			Description = "A math operation (/ * ^ + - %)"
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
		end
		return tostring(result)
	end
}