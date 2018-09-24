return function (registry)
	registry:RegisterType("conditionFunction", registry.Cmdr.Util.MakeEnumType("ConditionFunction", {"startsWith"}))
end
