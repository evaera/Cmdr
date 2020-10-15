local DataStoreService = game:GetService("DataStoreService")

local DataStoresActive, DataStore = pcall(function()
	return DataStoreService:GetGlobalDataStore("_package/eryn.io/Cmdr")
end)

return function (context, key)
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

	if saved and not DataStoresActive then
		return "# You must publish this place to the web to use saved keys."
	end

	local namespace = "var_" .. (gameWide and "global" or tostring(context.Executor.UserId))

	if saved then
		local keyPath = namespace .. "_" .. key
		local value = DataStore:GetAsync(keyPath) or ""
		if type(value) == "table" then
			return table.concat(value, ",") or ""
		end
		return value
	else
		local store = context:GetStore(namespace)

		local value = store[key] or ""

		if type(value) == "table" then
			return table.concat(value, ",") or ""
		end

		return value
	end
end