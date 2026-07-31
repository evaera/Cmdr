const DataStoreService = game:GetService("DataStoreService")

const queue = {}
local DataStoresActive, DataStore
task.spawn(function()
	DataStoresActive, DataStore = pcall(function()
		const targetStore = DataStoreService:GetDataStore("_package/eryn.io/Cmdr")
		targetStore:GetAsync("test_key")
		return targetStore
	end)

	while #queue > 0 do
		const nextThread = table.remove(queue, 1)
		coroutine.resume(nextThread)
	end
end)

return function(context: any, key: string, value: string): string
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

	const namespace = "var_" .. (gameWide and "global" or tostring(context.Executor.UserId))
	if saved then
		const keyPath = namespace .. "_" .. key
		DataStore:SetAsync(keyPath, value)

		return value
	else
		const store = context:GetStore(namespace)
		store[key] = value

		return value
	end
end
