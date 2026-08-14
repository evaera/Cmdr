# Cookbook

Welcome to the Cmdr cookbook! Here you will find practical recipes and code patterns for implementing common administrative workflows, custom user interfaces, and advanced network routines.

---

## Sending custom client notifications with network events

Cmdr allows commands running on the server to dispatch messages to specific clients or broadcast them to every client using `context:SendEvent` and `context:BroadcastEvent`.

This recipe demonstrates how to create a `notify` command that safely filters text input and sends a titled pop-up notification with custom durations to targeted players.

:::warning Text Filtering Requirements

Roblox requires all user-generated text displayed to other players to be filtered on the server. Failure to filter user input can lead to moderation action.

:::

### Command definition (`notify.luau`)

Define the command structure, requiring target players, a title, a body message, and an optional duration.

```luau
return {
	Name = "notify",
	Aliases = { "toast" },
	Description = "Sends a client-side screen notification to targeted players.",
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Targets",
			Description = "The player(s) who will receive the notification",
		},
		{
			Type = "string",
			Name = "Title",
			Description = "The header title of the notification",
		},
		{
			Type = "string",
			Name = "Message",
			Description = "The main body text of the notification",
		},
		{
			Type = "duration",
			Name = "Duration",
			Description = "How long the notification stays on screen",
			Optional = true,
			Default = 5,
		},
	},
}
```

---

### Server implementation (`notifyServer.luau`)

Filter both the `Title` and `Message` arguments through `TextService:FilterStringAsync()` using the command executor's `UserId`. Once filtered, dispatch the payload to the target clients.

