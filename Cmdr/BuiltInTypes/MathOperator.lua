local Util = require(script.Parent.Parent.Shared.Util)
local ValidOps = {"/", "*", "+", "-", "%", "^"}

local mathOperatorType = {
	Validate = function(text)
		if table.find(ValidOps, text) then
			return true
		end
		
		return false, "Operator must be one of: / * ^ + - %"
	end;
	
	Parse = function(text)
		return text
	end;
}

return function (cmdr)
	cmdr:RegisterType("mathOperator", mathOperatorType)
	cmdr:RegisterType("mathOperators", Util.MakeListableType(mathOperatorType))
end
