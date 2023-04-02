local DataStoreService = game:GetService("DataStoreService")

local queue = {}
local DataStoresActive, DataStore
task.spawn(function()
	DataStoresActive, DataStore = pcall(function()
		local DataStore = DataStoreService:GetDataStore("_package/eryn.io/Cmdr")
		DataStore:GetAsync("test_key")
		return DataStore
	end)

	while #queue > 0 do
		coroutine.resume(table.remove(queue, 1))
	end
end)

return function (context, key, value)
	if DataStoresActive == nil then
		table.insert(queue, coroutine.running())
		coroutine.yield()
	end

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

		DataStore:SetAsync(keyPath, value)

		if type(value) == "table" then
			return table.concat(value, ",") or ""
		end

		return value
	else
		local store = context:GetStore(namespace)

		store[key] = value

		if type(value) == "table" then
			return table.concat(value, ",") or ""
		end

		return value
	end
end
