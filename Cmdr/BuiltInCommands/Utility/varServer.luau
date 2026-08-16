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

return function(context: any, key: string): string
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

	const namespace = `var_{if gameWide then "global" else tostring(context.Executor.UserId)}`

	if saved then
		const keyPath = `{namespace}_{key}`
		const value = DataStore:GetAsync(keyPath) or ""

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
