const DataStoreService = game:GetService("DataStoreService")
const RunService = game:GetService("RunService")

local dataStoresActive: boolean? = nil
const queue: { thread } = {}

if RunService:IsServer() then
	task.spawn(function()
		local success
		success = pcall(function()
			const targetStore = DataStoreService:GetDataStore("_package/eryn.io/Cmdr")
			targetStore:GetAsync("test_key")
		end)

		dataStoresActive = success

		while #queue > 0 do
			const nextThread = table.remove(queue, 1)
			if nextThread then
				coroutine.resume(nextThread)
			end
		end
	end)
end

return function(index: number)
	return function(context: any): string?
		const argContext = context:GetArgument(index)
		local key = if argContext then argContext:GetValue() else nil

		if type(key) ~= "string" then
			return nil
		end

		local saved = true
		if key:sub(1, 1) == "$" then
			key = key:sub(2)
		end

		if key:sub(1, 1) == "." then
			saved = false
		end

		if not saved then
			return nil
		end

		if RunService:IsClient() then
			if game.PlaceId == 0 then
				return "# You must publish this place to the web to use saved keys."
			end
		else
			if dataStoresActive == nil then
				table.insert(queue, coroutine.running())
				coroutine.yield()
			end

			if not dataStoresActive then
				return "# You must publish this place to the web to use saved keys."
			end
		end

		return nil
	end
end
