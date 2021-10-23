local Directory = require(script.Parent.Parent.Shared.Directory)

local autocompleteSettings = {
	IsPartial = true
}

local FUZZY_PREFIX_PATTERN = "^(.*/)(.*)$"
local function fuzzyFind(value)
	local prefix, suffix = string.match(value, FUZZY_PREFIX_PATTERN)
	
	if not prefix then
		return Directory:GetInstance("./"), "", value
	end
	return Directory:GetInstance(prefix), prefix, suffix
end

local pathnamePathType = {
	DisplayName = "pathname",
	Validate = function(value)
		return fuzzyFind(value) ~= nil, "Not a valid instance '" .. value .. "'"
	end,
	Autocomplete = function(value)
		local paths = {}

		local instance, prefix, suffix = fuzzyFind(value)
		if instance then
			-- Insert the paths of each child
			for _, child in ipairs(instance:GetChildren()) do
				local success, name = pcall(tostring, child)
				if success then
					local suffixStart, suffixEnd = string.find(name, suffix, nil, true)
					if suffixStart then
						table.insert(paths, prefix .. Directory:JoinPaths(suffix .. string.sub(name, suffixEnd + 1)))
					end
				end
			end

			if string.find("..", suffix, nil, true) then
				table.insert(paths, 1, prefix .. "..")
			end

			-- If the paths are empty we should skip to the next argument
			if #paths == 1 then
				return paths
			end
		end

		return paths, autocompleteSettings
	end,
	Default = function(player)
		return Directory.new(player):GetCD()
	end,
	Parse = function(value)
		-- Would need to know which player is parsing this type to properly handle things like home directories
		-- return Directory:ResolveAbsolutePathname(value)
		return value
	end
}

return function(registry)
	registry:RegisterType("pathname", pathnamePathType)
end