```luau
const TextService = game:GetService("TextService")

const function filterText(text: string, fromUserId: number): string?
	const success, filterResult = pcall(TextService.FilterStringAsync, TextService, text, fromUserId)

	if not (success and filterResult) then
		return
	end

	const broadcastSuccess, filteredString = pcall(filterResult.GetNonChatStringForBroadcastAsync, filterResult)

	return broadcastSuccess and filteredString
end

return function(context: any, targets: { Player }, title: string, message: string, duration: number): string
	const authorUserId = context.Executor.UserId

	-- Filter title and message before sending to target players
	const filteredTitle = filterText(title, authorUserId)
	const filteredMessage = filterText(message, authorUserId)

	if not (filteredTitle and filteredMessage) then
		return "Failed to filter notification text."
	end

	for _, player in ipairs(targets) do
		context:SendEvent(player, "ShowNotification", filteredTitle, filteredMessage, duration)
	end

	return `Notification sent to {#targets} player(s).`
end
```

:::tip Broadcasting to Everyone

If you want to broadcast a notification to every connected player at once, use `context:BroadcastEvent("ShowNotification", filteredTitle, filteredMessage, duration)` instead of looping over players.

:::

---

### Client event listener (`CmdrClient.luau`)

Register a listener on the client with `CmdrClient:HandleEvent` to receive the filtered payload and trigger your UI logic.

```luau
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const StarterGui = game:GetService("StarterGui")

const Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

-- Listen for the custom "ShowNotification" network event
Cmdr:HandleEvent("ShowNotification", function(title: string, message: string, duration: number)
	-- Replace this with your custom UI/notification framework logic
	print(`[Notification Received] {title}: {message} (Duration: {duration}s)`)

	-- Example StarterGui notification call:
	StarterGui:SetCore("SendNotification", {
		Title = title,
		Text = message,
		Duration = duration,
	})
end)
```

---

{/* Keep this the last one. */}
{/* and, no, MDX doesn't support HTML comments */}

## Adding Luau LSP type definitions

Luau Language Server (Luau LSP) gives you autocomplete, static type checking, and hover documentation inside your code editor. By adding a central definition file to your project, Luau recognizes types like `CommandContext`, `Registry`, and `CommandDefinition` without requiring manual annotations in every script.

### Setup (`CmdrTypes.luau`)

Create a script named `CmdrTypes.luau` inside your project root or type definitions folder. Exporting these types allows Luau LSP to infer parameter structures automatically when typing command definitions or registry hooks.

```luau
export type HookType = "BeforeRun" | "AfterRun" | "BeforeCommandRegister"

export type HookCallback = (CommandContext) -> string?

export type BuiltInTypeName =
	"string"
	| "strings"
	| "number"
	| "numbers"
	| "integer"
	| "integers"
	| "positiveInteger"
	| "positiveIntegers"
	| "nonNegativeInteger"
	| "nonNegativeIntegers"
	| "byte"
	| "bytes"
	| "digit"
	| "digits"
	| "boolean"
	| "booleans"
	| "player"
	| "players"
	| "playerId"
	| "playerIds"
	| "team"
	| "teams"
	| "teamPlayers"
	| "teamColor"
	| "teamColors"
	| "brickColor"
	| "brickColors"
	| "brickColor3"
	| "brickColor3s"
	| "color3"
	| "color3s"
	| "hexColor3"
	| "hexColor3s"
	| "vector3"
	| "vector3s"
	| "vector2"
	| "vector2s"
	| "positionVector3"
	| "positionVector3s"
	| "duration"
	| "durations"
	| "command"
	| "commands"
	| "type"
	| "types"
	| "userInput"
	| "userInputs"
	| "storedKey"
	| "storedKeys"
	| "url"
	| "urls"
	| "json"
	| "mathOperator"

export type AutocompleteOptions = {
	IsPartial: boolean?,
}

export type TypeDefinition<T = any> = {
	Name: string?,
	DisplayName: string?,
	Prefixes: string?,
	Listable: boolean?,
	ArgumentOperatorAliases: { [string]: string }?,
	Default: ((Player) -> string)?,
	Transform: ((text: string, executor: Player) -> T)?,
	Validate: ((value: T) -> (boolean, string?))?,
	ValidateOnce: ((value: T) -> (boolean, string?))?,
	Autocomplete: ((value: T) -> ({ string }, AutocompleteOptions?))?,
	Parse: (value: T) -> any,
}

export type ArgumentDefinition = {
	Type: BuiltInTypeName | string | TypeDefinition<any>,
	Name: string,
	Description: string?,
	Optional: boolean?,
	Default: any?,
}

export type ArgumentContext = {
	Command: CommandContext,
	Type: TypeDefinition<any>,
	Name: string,
	Object: ArgumentDefinition,
	Required: boolean,
	Executor: Player,
	RawValue: string,
	RawSegments: { string },
	Prefix: string,

	GetTransformedValue: (self: ArgumentContext, segment: number) -> ...any,
	Validate: (self: ArgumentContext, isFinal: boolean?) -> (boolean, string?),
	GetAutocomplete: (self: ArgumentContext) -> ({ string }, AutocompleteOptions?),
	GetValue: (self: ArgumentContext) -> any,
}

export type CommandDefinition = {
	Name: string,
	Aliases: { string }?,
	Description: string?,
	Group: string?,
	Args: { ArgumentDefinition | (CommandContext) -> ArgumentDefinition? },
	Data: ((CommandContext, ...any) -> any)?,
	ClientRun: ((CommandContext, ...any) -> string?)?,
	Run: ((CommandContext, ...any) -> string?)?,
	Guards: { (CommandContext, ...any) -> string? }?,
	AutoExec: { string }?,

	_isDefault: boolean?,
	_isHidden: boolean?,
	_scriptInstance: ModuleScript?,
}

export type CommandContext = {
	Dispatcher: Dispatcher,
	Cmdr: CmdrLike,
	Name: string,
	RawText: string,
	Object: CommandDefinition,
	Group: string?,
	State: { [any]: any },
	Aliases: { string }?,
	Alias: string,
	Description: string?,
	Executor: Player,
	ArgumentDefinitions: { ArgumentDefinition | (CommandContext) -> ArgumentDefinition? },
	RawArguments: { string },
	Arguments: { ArgumentContext },
	Data: any,
	Response: string?,
	Guards: { (CommandContext, ...any) -> string? }?,

	Parse: (self: CommandContext, allowIncompleteArguments: boolean?) -> (boolean, string?),
	Validate: (self: CommandContext, isFinal: boolean?) -> (boolean, string),
	GetLastArgument: (self: CommandContext) -> ArgumentContext?,
	GatherArgumentValues: (self: CommandContext) -> ({ any }, number),
	Run: (self: CommandContext) -> string?,
	GetArgument: (self: CommandContext, index: number) -> ArgumentContext?,
	GetData: (self: CommandContext) -> any,
	SendEvent: (self: CommandContext, player: Player, event: string, ...any) -> (),
	BroadcastEvent: (self: CommandContext, event: string, ...any) -> (),
	Reply: (self: CommandContext, text: string, options: any?) -> (),
	GetStore: (self: CommandContext, name: string) -> { [any]: any },
	HasImplementation: (self: CommandContext) -> boolean,
}

export type Registry = {
	Cmdr: CmdrLike,

	RegisterType: (self: Registry, name: string, typeObject: TypeDefinition<any>) -> (),
	RegisterTypePrefix: (self: Registry, name: string, union: string) -> (),
	RegisterTypeAlias: (self: Registry, name: string, alias: string) -> (),
	RegisterTypesIn: (self: Registry, container: Instance) -> (),
	RegisterHooksIn: (self: Registry, container: Instance) -> (),

	RegisterCommandObject: (self: Registry, commandObject: CommandDefinition, isDefault: boolean?) -> boolean,
	RegisterCommand: (
		self: Registry,
		commandScript: ModuleScript,
		commandServerScript: ModuleScript?,
		filter: ((CommandDefinition) -> boolean)?,
		isDefault: boolean?
	) -> (),
	RegisterCommandsIn: (
		self: Registry,
		container: Instance,
		filter: ((CommandDefinition) -> boolean)?,
		isDefault: boolean?
	) -> (),
	RegisterDefaultCommands: (self: Registry, arrayOrFunc: ({ string } | (CommandDefinition) -> boolean)?) -> (),

	GetCommand: (self: Registry, name: string) -> CommandDefinition?,
	GetCommands: (self: Registry) -> { CommandDefinition },
	GetCommandNames: (self: Registry, includeAliases: boolean?) -> { string },
	GetCommandsAsStrings: (self: Registry, includeAliases: boolean?) -> { string },

	GetTypeNames: (self: Registry) -> { string },
	GetType: (self: Registry, name: string) -> TypeDefinition<any>?,
	GetTypeName: (self: Registry, name: string) -> string,
	RegisterHook: (self: Registry, hookName: HookType, callback: HookCallback, priority: number?) -> (),
	AddHook: (self: Registry, hookName: HookType, callback: HookCallback, priority: number?) -> (),
	GetStore: (self: Registry, name: string) -> { [any]: any },
}

export type Dispatcher = {
	Cmdr: CmdrLike,
	Registry: Registry,
	Evaluate: (
		self: Dispatcher,
		text: string,
		executor: Player,
		allowIncompleteArguments: boolean?,
		data: any?
	) -> (CommandContext | false, string?),
	EvaluateAndRun: (
		self: Dispatcher,
		text: string,
		executor: Player?,
		options: { Data: any?, IsHuman: boolean? }?
	) -> string,
	Send: (self: Dispatcher, text: string, data: any?) -> string,
	SendEvent: (self: Dispatcher, player: Player, event: string, ...any) -> (),
	BroadcastEvent: (self: Dispatcher, event: string, ...any) -> (),
	Run: (self: Dispatcher, ...any) -> string,
	GetHistory: (self: Dispatcher) -> { string },
	RunBeforeCommandRegisterHooks: (self: Dispatcher, player: Player?) -> (),
}

export type FuzzyFinder = (text: string, returnFirst: boolean?, matchStart: boolean?) -> any

export type Util = {
	MakeDictionary: (array: { any }) -> { [any]: true },
	DictionaryKeys: (dict: { [any]: any }) -> { any },
	MakeFuzzyFinder: (setOrContainer: any) -> FuzzyFinder,
	GetNames: (instances: any) -> { string },
	SplitStringSimple: (input: string, separator: string?) -> { string },
	SplitString: (text: string, max: number?) -> { string },
	SplitPrioritizedDelimeter: (text: string, delimiters: { string }) -> { string }?,
	TrimString: (str: string) -> string,
	ParseEscapeSequences: (text: string) -> string,
	MakeEnumType: (name: string, values: { any }) -> TypeDefinition<any>,
	MakeListableType: (typeDefinition: TypeDefinition<any>, override: { [string]: any }?) -> TypeDefinition<any>,
	ParsePrefixedUnionType: (typeValue: string, rawValue: string) -> (string?, string?, string?),
	RunCommandString: (dispatcher: Dispatcher, commandString: string) -> string?,
	RunEmbeddedCommands: (dispatcher: Dispatcher, str: string) -> string,
	SubstituteArgs: (str: string, replace: any) -> string,
	MakeAliasCommand: (name: string, commandString: string) -> CommandDefinition,
	Map: <T, U>(array: { T }, callback: (T, number) -> U) -> { U },
	Each: (callback: (any) -> any, ...any) -> ...any,

	SuppressDeprecationWarning: (self: Util, names: string | { string }) -> (),
}

export type Cmdr = {
	Registry: Registry,
	Dispatcher: Dispatcher,
	Util: Util,
}

export type ToggledSignal = {
	Connect: (self: ToggledSignal, callback: (visible: boolean) -> ()) -> RBXScriptConnection,
	Fire: (self: ToggledSignal, visible: boolean) -> (),
}

export type CmdrClient = {
	Registry: Registry,
	Dispatcher: Dispatcher,
	Util: Util,
	Gui: ScreenGui?,
	Toggled: ToggledSignal,

	SetEnabled: (self: CmdrClient, enabled: boolean) -> (),
	SetActivationKeys: (self: CmdrClient, keys: { Enum.KeyCode }) -> (),
	SetActivationUnlocksMouse: (self: CmdrClient, enabled: boolean) -> (),
	Show: (self: CmdrClient) -> (),
	Hide: (self: CmdrClient) -> (),
	Toggle: (self: CmdrClient) -> (),
	SetMashToEnable: (self: CmdrClient, enabled: boolean) -> (),
	SetHideOnLostFocus: (self: CmdrClient, enabled: boolean) -> (),
	SetPlaceName: (self: CmdrClient, name: string) -> (),
	HandleEvent: (self: CmdrClient, name: string, callback: (...any) -> ()) -> (),
}

export type CmdrLike = Cmdr | CmdrClient

return nil
```

---

### Usage example

To enforce these types inside your command definitions or execution scripts, import `CmdrTypes` at the top of your module:

```luau
const CmdrTypes = require(path.to.CmdrTypes)

const command: CmdrTypes.CommandDefinition = {
	Name = "teleport",
	Description = "Teleports target players to a destination.",
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Targets",
			Description = "Players to move.",
		},
	},
}

return command
```


