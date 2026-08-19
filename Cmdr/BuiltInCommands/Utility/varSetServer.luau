return function(context: any, key: string, value: string): string
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
		dataStore:SetAsync(keyPath, value)

		return value
	else
		const store = context:GetStore(namespace)
		store[key] = value

		return value
	end
end
