const RunService = game:GetService("RunService")

const Util = require("./Util")

const IS_SERVER = RunService:IsServer()
const IS_CLIENT = RunService:IsClient()

const TYPE_METHODS = Util.MakeDictionary({
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
})
const COMMAND_METHODS = Util.MakeDictionary({
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
	"_scriptInstance",
})
const COMMAND_ARGUMENT_PROPERTIES = Util.MakeDictionary({ "Name", "Type", "Description", "Optional", "Default" })

const NIL_PROPERTIES = { "_autoExecFlushConnection" }

--[=[
	@class Registry
	The registry keeps track of all the commands and types that Cmdr knows about.
]=]

--[=[
	@within Registry
	@type HookType "BeforeRun" | "AfterRun" | "BeforeCommandRegister"
]=]

--[=[
	@within Registry
	@interface ArgumentDefinition
	.Type string | TypeDefinition -- The argument type (case sensitive), or an [inline TypeDefinition object](/docs/reference/commands#dynamic-arguments-and-inline-types).
	.Name string -- The argument name, this is displayed to the user as they type.
	.Description string? -- A description of what the argument is, this is also displayed to the user.
	.Optional boolean? -- If this is set to `true`, then the user can run the command without filling out the value. In which case, the argument will be sent to implementations as `nil`.
	.Default any? -- If present, the argument will be automatically made optional, so if the user doesn't supply a value, implementations will receive whatever the value of `Default` is.

	The `table` definition, usually contained in a [CommandDefinition](#CommandDefinition), which 'defines' the argument.
]=]

--[=[
	@within Registry
	@interface CommandDefinition
	.Name string -- The name of the command
	.Aliases {string}? -- Aliases which aren't part of auto-complete, but if matched will run this command just the same. For example, `m` might be an alias of `announce`.
	.Description string? -- A description of the command, displayed to the user in the `help` command and auto-complete menu.
	.Group string? -- This property is intended to be used in hooks, so that you can categorise commands and decide if you want a specific user to be able to run them or not. But the `help` command will use them as headings.
	.Args {ArgumentDefinition | (CommandContext) -> (ArgumentDefinition)} -- Arguments for the command; this is technically optional but if you have no args, set it to `{}` or you may experience some interface weirdness.
	.Data (CommandContext, ...) -> any -- If your command needs to gather some extra data from the client that's only available on the client, then you can define this function. It should accept the command context and tuple of transformed arguments, and return a single value which will be available in the command with [CommandContext:GetData](/api/CommandContext#GetData).
	.ClientRun (CommandContext, ...) -> string? -- If you want your command to run on the client, you can add this function to the command definition itself. It works exactly like the function that you would return from the Server module. If this function returns a string, the command will run entirely on the client and won't touch the server (which means server-only hooks won't run). If this function doesn't return anything, it will fall back to executing the Server module on the server.
	.Run (CommandContext, ...) -> string? -- An older version of ClientRun. There are very few scenarios where this is preferred to ClientRun (so, in other words, don't use it!). These days, `Run` is only used for some dark magic involving server-sided command objects.
	._isDefault boolean -- Whether this command is provided by Cmdr itself rather than registered by the developer.
	._isHidden boolean -- Whether this command is hidden from the command list, help, and auto-complete.
]=]

--[=[
	@within Registry
	@interface TypeDefinition
	.Prefixes string? -- String containing [prefixed union types](/docs/reference/commands#prefixed-union-types) for this type. This property should omit the inital type, so the string should begin with a prefix character, e.g. `Prefixes = "# integer ! boolean"`
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
	@within Registry
	@readonly

	@prop Cmdr Cmdr | CmdrClient

	A reference to Cmdr. This may either be the server or client version of Cmdr depending on where the code is running.
]=]

--[=[
	@within Registry
	@readonly
	@private

	@prop _types table

	A collection of all types.
]=]

--[=[
	@within Registry
	@readonly
	@private

	@prop _typeAliases table

	A collection of all types and their names.
]=]

--[=[
	@within Registry
	@readonly
	@private

	@prop _commands table

	A collection of all registered commands.
]=]

--[=[
	@within Registry
	@readonly
	@private

	@prop _commandsArray table

	An array of all command objects.
]=]

--[=[
	@within Registry
	@readonly
	@private

	@prop _hooks { [HookType]: table }

	A collection of all registered hooks.
]=]

--[=[
	@within Registry
	@readonly
	@private

	@prop _autoExecBuffer table

	A buffer containing pending auto-execute commands waiting to be flushed.
]=]

--[=[
	@within Registry
	@readonly
	@private

	@prop _autoExecFlushConnection RBXScriptConnection?

	A connection used to defer flushing the auto-execute buffer until the end of the frame.
]=]

--[=[
	@prop _stores table
	@within Registry
	@readonly
	@private
]=]

const Registry = {
	Cmdr = nil :: any,

	_types = {},
	_typeAliases = {},

	_commands = {},
	_commandsArray = {},

	_hooks = {
		BeforeRun = {},
		AfterRun = {},
		BeforeCommandRegister = {},
	},

	_autoExecBuffer = {},
	_autoExecFlushConnection = nil,

	_stores = setmetatable({}, {
		__index = function(self, key)
			self[key] = {}
			return self[key]
		end,
	}),
}

--[=[
	@within Registry

	@param name -- The name of the type, this must be unique, alphanumeric, and start with a lower-case letter or digit.
	@param typeObject TypeDefinition

	Registers a type on the current realm (server/client), this function should be called from within the type definition ModuleScript.
]=]
function Registry:RegisterType(name: string, typeObject: any)
	assert(typeof(name) == "string", `[Cmdr] Invalid type name provided: {tostring(name)}`)
	assert(
		name:find("^[%d%l]%w*$") ~= nil,
		`[Cmdr] Invalid type name provided: "{name}", type names must be alphanumeric and start with a lowercase letter or digit.`
	)

	for key in pairs(typeObject) do
		assert(TYPE_METHODS[key] ~= nil, `[Cmdr] Unknown key/method in type "{name}": {key}`)
	end

	assert(self._types[name] == nil, `[Cmdr] Type "{name}" has already been registered.`)

	typeObject.Name = name
	typeObject.DisplayName = typeObject.DisplayName or name

	self._types[name] = typeObject

	if typeObject.Prefixes then
		self:RegisterTypePrefix(name, typeObject.Prefixes)
	end
end

--[=[
	@within Registry

	@param name -- The name of the type.
	@param union -- The string should omit the initial type name, so this string should begin with a prefix character, e.g. `# integer ! boolean`

	Registers a Prefixed Union Type string on the current realm (server/client), this function should be called from within the type definition ModuleScript.
	If there are already type prefixes for the given type name, they will be concatenated. This allows you to add prefixes to default types, like `players`.
]=]
function Registry:RegisterTypePrefix(name: string, union: string)
	if not self._typeAliases[name] then
		self._typeAliases[name] = name
	end

	self._typeAliases[name] = `{self._typeAliases[name]} {union}`
end

--[=[
	@within Registry

	@param name -- The name of the type, this must be unique, alphanumeric, and start with a lower-case letter or digit.
	@param alias -- The string should *include* the initial type name, e.g. `string # integer ! boolean`

	Allows you to register a name which will be expanded into a longer type which can be used as a command argument type.
	For example, if you register the alias `stringOrNumber` it could be interpreted as `string # number` when used.
]=]
function Registry:RegisterTypeAlias(name: string, alias: string)
	assert(self._typeAliases[name] == nil, `[Cmdr] Type alias "{name}" already exists!`)

	self._typeAliases[name] = alias
end

--[=[
	@within Registry
	@server

	Registers all types from a container.
]=]
function Registry:RegisterTypesIn(container: Instance)
	for _, object in pairs(container:GetChildren()) do
		if object:IsA("ModuleScript") then
			object.Parent = self.Cmdr._replicatedRoot.Types

			require(object)(self)
		else
			self:RegisterTypesIn(object)
		end
	end
end

-- These are exactly the same thing. No one will notice. Except for you, dear reader.
--[=[
	@within Registry
	@method RegisterHooksIn
	@server

	@param container Instance

	Registers all hooks from within a container on both the server and client.
	If you want to add a hook only on the server or client – e.g. for logging – then you should use the Register.RegisterHook method instead.
]=]
Registry.RegisterHooksIn = Registry.RegisterTypesIn

--[=[
	@within Registry
	@private

	@param commandObject CommandDefinition

	Validates the arguments of a provided Command Object.
	Errors if an invalid property exists.
]=]
function Registry:_validateCommandArguments(commandObject: any)
	for index, argument in pairs(commandObject.Args) do
		if type(argument) ~= "table" then
			continue
		end

		for key in pairs(argument) do
			assert(
				COMMAND_ARGUMENT_PROPERTIES[key],
				`[Cmdr] Unknown property in command "{commandObject.Name or "unknown"}" argument #{index}: {key}`
			)
		end
	end
end

--[=[
	@within Registry
	@private

	@param commandObject CommandDefinition

	Validates the properties of a provided Command Object.
	Errors if an invalid property exists.
]=]
function Registry:_validateCommand(commandObject: any)
	for key in pairs(commandObject) do
		assert(
			COMMAND_METHODS[key],
			`[Cmdr] Unknown key/method in command "{commandObject.Name or "unknown command"}": {key}`
		)
	end

	if commandObject.Args then
		self:_validateCommandArguments(commandObject)
	end
end

--[=[
	@within Registry

	@param commandObject CommandDefinition
	@param isDefault boolean? -- True if this is a built-in Cmdr command
	@return boolean -- Returns true if registration succeeded or false if aborted due to a developer override

	Register a command purely based on its definition.
	Prefer using Registry:RegisterCommand for proper handling of client/server model.
]=]
function Registry:RegisterCommandObject(commandObject: any, isDefault: boolean?): boolean
	self:_validateCommand(commandObject) -- Error if the command object isn't valid

	commandObject._isDefault = isDefault == true
	commandObject._isHidden = false

	if IS_CLIENT then
		const beforeCommandRegisterHook = self.Cmdr.Dispatcher:_runBeforeCommandRegisterHookForCommand(commandObject)
		commandObject._isHidden = beforeCommandRegisterHook ~= nil and beforeCommandRegisterHook ~= true

		if commandObject.AutoExec then
			table.insert(self._autoExecBuffer, commandObject.AutoExec)
			self:_flushAutoExecBufferDeferred()
		end
	end

	const commandName = commandObject.Name:lower()
	const existingCommand = self._commands[commandName]
	if existingCommand then
		const existingIsDefault = existingCommand._isDefault

		if isDefault and not existingIsDefault then
			warn(
				`[Cmdr] Ignored default command "{commandObject.Name}" because a custom developer command is already registered with this name.`
			)
			return false
		end

		if not isDefault and existingIsDefault then
			warn(`[Cmdr] Custom command "{commandObject.Name}" has replaced the default built-in command.`)
		elseif not isDefault and not existingIsDefault then
			warn(`[Cmdr] Custom command "{commandObject.Name}" was overwritten by a newer custom command.`)
		else
			warn(`[Cmdr] Default command "{commandObject.Name}" was overwritten by a newer default command.`)
		end

		if IS_SERVER and existingCommand._scriptInstance then
			existingCommand._scriptInstance:Destroy()
		end

		const commandIndex = table.find(self._commandsArray, existingCommand)
		if commandIndex then
			self._commandsArray[commandIndex] = commandObject
		else
			table.insert(self._commandsArray, commandObject)
		end

		if existingCommand.Aliases then
			for _, alias in pairs(existingCommand.Aliases) do
				self._commands[alias:lower()] = nil
			end
		end
	else
		table.insert(self._commandsArray, commandObject)
	end

	self._commands[commandName] = commandObject

	if commandObject.Aliases then
		for _, alias in pairs(commandObject.Aliases) do
			self._commands[alias:lower()] = commandObject
		end
	end

	return true
end

--[=[
	@within Registry

	@param filter ((CommandDefinition) -> boolean)? -- If present, will be passed a command definition which will then only be registered if the function returns `true`.

	Registers a command definition and its server equivalent.
	Handles replicating the definition to the client.
]=]
function Registry:RegisterCommand(
	commandScript: ModuleScript,
	commandServerScript: ModuleScript?,
	filter: ((any) -> boolean)?,
	isDefault: boolean?
)
	local commandObject = require(commandScript)
	assert(
		typeof(commandObject) == "table",
		`[Cmdr] Invalid return value from command script "{commandScript.Name}" (CommandDefinition expected, got {typeof(
			commandObject
		)})`
	)

	if commandServerScript then
		assert(IS_SERVER, "[Cmdr] The commandServerScript parameter is not valid for client usage.")
		commandObject.Run = require(commandServerScript)
	end

	if filter and not filter(commandObject) then
		return
	end

	commandObject._scriptInstance = commandScript

	const success = self:RegisterCommandObject(commandObject, isDefault)
	if success then
		commandScript.Parent = self.Cmdr._replicatedRoot.Commands
	end
end

--[=[
	@within Registry

	@param filter ((CommandDefinition) -> boolean)? -- If present, will be passed a command definition which will then only be registered if the function returns `true`.

	Registers all commands from within a container on both the server and client.
	Module scripts which include `Server` in their name will not be sent to the client.
]=]
function Registry:RegisterCommandsIn(container: Instance, filter: ((any) -> boolean)?, isDefault: boolean?)
	local skippedServerScripts = {}
	local usedServerScripts = {}
	for _, commandScript in pairs(container:GetChildren()) do
		if commandScript:IsA("ModuleScript") then
			if not commandScript.Name:find("Server") then
				const serverCommandScript = container:FindFirstChild(`{commandScript.Name}Server`)
				if serverCommandScript then
					usedServerScripts[serverCommandScript] = true
				end

				self:RegisterCommand(commandScript, serverCommandScript, filter, isDefault)
			else
				skippedServerScripts[commandScript] = true
			end
		else
			self:RegisterCommandsIn(commandScript, filter, isDefault)
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
	@within Registry
	@server

	@param arrayOrFunc {string} | (CommandDefinition) -> boolean | nil

	Registers the default commands on both the server and client.

	The optional `arrayOrFunc` parameter can be provided with:

	1. an array of strings — this will limit registration to only commands which have their `Group` property set to this
	2. a function which takes in a CommandDefinition and returns a `boolean` — only if `true` is returned will the command be registered

	If a custom developer command is registered with the same name or alias as a default command, the developer command will take precedence and replace the default built-in command.
]=]
function Registry:RegisterDefaultCommands(arrayOrFunc: { string } | (any) -> boolean | nil)
	assert(IS_SERVER, "[Cmdr] RegisterDefaultCommands cannot be called from the client.")

	const dictionary = if type(arrayOrFunc) == "table" then Util.MakeDictionary(arrayOrFunc) else nil
	local filter

	if dictionary ~= nil then
		function filter(command)
			return dictionary[command.Group] or false
		end
	else
		filter = arrayOrFunc
	end

	self:RegisterCommandsIn(self.Cmdr._defaultCommandsFolder, filter, true)
end

--[=[
	@within Registry
	@return CommandDefinition?

	Returns the CommandDefinition from the given name, or nil if no command is found. Command aliases are also accepted.
]=]
function Registry:GetCommand(name: string)
	return self._commands[name:lower()]
end

--[=[
	@within Registry
	@return {CommandDefinition}

	Returns an array of all registers commands, not including aliases.
]=]
function Registry:GetCommands(): { any }
	return self._commandsArray
end

--[=[
	@within Registry
	Returns an array of containing the names of all registered commands, not including aliases.
]=]
function Registry:GetCommandNames(includeAliases: boolean?): { string }
	local commands = {}

	for _, command in pairs(self._commandsArray) do
		if command._isHidden then
			continue
		end

		if includeAliases and typeof(command.Aliases) == "table" then
			for _, alias in pairs(command.Aliases) do
				table.insert(commands, alias)
			end
		end

		table.insert(commands, command.Name)
	end

	return commands
end

--[=[
	@within Registry
	@method GetCommandsAsStrings
	@deprecated v1.8.0 -- This method was renamed to GetCommandNames in v1.8.0. The old name exists for backwards compatibility and should not be used for new work.
]=]
Registry.GetCommandsAsStrings = Registry.GetCommandNames
Util:_registerDeprecationWarning(
	"GetCommandsAsStrings",
	"This method was renamed to GetCommandNames in v1.8.0. The old name exists for backwards compatibility and should not be used for new work."
)

--[=[
	@within Registry
	Returns an array of containing the names of all registered types, not including aliases.
]=]
function Registry:GetTypeNames(): { string }
	local typeNames = {}

	for typeName in pairs(self._types) do
		table.insert(typeNames, typeName)
	end

	return typeNames
end

--[=[
	@within Registry
	@return TypeDefinition?

	Returns the type definition from the given name, or nil if no argument is found.
]=]
function Registry:GetType(name: string)
	return self._types[name]
end

--[=[
	@within Registry
	@return TypeDefinition | string

	Returns a type name taking aliases into account. If there is no alias, the name parameter is simply returned as a pass through.
]=]
function Registry:GetTypeName(name: string): string | any
	return self._typeAliases[name] or name
end

--[=[
	@within Registry

	@param hookName HookType
	@param callback (CommandContext) -> string? -- returns nil for ok, string (errorText) for cancellation
	@param priority number? -- If unspecified, the priority will default to `0`.

	Registers a hook on the current realm (server/client). This should probably be ran on the server or in a hook module script, but can also work on the client.
	Hooks run in order of priority from lowest (running first) to highest.
]=]
function Registry:RegisterHook(hookName: string, callback: (any) -> string?, priority: number?)
	assert(self._hooks[hookName], `[Cmdr] Invalid hook name: {hookName}`)

	table.insert(self._hooks[hookName], { callback = callback, priority = priority or 0 })
	table.sort(self._hooks[hookName], function(a, b)
		return a.priority < b.priority
	end)
end

--[=[
	@within Registry
	@method AddHook
	@deprecated v1.1.2 -- This method was renamed to RegisterHook in v1.1.2. The old name exists for backwards compatibility and should not be used for new work.
]=]
Registry.AddHook = Registry.RegisterHook
Util:_registerDeprecationWarning(
	"AddHook",
	"This method was renamed to RegisterHook in v1.1.2. The old name exists for backwards compatibility and should not be used for new work."
)

--[=[
	@within Registry
	@return table

	Returns a table saved with the given name. Always returns the same table on subsequent calls. Useful for commands that require persistent state, like bind or ban.
	This is the same as CommandContext.GetStore.
]=]
function Registry:GetStore(name: string)
	return self._stores[name]
end

--[=[
	@within Registry
	@private

	Runs all pending auto exec commands in Registry.AutoExecBuffer.
]=]
function Registry:_flushAutoExecBuffer()
	for _, commandGroup in ipairs(self._autoExecBuffer) do
		for _, command in ipairs(commandGroup) do
			self.Cmdr.Dispatcher:EvaluateAndRun(command)
		end
	end

	self._autoExecBuffer = {}
end

--[=[
	@within Registry
	@private

	Calls Registry.FlushAutoExecBuffer at the end of the frame.
]=]
function Registry:_flushAutoExecBufferDeferred()
	if self._autoExecFlushConnection then
		return
	end

	self._autoExecFlushConnection = RunService.Heartbeat:Connect(function()
		self._autoExecFlushConnection:Disconnect()
		self._autoExecFlushConnection = nil
		self:_flushAutoExecBuffer()
	end)
end

-- Export Registry
Registry.__index = Registry
Registry.__newindex = Registry

export type Registry = typeof(setmetatable(Registry, Registry))

return function(Cmdr): Registry
	const ProtectedRegistry = { Cmdr = Cmdr }
	return setmetatable(ProtectedRegistry, {
		__index = function(_, key)
			if Util._deprecationWarnings[key] then
				Util:_emitDeprecationWarning(key)
			end

			const value = Registry[key]
			assert(value or table.find(NIL_PROPERTIES, key), `[Cmdr] Registry has no method or property "{key}".`)
			return value
		end,
		__newindex = function(_, key, value)
			assert(
				table.find(NIL_PROPERTIES, key) or Registry[key],
				`[Cmdr] Cannot assign key "{key}"; the Registry is read-only.`
			)
			Registry[key] = value
		end,
	}) :: Registry
end
