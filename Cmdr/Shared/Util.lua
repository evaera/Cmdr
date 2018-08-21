local TextService = game:GetService("TextService")

local Util = {}

--- Takes an array and flips its values into dictionary keys with value of true.
function Util.MakeDictionary (array)
	local dictionary = {}

	for i = 1, #array do
		dictionary[array[i]] = true
	end

	return dictionary
end

-- Takes an array of instances and returns (array<names>, array<instances>)
function transformInstanceSet (instances)
	local names = {}

	for i = 1, #instances do
		names[i] = instances[i].Name
	end

	return names, instances
end

--- Returns a function that is a fuzzy finder for the specified set or container.
-- Can pass an array of strings, array of instances, or an instance (in which case its children will be used)
function Util.MakeFuzzyFinder (setOrContainer)
	local names
	local instances = {}

	if typeof(setOrContainer) == "Instance" then
		names, instances = transformInstanceSet(setOrContainer:GetChildren())
	elseif type(setOrContainer) == "table" then
		if typeof(setOrContainer[1]) == "Instance" then
			names, instances = transformInstanceSet(setOrContainer)
		elseif type(setOrContainer[1]) == "string" then
			names = setOrContainer
		elseif setOrContainer[1] ~= nil then
			error("MakeFuzzyFinder only accepts tables of instances or strings.")
		else
			names = {}
		end
	else
		error("MakeFuzzyFinder only accepts a table or an Instance.")
	end

	-- Searches the set (checking exact matches first)
	return function (text, returnFirst)
		local results = {}

		for i, name in pairs(names) do
			-- Exact match check first...
			if returnFirst and name:lower() == text:lower() then
				return instances and instances[i] or name
			end

			-- Continue on checking for non-exact matches...
			-- Still need to loop through everything, even on returnFrist, because possibility of an exact match.
			if name:lower():sub(1, #text) == text then
				results[#results + 1] = instances and instances[i] or name
			end
		end

		if returnFirst then
			return results[1]
		end

		return results
	end
end

--- Takes an array of instances and returns an array of those instances' names.
function Util.GetInstanceNames (instances)
	local names = {}

	for i = 1, #instances do
		names[i] = instances[i].Name
	end

	return names
end

--- Splits a string using a simple separator (no quote parsing)
function Util.SplitStringSimple(inputstr, sep)
	if sep == nil then
					sep = "%s"
	end
	local t={}
	local i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
					t[i] = str
					i = i + 1
	end
	return t
end

--- Splits a string by space but taking into account quoted sequences which will be treated as a single argument.
function Util.SplitString (text, max)
	max = max or math.huge
	local t = {}
	local spat, epat, buf, quoted = [=[^(['"])]=], [=[(['"])$]=]
	for str in text:gmatch("%S+") do
		local squoted = str:match(spat)
		local equoted = str:match(epat)
		local escaped = str:match([=[(\*)['"]$]=])
		if squoted and not quoted and not equoted then
			buf, quoted = str, squoted
		elseif buf and equoted == quoted and #escaped % 2 == 0 then
			str, buf, quoted = buf .. ' ' .. str, nil, nil
		elseif buf then
			buf = buf .. ' ' .. str
		end
		if not buf then
			t[#t + (#t > max and 0 or 1)] = (str:gsub(spat,""):gsub(epat,""))
		end
	end

	if buf then
		t[#t + (#t > max and 0 or 1)] = buf
	end

	return t
end

--- Takes an array of arguments and a max value.
-- Any indicies past the max value will be appended to the last valid argument.
function Util.MashExcessArguments (arguments, max)
	local t = {}
	for i = 1, #arguments do
		if i > max then
			t[max] = ("%s %s"):format(t[max], arguments[i])
		else
			t[i] = arguments[i]
		end
	end
	return t
end

--- Trims whitespace from both sides of a string.
function Util.TrimString(s)
	return s:match "^%s*(.-)%s*$"
end

--- Returns the text bounds size based on given text, label (from which properties will be pulled), and optional Vector2 container size.
function Util.GetTextSize (text, label, size)
	return TextService:GetTextSize(text, label.TextSize, label.Font, size or Vector2.new(label.AbsoluteSize.X, 0))
end

function Util.MakeEnumType(name, values)
	local findValue = Util.MakeFuzzyFinder(values)
	return {
		validate = function (text)
			return findValue(text, true) ~= nil, ("Value %q is not a valid %s."):format(text, name)
		end;
		autocomplete = function (text)
			return findValue(text)
		end;
		parse = function (text)
			return findValue(text, true)
		end
	}
end

return Util