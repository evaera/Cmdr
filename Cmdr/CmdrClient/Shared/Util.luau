-- Here be dragons

const DataStoreService = game:GetService("DataStoreService")
const RunService = game:GetService("RunService")
const TextService = game:GetService("TextService")

local dataStoreActive: boolean? = nil
local dataStore: GlobalDataStore? = nil
const dataStoreQueue: { thread } = {}

const CMDR_ESCAPE = "___!CMDR_ESCAPE!___"
const CMDR_QUOTE = "___!CMDR_QUOTE!___"
const CMDR_SQUOTE = "___!CMDR_SQUOTE!___"
const CMDR_NEW_LINE = "___!CMDR_NL!___"
const CMDR_DOLLAR = "___!CMDR_DOLLAR!___"

const OPERATORS = { "&&", "||", ";" }
const START_QUOTE_PATTERN = [=[^(['"])]=]
const END_QUOTE_PATTERN = [=[(['"])$]=]
const ESCAPED_QUOTE_PATTERN = [=[(\*)['"]$]=]

const CACHED_LABELS = setmetatable({}, { __mode = "k" })

if RunService:IsServer() then
	task.spawn(function()
		const success, result = pcall(function()
			const targetStore = DataStoreService:GetDataStore("_package/eryn.io/Cmdr")
			targetStore:GetAsync("test_key")
			return targetStore
		end)

		dataStoreActive = success

		if success then
			dataStore = result
		end

		while #dataStoreQueue > 0 do
			const nextThread = table.remove(dataStoreQueue, 1)

			if nextThread then
				coroutine.resume(nextThread)
			end
		end
	end)
end

-- Converts instances into display names and keeps the original values.
const function transformInstanceSet(instances: { any }): ({ string }, { any })
	const names: { string } = {}

	for index = 1, #instances do
		local object = instances[index]
		names[index] = object.Name or tostring(object)
	end

	return names, instances
end

-- Converts a hexadecimal string into a UTF-8 character.
const function hexToChar(value: string): string
	return utf8.char(tonumber(value, 16) :: number)
end

-- Replaces escaped control characters with temporary placeholders.
const function encodeControlChars(text: string): string
	return (text:gsub("\\\\", CMDR_ESCAPE):gsub('\\"', CMDR_QUOTE):gsub("\\'", CMDR_SQUOTE):gsub("\\\n", CMDR_NEW_LINE))
end

-- Restores temporary placeholders back into control characters.
const function decodeControlChars(text: string): string
	return (text:gsub(CMDR_ESCAPE, "\\"):gsub(CMDR_QUOTE, '"'):gsub(CMDR_SQUOTE, "'"):gsub(CMDR_NEW_LINE, "\n"))
end

-- Replaces escaped command variables with temporary placeholders.
const function encodeCommandEscape(text: string): string
	return (text:gsub("\\%$", CMDR_DOLLAR))
end

-- Restores temporary command variable placeholders.
const function decodeCommandEscape(text: string): string
	return (text:gsub(CMDR_DOLLAR, "$"))
end

-- Wraps a string in quotes while escaping special characters.
const function quoteString(value: string): string
	return ("%q"):format(value)
end

--[=[
	@class Util
	Cmdr utilities module.
]=]

--[=[
	@within Util
	@readonly
	@private

	@prop _deprecationWarnings { [string]: { Description: string, Suppressed: boolean, Emitted: boolean } }

	A collection of deprecated methods and their warnings.
]=]

const Util = {
	_deprecationWarnings = {} :: { [string]: { Description: string, Suppressed: boolean, Emitted: boolean } },
}

function Util.GetDataStore(): GlobalDataStore?
	if RunService:IsClient() then
		return
	end

	if dataStoreActive == nil then
		table.insert(dataStoreQueue, coroutine.running())
		coroutine.yield()
	end

	return dataStore
end

--[=[
	@within Util
	Takes an array and flips its values into dictionary keys with value of true.
]=]
function Util.MakeDictionary(array: { any }): { [any]: true }
	const dictionary = {}

	for index = 1, #array do
		dictionary[array[index]] = true
	end

	return dictionary
end

--[=[
	@within Util
	Takes a dictionary and returns its keys.
]=]
function Util.DictionaryKeys(dict: { [any]: any }): { any }
	const keys = {}

	for key in pairs(dict) do
		table.insert(keys, key)
	end

	return keys
end

--[=[
	@within Util

	Returns a function that is a fuzzy finder for the specified set or container.

	Can pass an array of strings, array of instances, array of EnumItems,
	array of dictionaries with a Name key or an instance (in which case its children will be used).

	Exact matches will be inserted in the front of the resulting array.
]=]
function Util.MakeFuzzyFinder(setOrContainer: any): (string, boolean?, boolean?) -> any
	const containerType = typeof(setOrContainer)
	assert(
		containerType == "table" or containerType == "Enum" or containerType == "Instance",
		"[Cmdr] MakeFuzzyFinder only accepts a table, Enum, or Instance."
	)

	if containerType == "Enum" then
		setOrContainer = setOrContainer:GetEnumItems()
	elseif containerType == "Instance" then
		setOrContainer = setOrContainer:GetChildren()
	end

	local names: { string }
	local instances: { any }? = nil
	if #setOrContainer == 0 then
		names = {}
	else
		const first = setOrContainer[1]
		const firstType = typeof(first)

		if firstType == "string" then
			names = setOrContainer
		else
			const firstNameType = if firstType == "table" or firstType == "Instance" then typeof(first.Name) else "nil"
			assert(
				firstType == "Instance"
					or firstType == "EnumItem"
					or (firstType == "table" and firstNameType == "string"),
				"[Cmdr] MakeFuzzyFinder only accepts tables of instances or strings."
			)
			names, instances = transformInstanceSet(setOrContainer)
		end
	end

	-- Searches the set (checking exact matches first)
	return function(text: string, returnFirst: boolean?, matchStart: boolean?)
		const resultsPriority = {}
		const results = {}

		for index, name in pairs(names) do
			const value = if instances then instances[index] else name

			if name:lower() == text:lower() then
				if returnFirst then
					return value
				end

				results[#results + 1] = value
				resultsPriority[value] = 0
			elseif matchStart then
				if name:lower():sub(1, #text) == text:lower() then
					results[#results + 1] = value
					resultsPriority[value] = 1
				end
			else
				const startingIndex = name:lower():find(text:lower(), 1, true)
				if startingIndex then
					results[#results + 1] = value
					resultsPriority[value] = startingIndex
				end
			end
		end

		table.sort(results, function(a, b)
			const aPriority = resultsPriority[a]
			const bPriority = resultsPriority[b]

			if aPriority ~= bPriority then
				return aPriority < bPriority
			end

			const aString = if typeof(a) == "string"
				then a
				elseif typeof(a) == "Instance" then a.Name
				elseif typeof(a) == "table" and typeof(a.Name) == "string" then a.Name
				else ""
			const bString = if typeof(b) == "string"
				then b
				elseif typeof(b) == "Instance" then b.Name
				elseif typeof(b) == "table" and typeof(b.Name) == "string" then b.Name
				else ""

			return #aString < #bString
		end)

		if returnFirst then
			return results[1]
		end

		return results
	end
end

--[=[
	@within Util

	Takes an array of instances (or anything with a Name property) and maps them into an array of their names.
	If no Name property is present, then tostring will be called instead.
]=]
function Util.GetNames(instances: any): { string }
	const names, _ = transformInstanceSet(instances)
	return names
end

--[=[
	@within Util
	Splits a string using a simple separator (no quote parsing)
]=]
function Util.SplitStringSimple(input: string, separator: string?): { string }
	separator = separator or "%s"

	const segments = {}
	local index = 1
	for string in input:gmatch(`([^{separator :: string}]+)`) do
		segments[index] = string
		index = index + 1
	end

	return segments
end

--[=[
	@within Util
	Parses escape sequences into their fully qualified characters
]=]
function Util.ParseEscapeSequences(text: string): string
	return text:gsub("\\(.)", {
		t = "\t",
		n = "\n",
	})
		:gsub("\\u(%x%x%x%x)", hexToChar)
		:gsub("\\x(%x%x)", hexToChar)
end

--[=[
	@within Util
	Encodes escaped operators in a string, replacing them with their unicode representations.
]=]
function Util.EncodeEscapedOperator(text: string, operator: string): string
	const first = operator:sub(1, 1)
	const escapedOp = operator:gsub("(.)", "%%%1")
	const escapedFirst = `%{first}`

	return text:gsub(`({escapedFirst}+)({escapedOp})`, function(esc, op)
		return (`{esc:sub(1, #esc - 1)}{op}`):gsub(".", function(char)
			return `\\u{("%04x"):format(char:byte())}`
		end)
	end)
end

--[=[
	@within Util
	Encodes all escaped operators in a string, replacing them with their unicode representations.
]=]
function Util.EncodeEscapedOperators(text: string): string
	for _, operator in ipairs(OPERATORS) do
		text = Util.EncodeEscapedOperator(text, operator)
	end

	return text
end

--[[
	FIXME: Listable types containing spaces are currently handled incorrectly.
	The issue spans multiple systems, including Window, Dispatcher, and Argument.
	Fixing this properly would require a major overhaul of how Cmdr tokenizes,
	parses, and preserves command input strings.

	Good luck, future reader.

	Hours wasted attempting to fix this:
	3
]]

--[=[
	@within Util
	Splits a string by space but taking into account quoted sequences which will be treated as a single argument.
]=]
function Util.SplitString(text: string, max: number?): { string }
	text = encodeControlChars(text)
	max = max or math.huge

	const segments = {}
	local buffer = nil
	local quoteChar = nil

	const function addSegment(segment: string)
		if #segments > max then
			segments[max] ..= ` {segment}`
		else
			segments[#segments + 1] = segment
		end
	end

	for segment in text:gmatch("[^ ]+") do
		segment = Util.ParseEscapeSequences(segment)

		const startsWithQuote = segment:match(START_QUOTE_PATTERN)
		const endsWithQuote = segment:match(END_QUOTE_PATTERN)
		const escapedQuotes = segment:match(ESCAPED_QUOTE_PATTERN)

		if startsWithQuote and not quoteChar and not endsWithQuote then
			buffer = segment
			quoteChar = startsWithQuote
		elseif buffer and endsWithQuote == quoteChar and #escapedQuotes % 2 == 0 then
			buffer ..= ` {segment}`

			addSegment(decodeControlChars(buffer:gsub(START_QUOTE_PATTERN, ""):gsub(END_QUOTE_PATTERN, "")))

			buffer = nil
			quoteChar = nil
		elseif buffer then
			buffer ..= ` {segment}`
		else
			addSegment(decodeControlChars(segment:gsub(START_QUOTE_PATTERN, ""):gsub(END_QUOTE_PATTERN, "")))
		end
	end

	if buffer then
		addSegment(decodeControlChars(buffer))
	end

	return segments
end

--[=[
	@within Util
	Takes an array of arguments and a max value. Any indicies past the max value will be appended to the last valid argument.
]=]
function Util.MashExcessArguments(arguments: { string }, max: number): { string }
	const results = {}

	for argumentIndex = 1, #arguments do
		if argumentIndex > max then
			results[max] = (results[max] or "") .. ` {arguments[argumentIndex]}`
		else
			results[argumentIndex] = arguments[argumentIndex]
		end
	end

	return results
end

--[=[
	@within Util
	Trims whitespace from both sides of a string.
]=]
function Util.TrimString(str: string): string
	const _, from = str:find("^%s*")
	return if from == #str then "" else str:match(".*%S", from + 1) :: string
end

--[=[
	@within Util
	Returns the text bounds size based on given text, label (from which properties will be pulled), and optional Vector2 container size.
]=]
function Util.GetTextSize(text: string, label: TextLabel, size: Vector2?): Vector2
	size = size or Vector2.new(label.AbsoluteSize.X, 0)

	if label.Font == Enum.Font.Unknown then
		const textBoundsParams = CACHED_LABELS[label] or Instance.new("GetTextBoundsParams")
		textBoundsParams.Text = text
		textBoundsParams.Font = label.FontFace
		textBoundsParams.Size = label.TextSize
		textBoundsParams.Width = (size :: Vector2).X
		textBoundsParams.RichText = label.RichText
		CACHED_LABELS[label] = textBoundsParams

		const success, bounds = pcall(TextService.GetTextBoundsAsync, TextService, textBoundsParams)
		if not success or not bounds then
			warn(`[Cmdr] Failed to get TextSize for Font Face {label.FontFace.Family}: {bounds}`)
			return Vector2.new(0, 0)
		end

		return bounds
	end

	return TextService:GetTextSize(text, label.TextSize, label.Font, size)
end

--[=[
	@within Util
	@return TypeDefinition

	Makes an Enum type.
]=]
function Util.MakeEnumType(name: string, values: any): { [string]: any }
	const findValue = Util.MakeFuzzyFinder(values)
	return {
		Validate = function(text)
			return findValue(text, true) ~= nil, `Value {("%q"):format(text)} is not a valid {name}.`
		end,

		Autocomplete = function(text)
			local list = findValue(text)
			return type(list[1]) ~= "string" and Util.GetNames(list) or list
		end,

		Parse = function(text)
			return findValue(text, true)
		end,
	}
end

--[=[
	@within Util
	Parses a prefixed union type argument (such as %Team)
]=]
function Util.ParsePrefixedUnionType(typeValue: string, rawValue: string): (string?, string?, string?)
	const split = Util.SplitStringSimple(typeValue)

	const types = {}
	for splitIndex = 1, #split, 2 do
		types[#types + 1] = {
			prefix = split[splitIndex - 1] or "",
			type = split[splitIndex],
		}
	end

	table.sort(types, function(a, b)
		return #a.prefix > #b.prefix
	end)

	for typeIndex = 1, #types do
		const typeInfo = types[typeIndex]

		if rawValue:sub(1, #typeInfo.prefix) == typeInfo.prefix then
			return typeInfo.type, rawValue:sub(#typeInfo.prefix + 1), typeInfo.prefix
		end
	end

	return
end

--[=[
	@within Util

	@param typeDefinition TypeDefinition
	@param override table
	@return TypeDefinition

	Creates a listable type from a singular type
]=]
function Util.MakeListableType(typeDefinition: any, override: { [string]: any }?): { [string]: any }
	const listableType: { [string]: any } = {
		Listable = true,
		Transform = typeDefinition.Transform,
		Validate = typeDefinition.Validate,
		ValidateOnce = typeDefinition.ValidateOnce,
		Autocomplete = typeDefinition.Autocomplete,
		Default = typeDefinition.Default,
		ArgumentOperatorAliases = typeDefinition.ArgumentOperatorAliases,
		Parse = function(...)
			return { typeDefinition.Parse(...) }
		end,
	}

	if override then
		for key, value in pairs(override) do
			listableType[key] = value
		end
	end

	return listableType
end

--[=[
	@within Util
	@param dispatcher Dispatcher

	Runs a command string, chaining commands with && and replacing || with the previous command's output.
]=]
function Util.RunCommandString(dispatcher: any, commandString: string): string?
	commandString = Util.ParseEscapeSequences(commandString)
	commandString = Util.EncodeEscapedOperators(commandString)

	const commands = commandString:split("&&")
	local output = ""
	for commandIndex, command in ipairs(commands) do
		const outputEncoded = output:gsub("%$", "\\x24"):gsub("%%", "%%%%")
		command = command:gsub("||", output:find("%s") and quoteString(outputEncoded) or outputEncoded)

		output = tostring(dispatcher:EvaluateAndRun((Util.RunEmbeddedCommands(dispatcher, command))))

		if commandIndex == #commands then
			return output
		end
	end

	return
end

--[=[
	@within Util
	@param dispatcher Dispatcher

	Runs embedded commands and replaces them
]=]
function Util.RunEmbeddedCommands(dispatcher: any, str: string): string
	str = encodeCommandEscape(str)

	const results = {}
	-- We need to do this because you can't yield in the gsub function
	for text in str:gmatch("$(%b{})") do
		local doQuotes = true
		local commandString = text:sub(2, #text - 1)

		if commandString:match("^{.+}$") then -- Allow double curly for literal replacement
			doQuotes = false
			commandString = commandString:sub(2, #commandString - 1)
		end

		results[text] = Util.RunCommandString(dispatcher, commandString)

		if doQuotes then
			if results[text]:find("%s") or results[text] == "" then
				results[text] = quoteString(results[text])
			end
		end
	end

	const escaped = (str:gsub("%$(%b{})", results))
	return decodeCommandEscape(escaped)
end

--[=[
	@within Util
	Replaces arguments in the format $1, $2, $something with whatever the given function returns for it.
]=]
function Util.SubstituteArgs(str: string, replace: any): string
	str = encodeCommandEscape(str)

	if type(replace) == "table" then
		for index = 1, #replace do
			const key = tostring(index)
			replace[key] = replace[index]

			if replace[key]:find("%s") then
				replace[key] = quoteString(replace[key])
			end
		end
	end

	const escaped = str:gsub("%$(%d+)%b{}", "$%1"):gsub("%$(%w+)", replace)
	return decodeCommandEscape(escaped)
end

--[=[
	@within Util
	@return CommandDefinition

	Creates an alias command, should only be used on the client.
]=]
function Util.MakeAliasCommand(name: string, commandString: string): { [string]: any }
	const commandName, commandDescription = unpack(name:split("|"))
	const args, seenArgs = {}, {}

	commandString = Util.EncodeEscapedOperators(commandString)
	for arg in commandString:gmatch("$(%d+)") do
		if seenArgs[arg] == nil then
			seenArgs[arg] = true
			local options = commandString:match(`${arg}(%b\{})`)

			local argOptional, argType, argName, argDescription
			if options then
				options = options:sub(2, #options - 1) -- remove braces
				argType, argName, argDescription = unpack(options:split("|"))
			end

			argOptional = argType and not not argType:match("%?$")
			argType = if argType then argType:match("^%w+") else "string"
			argName = argName or `Argument {arg}`
			argDescription = argDescription or ""

			table.insert(args, {
				Type = argType,
				Name = argName,
				Description = argDescription,
				Optional = argOptional,
			})
		end
	end

	return {
		Name = commandName,
		Description = `<Alias> {commandDescription or commandString}`,
		Group = "UserAlias",
		Args = args,
		ClientRun = function(context: any)
			return Util.RunCommandString(context.Dispatcher, Util.SubstituteArgs(commandString, context.RawArguments))
		end,
	}
end

--[=[
	@within Util

	@param options { Transform: function?, Parse: function?, Constructor: function?, TransformEach: function?, ValidateEach: function?, Prefixes: {string}?, Length: number? }
	@return ArgumentDefinition

	Makes a type that contains a sequence, e.g. Vector3 or Color3
	For options, one of Constructor or Parse is required
]=]
function Util.MakeSequenceType(options: {
	Transform: ((string) -> any)?,
	Parse: (({ string }) -> any)?,
	Constructor: ((...any) -> any)?,
	TransformEach: ((string) -> any)?,
	ValidateEach: ((any, number) -> (boolean, string?))?,
	Prefixes: { string }?,
	Length: number?,
}): { [string]: any }
	assert(
		options.Parse ~= nil or options.Constructor ~= nil,
		"[Cmdr] MakeSequenceType: Must provide one of: Constructor, Parse"
	)
	options.TransformEach = options.TransformEach or function(value: string): string
		return value
	end

	options.ValidateEach = options.ValidateEach or function()
		return true
	end

	return {
		Prefixes = options.Prefixes,

		Transform = options.Transform or function(text: string)
			const elements = Util.SplitPrioritizedDelimeter(text, { ",", "%s" }) or {}
			return Util.Map(elements, function(value: string)
				return (options :: any).TransformEach(value)
			end)
		end,

		Validate = function(components)
			if options.Length and #components > options.Length then
				return false, `Maximum of {options.Length} values allowed in sequence`
			end

			for componentIndex = 1, options.Length or #components do
				const valid, reason = (options :: any).ValidateEach(components[componentIndex], componentIndex)
				if not valid then
					return false, reason
				end
			end

			return true
		end,

		Parse = options.Parse or function(components)
			return options.Constructor(unpack(components))
		end,
	}
end

--[=[
	@within Util
	Splits a string by a single delimeter chosen from the given set. The first matching delimeter from the set becomes the split character.
]=]
function Util.SplitPrioritizedDelimeter(text: string, delimiters: { string }): { string }?
	for delimiterIndex, delimiter in ipairs(delimiters) do
		if text:find(delimiter) or delimiterIndex == #delimiters then
			return Util.SplitStringSimple(text, delimiter)
		end
	end

	return
end

--[=[
	@within Util
	Maps values of an array through a callback and returns an array of mapped values.
]=]
function Util.Map(array: { any }, callback: (any, number) -> any): { any }
	const results: { any } = {}
	for index, value in ipairs(array) do
		results[index] = callback(value, index)
	end

	return results
end

--[=[
	@within Util
	Maps arguments #2-n through callback and returns values as tuple.
]=]
function Util.Each(callback: (any) -> any, ...: any): ...any
	const results: { any } = {}
	for index, value in ipairs({ ... }) do
		results[index] = callback(value)
	end

	return unpack(results)
end

--[=[
	@within Util
	Emulates tabstops with spaces.
]=]
function Util.EmulateTabstops(text: string, tabWidth: number): string
	local currentColumn = 0
	const result = table.create(#text)
	for index = 1, #text do
		const character = text:sub(index, index)

		if character == "\t" then
			const spaces = tabWidth - currentColumn % tabWidth
			table.insert(result, (" "):rep(spaces))
			currentColumn += spaces
		else
			table.insert(result, character)

			if character == "\n" then
				currentColumn = 0
			elseif character ~= "\r" then
				currentColumn += 1
			end
		end
	end

	return table.concat(result)
end

--[=[
	@within Util
	@return function -- A function that locks the mutex and returns a function to unlock it.

	Creates a mutex for synchronizing coroutines.
]=]
function Util.Mutex(): () -> ()
	const queue: { thread } = {}
	local locked = false

	return function()
		if locked then
			table.insert(queue, coroutine.running())
			coroutine.yield()
		else
			locked = true
		end

		return function()
			if #queue > 0 then
				const nextThread = table.remove(queue, 1)
				coroutine.resume(nextThread)
			else
				locked = false
			end
		end
	end
end

--[=[
	@within Util
	@private

	Registers a deprecation warning for a method.
]=]
function Util:_registerDeprecationWarning(name: string, description: string)
	assert(type(name) == "string" and #name > 0, "[Cmdr] Deprecation warning name must be a string.")
	assert(
		type(description) == "string" and #description > 0,
		"[Cmdr] Deprecation warning description must be a string."
	)
	assert(not self._deprecationWarnings[name], `[Cmdr] Deprecation warning {name} is already registered.`)

	self._deprecationWarnings[name] = {
		Description = description,
		Suppressed = false,
		Emitted = false,
	}
end

--[=[
	@within Util
	@private

	Emits a deprecation warning for a method if it has been called. This should be called at the start of a deprecated method.
]=]
function Util:_emitDeprecationWarning(name: string)
	const warningInfo = self._deprecationWarnings[name]
	assert(warningInfo, `[Cmdr] Unknown deprecation warning {name}.`)

	if not warningInfo.Suppressed and not warningInfo.Emitted then
		warn(debug.traceback(`[Cmdr] [DeprecationWarning::{name}] {warningInfo.Description}`, 2))
		warningInfo.Emitted = true
	end
end

--[=[
	@within Util
	Suppresses a deprecation warning for a method.
]=]
function Util:SuppressDeprecationWarning(names: string | { string })
	assert(
		type(names) == "string" or type(names) == "table",
		"[Cmdr] Deprecation warning name(s) must be a string or an array of strings."
	)
	assert(#names > 0, "[Cmdr] Deprecation warning name(s) must not be empty.")

	if type(names) == "string" then
		names = { names }
	end

	for _, name in pairs(names) do
		assert(type(name) == "string", "[Cmdr] Deprecation warning names must be strings.")
		assert(self._deprecationWarnings[name], `[Cmdr] Unknown deprecation warning {name}.`)
		self._deprecationWarnings[name].Suppressed = true
	end
end

Util:_registerDeprecationWarning(
	"ProxyCalls",
	`Method calls should be performed against their respective modules rather than the {if RunService:IsServer()
		then "Cmdr"
		else "CmdrClient"} object. Proxy calls are deprecated, they exist for backwards compatibility and should not be used for new work.`
)

return Util
