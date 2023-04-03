return {
	Name = "math";
	Aliases = {};
	Description = "Perform a math operation on 2 values.";
	Group = "DefaultUtil";
	AutoExec = {
		"alias \"+|Perform an addition.\" math $1{number|Number} + $2{number|Number}";
		"alias \"-|Perform a subtraction.\" math $1{number|Number} - $2{number|Number}";
		"alias \"*|Perform a multiplication.\" math $1{number|Number} * $2{number|Number}";
		"alias \"/|Perform a division.\" math $1{number|Number} / $2{number|Number}";
		"alias \"**|Perform an exponentiation.\" math *$1{number| * umber} $2{number|Number}";
		"alias \"%|Perform a modulus.\" math $1{number|Number} % $2{number|Number}";
	};
	Args = {
		{
			Type = "number";
			Name = "Value";
			Description = "A number value."
		};
		{
			Type = "mathOperator";
			Name = "Operation";
			Description = "A math operation."
		};
		{
			Type = "number";
			Name = "Value";
			Description = "A number value."
		}
	};

	ClientRun = function(_, a, operation, b)
		return operation.Perform(a, b)
	end
}
