return function(registry)
	registry:RegisterType(
		"conditionFunction",
		registry.Cmdr.Util.MakeEnumType("ConditionFunction", {
			"startsWith",
			"contains",
			"endsWith",
			"pattern",
			"equals",
			"notEquals",
			"greaterThan",
			"lessThan",
			"greaterThanOrEqual",
			"lessThanOrEqual",
			"length",
		})
	)
end
