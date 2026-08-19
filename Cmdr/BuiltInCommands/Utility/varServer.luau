return function(context: any, key: string): string
	local gameWide = false
	local saved = true

	if key:sub(1, 1) == "$" then
		key = key:sub(2)
		gameWide = true
	end

	if key:sub(1, 1) == "." then
		key = key:sub(2)
		saved = false
	end

	const namespace = `var_{if gameWide then "global" else tostring(context.Executor.UserId)}`

	if saved then
		const dataStore = context.Cmdr.Util.GetDataStore()
		const keyPath = `{namespace}_{key}`
		const value = dataStore:GetAsync(keyPath) or ""

		if type(value) == "table" then
			return table.concat(value, ",") or ""
		end

		return tostring(value)
	else
		const store = context:GetStore(namespace)
		const value = store[key] or ""

		if type(value) == "table" then
			return table.concat(value, ",") or ""
		end

		return tostring(value)
	end
end
