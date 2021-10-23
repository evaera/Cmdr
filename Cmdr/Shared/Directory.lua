local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Directory = {
	HomeStack = {}
}
Directory.__index = Directory

-- Directory symbols
local HOME_WORD = "~"
local PARENT_WORD = ".."
local CD_WORD = "."
local PATH_SEPARATOR = "/"

-- Root instance
local ROOT_INSTANCE = game

-- Gets the current directory
function Directory:GetCD()
	return self.CD or PATH_SEPARATOR
end

-- Changes the current directory
function Directory:SetCD(directory)
	local cd = self:GetCD()

	-- Resolve absolute path, and don't set it if it hasn't changed
	directory = self:ResolveAbsolutePathname(directory, cd)
	if directory == cd then
		return
	end

	self.CD = directory
end

-- Gets an instance by its pathname
function Directory:GetInstance(path, rootInstance)
	local fullPath = self:ResolveAbsolutePathname(path, self:GetCD())
	local item = rootInstance or ROOT_INSTANCE
	
	assert(item, "GetInstance was passed an invalid root instance")

	if fullPath == PATH_SEPARATOR then
		return item
	end
	local segments = self:ParsePathname(fullPath)
	local numSegments = #segments
	for index, segment in ipairs(segments) do
		-- Skip first segment since its an absolute path
		if index == 1 then
			continue
		elseif index == numSegments then
			if segment == "" then
				break
			end
		end

		item = item:FindFirstChild(segment)
		-- Item doesn't exist, stop searching
		if not item then
			break
		end
	end
	return item
end

-- Parses a pathname into its segments
function Directory:ParsePathname(pathname)
	if pathname == "/" then
		return {""}
	end
	return string.split(pathname, PATH_SEPARATOR)
end

-- Combines a list of path segments or names into a full path, resolving special path words
function Directory:JoinPaths(...)
	local argCount = select("#", ...)
	local args = {...}

	local combined = table.create(argCount)
	for _, path in ipairs(args) do
		if type(path) == "string" then
			path = self:ParsePathname(path)
		elseif type(path) ~= "table" then
			error(string.format("JoinPaths expected arguments of type 'table' or 'string' but got type '%s'", type(path)), 2)
		end

		for _, segment in ipairs(path) do
			table.insert(combined, segment)
		end
	end

	local firstSegment = combined[1]
	if firstSegment == HOME_WORD then
		-- Replace the first segment with the home directory
		table.remove(combined, 1)

		local segments = self:ParsePathname(self:GetHomeDirectory())
		for index, segment in ipairs(segments) do
			table.insert(combined, index, segment)
		end
	elseif firstSegment == CD_WORD then
		-- Replace the first segment with the current directory
		table.remove(combined, 1)

		local segments = self:ParsePathname(self:GetCD())
		for index, segment in ipairs(segments) do
			table.insert(combined, index, segment)
		end
	end

	local combinedFinal = table.create(#combined)
	for _, segment in ipairs(combined) do
		if segment ~= CD_WORD then
			if segment == PARENT_WORD then
				table.remove(combinedFinal, #combinedFinal)
			else
				table.insert(combinedFinal, segment)
			end
		end
	end
	return table.concat(combinedFinal, PATH_SEPARATOR)
end

local roots = {
	[""] = PATH_SEPARATOR,
	[HOME_WORD] = HOME_WORD
}

-- Resolves an absolute path with the given base path which defaults to the cd
function Directory:ResolveAbsolutePathname(path, basePath)
	local segments = self:ParsePathname(path)

	-- If the directory is prefixed with some kind of root folder we want to use that root folder instead of the cd
	local root = roots[segments[1]]
	if root then
		table.remove(segments, 1)
		basePath = self:ParsePathname(root)
	end

	-- Join the path at the base
	local joined = self:JoinPaths(basePath or self:GetCD(), segments)
	if string.sub(joined, 1, #PATH_SEPARATOR) ~= PATH_SEPARATOR then
		joined = PATH_SEPARATOR .. joined
	end
	return joined
end

-- Gets the current home directory
function Directory:GetHomeDirectory()
	local homeStack = self.HomeStack
	return homeStack[#homeStack] or self.HomeRoot or (PATH_SEPARATOR .. CD_WORD)
end

-- Push/pop for home directories, can properly handle "sudo" behaviour where a user invokes stuff on the home folder of another user
-- e.g. an emulation of sudo -u "fake-user"
function Directory:PushHomeDirectory(path)
	local homeStack = self.HomeStack
	table.insert(homeStack, self:ResolveAbsolutePathname(path))
end
function Directory:PopHomeDirectory()
	local homeStack = self.HomeStack
	return table.remove(homeStack, #homeStack)
end

local directories = {}
function Directory.new(player)
	player = player or Players.LocalPlayer
	if not RunService:IsServer() then
		if not player then
			return Directory
		end
	end

	local existing = directories[player]
	if existing then
		return existing
	end

	local directory = setmetatable({
		HomeRoot = Directory:JoinPaths(PATH_SEPARATOR .. "Workspace", player.Name)
	}, Directory)
	directory:SetCD(HOME_WORD)

	directories[player] = directory
	return directory
end

return Directory