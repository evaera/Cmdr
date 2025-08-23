local RunService = game:GetService("RunService")

local Util = require(script.Parent.Util)

--[=[
	@class Registry

	The registry keeps track of all the commands and types that Cmdr knows about.
]=]

--[=[
	@type HookType "BeforeRun" | "AfterRun"
	@within Registry
]=]

--[=[
	@interface ArgumentDefinition
	@within Registry
	.Type string | TypeDefinition -- The argument type (case sensitive), or an [inline TypeDefinition object](/docs/commands#dynamic-arguments-and-inline-types).
	.Name string -- The argument name, this is displayed to the user as they type.
	.Description string? -- A description of what the argument is, this is also displayed to the user.
	.Optional boolean? -- If this is set to `true`, then the user can run the command without filling out the value. In which case, the argument will be sent to implementations as `nil`.
	.Default any? -- If present, the argument will be automatically made optional, so if the user doesn't supply a value, implementations will receive whatever the value of `Default` is.

	The `table` definition, usually contained in a [CommandDefinition](#CommandDefinition), which 'defines' the argument.
]=]

--[=[
	@interface CommandDefinition
	@within Registry
	.Name string -- The name of the command
	.Aliases {string}? -- Aliases which aren't part of auto-complete, but if matched will run this command just the same. For example, `m` might be an alias of `announce`.
	.Description string? -- A description of the command, displayed to the user in the `help` command and auto-complete menu.
	.Group string? -- This property is intended to be used in hooks, so that you can categorise commands and decide if you want a specific user to be able to run them or not. But the `help` command will use them as headings.
	.Args {ArgumentDefinition | (CommandContext) -> (ArgumentDefinition)} -- Arguments for the command; this is technically optional but if you have no args, set it to `{}` or you may experience some interface weirdness.
	.Data (CommandContext, ...) -> any -- If your command needs to gather some extra data from the client that's only available on the client, then you can define this function. It should accept the command context and tuple of transformed arguments, and return a single value which will be available in the command with [CommandContext:GetData](/api/CommandContext#GetData).
	.ClientRun (CommandContext, ...) -> string? -- If you want your command to run on the client, you can add this function to the command definition itself. It works exactly like the function that you would return from the Server module. If this function returns a string, the command will run entirely on the client and won't touch the server (which means server-only hooks won't run). If this function doesn't return anything, it will fall back to executing the Server module on the server.
	.Run (CommandContext, ...) -> string? -- An older version of ClientRun. There are very few scenarios where this is preferred to ClientRun (so, in other words, don't use it!). These days, `Run` is only used for some dark magic involving server-sided command objects.
]=]

--[=[
	@interface TypeDefinition
	@within Registry
	.Prefixes string? -- String containing [prefixed union types](/docs/commands#prefixed-union-types) for this type. This property should omit the inital type, so the string should begin with a prefix character, e.g. `Prefixes = "# integer ! boolean"`
	.DisplayName string? -- Overrides the user-facing name of this type in the autocomplete menu. Otherwise, the registered name of the type will be used.
	.Default ((Player) -> string)? -- Should return the "default" value for this type as a string. For example, the default value of the `player` type is the name of the player who ran the command.
	.Listable boolean? -- If true, this will tell Cmdr that comma-separated lists are allowed for this type. Cmdr will automatically split the list and parse each segment through your `Transform`, `Validate`, `Autocomplete` and `Parse` functions individually, so you don't have to change the logic of your type at all. The only limitation is that your `Parse` function **must return a table**, the tables from each individual segment's `Parse` functions will be merged into one table at the end of the parsing step. The uniqueness of values is ensured upon merging, so even if the user lists the same value several times, it will only appear once in the final table.
	.Transform (string, Player) -> T? -- Transform is an optional function that is passed two values: the raw text, and the player running the command. Then, whatever values this function returns will be passed to all other functions in the type (`Validate`, `Autocomplete` and `Parse`).
	.Validate (T) -> (boolean, string?) -- The `Validate` function is passed whatever is returned from the `Transform` function (or the raw value if there is no `Transform` function). If the value is valid for the type, it should return `true`. If the value is invalid, it should return two values: `false` and a string containing an error message. If this function is omitted, anything will be considered valid.
	.ValidateOnce (T) -> (boolean, string?) -- This function works exactly the same as the normal `Validate` function, except it only runs once (after the user presses Enter). This should only be used if the validation process is relatively expensive or needs to yield. For example, the `playerId` type uses this because it needs to call `GetUserIdFromNameAsync` in order to validate. For the vast majority of types, you should just use `Validate` instead.
	.Autocomplete (T) -> ({string}, {IsPartial: boolean?}?)? -- Should only be present for types that are possible to be auto-completed. It should return an array of strings that will be displayed in the auto-complete menu. It can also return a second value, containing a dictionary of options (currently, `IsPartial`: if true then pressing Tab to auto-complete won't continue onwards to the next argument.)
	.Parse (T) -> any -- Parse is the only required function in a type definition. It is the final step before the value is considered finalised. This function should return the actual parsed value that will be sent to implementations.

	The `table` definition, contained in an [ArgumentDefinition](#ArgumentDefinition) or [registered](#RegisterType), which 'defines' the argument.
]=]

--[=[
	@prop TypeMethods { [string]: true }
	@within Registry
	@readonly
	@private
]=]

--[=[
	@prop CommandMethods { [string]: true }
	@within Registry
	@readonly
	@private
]=]

--[=[
	@prop CommandArgProps { [string]: true }
	@within Registry
	@readonly
	@private
]=]

--[=[
	@prop Types table
	@within Registry
	@readonly
	@private
]=]

--[=[
	@prop TypeAliases table
	@within Registry
	@readonly
	@private
]=]

--[=[
	@prop Commands table
	@within Registry
	@readonly
	@private
]=]

--[=[
	@prop CommandsArray table
	@within Registry
	@readonly
	@private
]=]

--[=[
	@prop Cmdr Cmdr | CmdrClient
	@within Registry
	@readonly
	A reference to Cmdr. This may either be the server or client version of Cmdr depending on where the code is running.
]=]

--[=[
	@prop Hooks { [HookType]: table }
	@within Registry
	@readonly
	@private
]=]

--[=[
	@prop Stores table
	@within Registry
	@readonly
	@private
]=]

--[=[
	@prop AutoExecBuffer table
	@within Registry
	@readonly
	@private
]=]

local Registry = {
	TypeMethods = Util.MakeDictionary({
		"Transform",
		"Validate",
		"Autocomplete",
		"Parse",
		"DisplayName",
		"Listable",
		"ValidateOnce",
		"Prefixes",
		"Default",
		"ArgumentOperatorAliases",
	}),
	CommandMethods = Util.MakeDictionary({
		"Name",
		"Aliases",
		"AutoExec",
		"Description",
		"Args",
		"Run",
		"ClientRun",
		"Data",
		"Group",
		"Guards",
	}),
	CommandArgProps = Util.MakeDictionary({ "Name", "Type", "Description", "Optional", "Default" }),
	Types = {},
	TypeAliases = {},
	Commands = {},
	CommandsArray = {},
	Cmdr = nil,
	Hooks = {
		BeforeRun = {},
		AfterRun = {},
	},
	Stores = setmetatable({}, {
		__index = function(self, k)
			self[k] = {}
			return self[k]
		end,
	}),
	AutoExecBuffer = {},
}

--[=[
	Registers a type on the current realm (server/client), this function should be called from within the type definition ModuleScript.
	@param name -- The name of the type, this must be unique, alphanumeric, and start with a lower-case letter or digit.
	@param typeObject TypeDefinition
	@within Registry
]=]
function Registry:RegisterType(name: string, typeObject)
	if not name or typeof(name) ~= "string" then
		error("[Cmdr] Invalid type name provided: nil")
	end

	if not name:find("^[%d%l]%w*$") then
		error(
			`[Cmdr] Invalid type name provided: "{name}", type names must be alphanumeric and start with a lower-case letter or a digit.`
		)
	end

	for key in pairs(typeObject) do
		if self.TypeMethods[key] == nil then
			error(`[Cmdr] Unknown key/method in type "{name}": {key}`)
		end
	end

	if self.Types[name] ~= nil then
		error(`[Cmdr] Type {name} has already been registered.`)
	end

	typeObject.Name = name
	typeObject.DisplayName = typeObject.DisplayName or name

	self.Types[name] = typeObject

	if typeObject.Prefixes then
		self:RegisterTypePrefix(name, typeObject.Prefixes)
	end
end

--[=[
	Registers a Prefixed Union Type string on the current realm (server/client), this function should be called from within the type definition ModuleScript.

	If there are already type prefixes for the given type name, they will be concatenated. This allows you to add prefixes to default types, like `players`.

	@param name -- The name of the type.
	@param union -- The string should omit the initial type name, so this string should begin with a prefix character, e.g. `# integer ! boolean`
	@within Registry
]=]
function Registry:RegisterTypePrefix(name: string, union: string)
	if not self.TypeAliases[name] then
		self.TypeAliases[name] = name
	end

	self.TypeAliases[name] = ("%s %s"):format(self.TypeAliases[name], union)
end

--[=[
	Allows you to register a name which will be expanded into a longer type which can be used as a command argument type.
	For example, if you register the alias `stringOrNumber` it could be interpreted as `string # number` when used.

	@param name -- The name of the type, this must be unique, alphanumeric, and start with a lower-case letter or digit.
	@param alias -- The string should *include* the initial type name, e.g. `string # integer ! boolean`
	@within Registry
]=]
function Registry:RegisterTypeAlias(name: string, alias: string)
	assert(self.TypeAliases[name] == nil, `[Cmdr] Type alias {alias} already exists!`)
	self.TypeAliases[name] = alias
end

--[=[
	Registers all types from within a container on both the server and client.

	@server
	@within Registry
]=]
function Registry:RegisterTypesIn(container: Instance)
	for _, object in pairs(container:GetChildren()) do
		if object:IsA("ModuleScript") then
			object.Parent = self.Cmdr.ReplicatedRoot.Types

			require(object)(self)
		else
			self:RegisterTypesIn(object)
		end
	end
end

-- These are exactly the same thing. No one will notice. Except for you, dear reader.
--[=[
	@method RegisterHooksIn
	Registers all hooks from within a container on both the server and client.
	If you want to add a hook only on the server or client – e.g. for logging – then you should use the Register.RegisterHook method instead.

	@param container Instance
	@server
	@within Registry
]=]
Registry.RegisterHooksIn = Registry.RegisterTypesIn

--[=[
	Register a command purely based on its definition.
	Prefer using Registry:RegisterCommand for proper handling of client/server model.

	@param commandObject CommandDefinition
	@private
	@within Registry
]=]
function Registry:RegisterCommandObject(commandObject)
	for key in pairs(commandObject) do
		if self.CommandMethods[key] == nil then
			error(`[Cmdr] Unknown key/method in command "{commandObject.Name or "unknown command"}": {key}`)
		end
	end

	if commandObject.Args then
		for i, arg in pairs(commandObject.Args) do
			if type(arg) == "table" then
				for key in pairs(arg) do
					if self.CommandArgProps[key] == nil then
						error(
							`[Cmdr] Unknown property in command "{commandObject.Name or "unknown"}" argument #{i}: {key}`
						)
					end
				end
			end
		end
	end

	if commandObject.AutoExec and RunService:IsClient() then
		table.insert(self.AutoExecBuffer, commandObject.AutoExec)
		self:FlushAutoExecBufferDeferred()
	end

	-- Unregister the old command if it exists...
	local oldCommand = self.Commands[commandObject.Name:lower()]
	if oldCommand and oldCommand.Aliases then
		for _, alias in pairs(oldCommand.Aliases) do
			self.Commands[alias:lower()] = nil
		end
	elseif not oldCommand then
		table.insert(self.CommandsArray, commandObject)
	end

	self.Commands[commandObject.Name:lower()] = commandObject

	if commandObject.Aliases then
		for _, alias in pairs(commandObject.Aliases) do
			self.Commands[alias:lower()] = commandObject
		end
	end
end

--[=[
	Registers a command definition and its server equivalent. Handles replicating the definition to the client.

	@param filter (CommandDefinition -> boolean)? -- If present, will be passed a command definition which will then only be registered if the function returns `true`.

	@server
	@within Registry
]=]
function Registry:RegisterCommand(
	commandScript: ModuleScript,
	commandServerScript: ModuleScript?,
	filter: ((any) -> boolean)?
)
	local commandObject = require(commandScript)
	assert(
		typeof(commandObject) == "table",
		`[Cmdr] Invalid return value from command script "{commandScript.Name}" (CommandDefinition expected, got {typeof(commandObject)})`
	)

	if commandServerScript then
		assert(RunService:IsServer(), "[Cmdr] The commandServerScript parameter is not valid for client usage.")
		commandObject.Run = require(commandServerScript)
	end

	if filter and not filter(commandObject) then
		return
	end

	self:RegisterCommandObject(commandObject)

	commandScript.Parent = self.Cmdr.ReplicatedRoot.Commands
end

--[=[
	Registers all commands from within a container on both the server and client.

	Module scripts which include `Server` in their name will not be sent to the client.

	@param filter ((CommandDefinition) -> boolean)? -- If present, will be passed a command definition which will then only be registered if the function returns `true`.

	@server
	@within Registry
]=]
function Registry:RegisterCommandsIn(container: Instance, filter: ((any) -> boolean)?)
	local skippedServerScripts = {}
	local usedServerScripts = {}

	for _, commandScript in pairs(container:GetChildren()) do
		if commandScript:IsA("ModuleScript") then
			if not commandScript.Name:find("Server") then
				local serverCommandScript = container:FindFirstChild(commandScript.Name .. "Server")

				if serverCommandScript then
					usedServerScripts[serverCommandScript] = true
				end

				self:RegisterCommand(commandScript, serverCommandScript, filter)
			else
				skippedServerScripts[commandScript] = true
			end
		else
			self:RegisterCommandsIn(commandScript, filter)
		end
	end

	for skippedScript in pairs(skippedServerScripts) do
		if not usedServerScripts[skippedScript] then
			warn(
				`[Cmdr] Command script {skippedScript.Name} was skipped because it has 'Server' in its name, and has no equivalent shared script.`
			)
		end
	end
end

--[=[
	Registers the default commands on both the server and client.

	The optional `arrayOrFunc` parameter can be provided with:

	1. an array of strings — this will limit registration to only commands which have their `Group` property set to this
	2. a function which takes in a CommandDefinition and returns a `boolean` — only if `true` is returned will the command be registered

	@param arrayOrFunc {string} | (CommandDefinition) -> boolean | nil

	@server
	@within Registry
]=]
function Registry:RegisterDefaultCommands(arrayOrFunc: { string } | (any) -> boolean | nil)
	assert(RunService:IsServer(), "[Cmdr] RegisterDefaultCommands cannot be called from the client.")

	local dictionary = if type(arrayOrFunc) == "table" then Util.MakeDictionary(arrayOrFunc) else nil

	self:RegisterCommandsIn(self.Cmdr.DefaultCommandsFolder, dictionary ~= nil and function(command)
		return dictionary[command.Group] or false
	end or arrayOrFunc)
end

--[=[
	Returns the CommandDefinition from the given name, or nil if no command is found. Command aliases are also accepted.
	@return CommandDefinition?
	@within Registry
]=]
function Registry:GetCommand(name: string)
	name = name or ""
	return self.Commands[name:lower()]
end

--[=[
	Returns an array of all registers commands, not including aliases.
	@return {CommandDefinition}
	@within Registry
]=]
function Registry:GetCommands(): { any }
	return self.CommandsArray
end

--[=[
	Returns an array of containing the names of all registered commands, not including aliases.
	@within Registry
]=]
function Registry:GetCommandNames(): { string }
	local commands = {}

	for _, command in pairs(self.CommandsArray) do
		table.insert(commands, command.Name)
	end

	return commands
end

--[=[
	@method GetCommandsAsStrings
	@deprecated v1.8.0 -- This method was renamed to GetCommandNames in v1.8.0. The old name exists for backwards compatibility and should not be used for new work.
	@within Registry
]=]
Registry.GetCommandsAsStrings = Registry.GetCommandNames

--[=[
	Returns an array of containing the names of all registered types, not including aliases.
	@within Registry
]=]
function Registry:GetTypeNames(): { string }
	local typeNames = {}

	for typeName in pairs(self.Types) do
		table.insert(typeNames, typeName)
	end

	return typeNames
end

--[=[
	Returns the type definition from the given name, or nil if no argument is found.
	@return TypeDefinition?
	@within Registry
]=]
function Registry:GetType(name: string)
	return self.Types[name]
end

--[=[
	Returns a type name taking aliases into account. If there is no alias, the name parameter is simply returned as a pass through.
	@return TypeDefinition | string
	@within Registry
]=]
function Registry:GetTypeName(name: string): string | any
	return self.TypeAliases[name] or name
end

--[=[
	Registers a hook on the current realm (server/client). This should probably be ran on the server or in a hook module script, but can also work on the client.

	Hooks run in order of priority from lowest (running first) to highest.

	@param hookName HookType
	@param callback (CommandContext) -> string? -- returns nil for ok, string (errorText) for cancellation
	@param priority -- If unspecified, the priority will default to `0`.
	@within Registry
]=]
function Registry:RegisterHook(hookName: string, callback: (any) -> string?, priority: number)
	if not self.Hooks[hookName] then
		error(("[Cmdr] Invalid hook name: %q"):format(hookName), 2)
	end

	table.insert(self.Hooks[hookName], { callback = callback, priority = priority or 0 })
	table.sort(self.Hooks[hookName], function(a, b)
		return a.priority < b.priority
	end)
end

--[=[
	@method AddHook
	@deprecated v1.1.2 -- This method was renamed to RegisterHook in v1.1.2. The old name exists for backwards compatibility and should not be used for new work.
	@param hookName HookType
	@param callback (CommandContext) -> string? -- returns nil for ok, string (errorText) for cancellation
	@param priority number -- If unspecified, the priority will default to `0`.
	@within Registry
]=]
Registry.AddHook = Registry.RegisterHook

--[=[
	Returns a table saved with the given name. Always returns the same table on subsequent calls. Useful for commands that require persistent state, like bind or ban.
	This is the same as CommandContext.GetStore.
	@return table
	@within Registry
]=]
function Registry:GetStore(name: string)
	return self.Stores[name]
end

--[=[
	Calls Registry.FlushAutoExecBuffer at the end of the frame.
	@private
	@within Registry
]=]
function Registry:FlushAutoExecBufferDeferred()
	if self.AutoExecFlushConnection then
		return
	end

	self.AutoExecFlushConnection = RunService.Heartbeat:Connect(function()
		self.AutoExecFlushConnection:Disconnect()
		self.AutoExecFlushConnection = nil
		self:FlushAutoExecBuffer()
	end)
end

--[=[
	Runs all pending auto exec commands in Registry.AutoExecBuffer.
	@private
	@within Registry
]=]
function Registry:FlushAutoExecBuffer()
	for _, commandGroup in ipairs(self.AutoExecBuffer) do
		for _, command in ipairs(commandGroup) do
			self.Cmdr.Dispatcher:EvaluateAndRun(command)
		end
	end

	self.AutoExecBuffer = {}
end

return function(cmdr)
	Registry.Cmdr = cmdr

	return Registry
end
