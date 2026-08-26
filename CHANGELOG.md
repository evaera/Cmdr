# Changelog

## v1.13.0 (currently rc.3)

*This is currently a prerelease version. Assuming no bugs, it will become `v1.13.0`. This version is expected to be stable but has not been as widely tested as we'd like.*

It's been a long time since the last release and there have been [a lot of changes](https://github.com/evaera/Cmdr/compare/v1.12.0...v1.13.0-rc.3), purely internal ones have been skipped over.

### Highlights

**New website**

Cmdr has a [new website](https://eryn.io/Cmdr), rebuilt from scratch using Docusaurus and Moonwave.

The new website has updated documentation pages, including [guides on topics like permissions](https://eryn.io/Cmdr/docs/permissions), [creating custom types](https://eryn.io/Cmdr/docs/customtypes), [Cmdr's security model](https://eryn.io/Cmdr/docs/security) as well as a [cookbook of examples](https://eryn.io/Cmdr/docs/cookbook).

The [API reference](https://eryn.io/Cmdr/api/Cmdr) now uses Moonwave, meaning it'll always be kept up-to-date with Cmdr's source, and you can view a wider range of methods. Note that although _private_ properties and methods aren't restricted (you _can_ use them), they might be broken without warning by updates.

This has been the main bottleneck for this update. Going forward, new releases should be much simpler and more frequent (but still only when needed and with backwards-compatibility as a top priority).

The previous Cmdr website used obsolete technology and was last updated in 2020. A copy of it is still available at [https://eryn.io/Cmdr/legacy](https://eryn.io/Cmdr/legacy/).

Note that we haven't created any redirects, either from the old pages or from the temporary `Cmdr/alpha` and `Cmdr/beta` pages, due to technical limitations.

**Guards**

Command definitions now include a [`Guards`](https://eryn.io/Cmdr/docs/guards) element. This allows command-specific check functions to be attached, which in turn can be reused across commands. For example, `hasAliveCharacter` could be pulled from a shared module and used in many commands.

**New builtin commands**

Roblox introduced a ban API in June 2024. We've added two `DefaultAdmin` commands: `ban` and `unban` which use these.

We've added an `exit` `DefaultUtil` command, which will close the Cmdr window.

This will be automatically included if you run [`Cmdr:RegisterDefaultCommands()`](https://eryn.io/Cmdr/api/Registry#RegisterDefaultCommands)

Developer commands will [automatically supersede builtin commands](https://github.com/evaera/Cmdr/commit/49de87e516dca385dbfdbeb0260e2d706ef8c468). This would usually happen anyway, but now it's explicit, instead of being at risk to race conditions.

**Relative positions**

`teleport` builtin command now uses the new `positionVector3` builtin type (the `vector3` builtin type has not been changed).

This type allows you to use `~[studs]` (where `[studs]` is a number of studs) for any part (or all) of a position, which will be calculated relative to your character's position (or `0` if you don't have a character). For example:

- `tp . @~,~5,~` will teleport you 5 studs into the air, and correspondingly `tp . @~,~-5,~` will teleport you 5 studs into the ground.
- `tp . @200,~,200` will teleport you to `200, 200` on the X and Z axes but not change your Y axis.

**Deprecation warnings**

Cmdr is over 8 years old, and we maintain as much compatibility as possible with previous versions. In order to avoid future pain, we've added deprecation warnings, for example when using the old name of a method or when using proxy calls like `Cmdr:RegisterCommandsIn` instead of `Cmdr.Registry:RegisterCommandsIn`.

You can turn off specific deprecation warnings with [`[Cmdr/CmdrClient].Util:SuppressDeprecationWarning`](https://eryn.io/Cmdr/api/Util/#SuppressDeprecationWarning).

Deprecation warnings are emitted with the following format `[Cmdr] [DeprecationWarning::{the name of the deprecation warning}]`, followed by the content of the warning, and a stack trace.

### Changes that might break you

- If a `Cmdr` instance exists in `StarterGui`, CmdrClient will always `PlayerGui:WaitForChild("Cmdr")` before loading. This might break you if you've [customized the interface](https://eryn.io/Cmdr/docs/customizinginterface) and do custom character loading.

- `blink` and `thru` builtin commands now ignore non-collidable parts. This might break you [if you blink to touchable but not collidable parts for triggering events](https://github.com/evaera/Cmdr/issues/321#issuecomment-2064428309).

- The maximum command string length has been reduced from 100,000 to 10,000, this will only affect commands that have a server element. If this [breaks you](https://xkcd.com/1172/): why? why on earth?

- The `rotriever.toml` manifest has been removed. [This doesn't impact any published code](https://github.com/search?q=path%3A**%2Frotriever.toml+%22Cmdr%22&type=code) but it might break some private code. ([Let us know](https://github.com/evaera/Cmdr/issues/new?template=BLANK_ISSUE) if you're stuck with Rotriever-aligned tools and can't migrate to Wally, we'll reintroduce the manifest.)

### API

- [`CmdrClient.Gui`](https://eryn.io/Cmdr/api/CmdrClient#Gui) added. This is a property that points to the current Cmdr GUI. Use this when [customizing the interface](https://eryn.io/Cmdr/docs/customizinginterface).

- [`CmdrClient.Toggled`](https://eryn.io/Cmdr/api/CmdrClient#Toggled) added. This is a signal that fires when the Cmdr window is toggled, passing the new `visible` status.

- Command hiding has been added, using the new [`BeforeCommandRegister`](https://eryn.io/Cmdr/docs/hooks#beforecommandregister) hook.

- Cmdr will now warn if it's located outside of a server container. We don't know why, but there have been really obscure bugs we haven't been able to understand and only happen when the Cmdr server library lives in a replicated container. You can ignore the warning if you don't have any issues with your setup.

- Fuzzy finders now have a [matchStart optional parameter](https://github.com/evaera/Cmdr/commit/67fc84b0a770a2dba524e996b794bb713a0cc606) and now [automatically sort](https://github.com/evaera/Cmdr/commit/8491d3416898e982915e174c486d032dd7bb91f3).

- There are now explicit errors when invalid methods or properties are used.

### Builtin commands

- The `runif` builtin command now has [more conditions](https://github.com/evaera/Cmdr/commit/c3c73617dbdfb7d75c8456d7057c214a385e34c5).
- `kick` builtin command now has a reason argument.
- `teleport` builtin command now unseats players.
- `commands` and `cmds` are now aliases for the `help` command.
- `help` command no longer breaks with inline arguments.
- `rand` builtin command now uses `Random:NextInteger` instead of `math.random`.

### Interface and internal

- TextChatService is now supported, including in the `announce` builtin command, `bind` builtin command, and Cmdr window.

- Cmdr now has a [vulnerability reporting policy](https://github.com/evaera/Cmdr/blob/master/SECURITY.md).

- Warning and error console outputs from Cmdr will now start with `[Cmdr]`.

- The window might work a bit better on mobile? Mobile still isn't officially supported, but we're always happy to merge patches that make it a little easier.

- Fixed a bug causing [duplicated outputs on Linux](https://github.com/evaera/Cmdr/issues/365)

- You can now customize the interface to use new FontFaces without breaking Cmdr.

- [Fixed replication bugs causing commands or types to not load on the client.](https://github.com/evaera/Cmdr/commit/8db4824f52bef023474c837fb2667a0b359a69df)

- Command aliases now display correctly with autocomplete.

- 3 keybinds have been added: `ESC` to close the UI, `LCTRL` + `BACKSP` to clear the input line, and `TAB` to recapture input line focus.

## v1.12.0

- Add `convertTimestamp` default command, outputs a human-readable timestamp from epoch seconds
- Add `positiveInteger`, `nonNegativeInteger`, `byte` (0-255), `digit` (0-9) built-in types (including respective plural types)
- Add `json` built-in type, takes in a Json string and provides a Luau table
- Add internal IsServer assertions for `RegisterDefaultCommands` and `commandServerScript`
- Add 'tips' to the help command output
- Make window scroll to bottom on input
- Make fuzzy finders search the entire string, rather than looking at the start
- Make autocomplete menu scrollable
- Fix window not resizing on clear
- Remove global initialization scripts feature

## v1.11.0

- Add support for new Roblox CoreGui Chat
- Add ArgumentOperatorAliases option to types which allows specifying short hands like "me", "others", "all", etc for any type

## v1.10.0

- Improve help command
- Alias command now supports optional arguments
- Legacy RoStrap support has been removed
- Command string text size is now capped at 100K
- Improved error messages when registering commands
- Improved docs
- Improved automatic line sizing
- Fix bug causing var and varSet to yield on require which could make clients fetch server modules too late
- The `run-lines` command now runs on the client

## v1.9.0

- Significantly improved the performance of Util.EmulateTabstops for long strings by using a string builder table (~250-350x) (#190)
  - Allows for long strings to be displayed in the output without a freeze
  - Added column logic to properly align text containing newlines
- Fix a new error caused by `var` & `varSet` in places with DataStore access disabled. (#188)
- Fix incorrect DataStore used by `var` and `varSet` commands.
- Fix incorrect number of arguments passed to `AutoComplete`, `Validate` and `Parse` on using value operators like `**` and `.` (Types).
- Fix `ValidateOnce` not working on types created with `Util.MakeListableType`.
- Fix label positioning broke by roblox update
- Update announce command to check if sender and recipient can chat
- Added RichText option to Window:AddLine
- Replace TeleportPartyAsync with TeleportAsync in teleport command
- Scroll to bottom on typing began

## v1.8.4

- Fix an error when using function arguments.

## v1.8.3

- "% teamPlayers" prefix was accidentally removed from `players` type, so this adds it back.

## v1.8.2

- Fix pressing tab doesn't insert space (#149)

## v1.8.1

- Fixes issue with autocomplete in lists
- Fixes init-run command in unpublished games
- Fix boolean type erroring given the empty string

## v1.8.0

- Add `var` and `var=` default commands, which act as a persistent key-value store.
  - Keys can begin with a dot to be per-session only.
  - Keys can begin with a $ to be game-wide, shared among all players.
  - Keys can begin with $. to be game-wide and per-session.
- Add `fetch` command, which fetches and returns data from the Internet.
- Generalize the `*`, `.`, `?`, and `?N` operators from the player type for all types.
  - Adds a `Default` function to types to determine their "default" value, this maps to `.`
  - `*` is determined by calling the `Autocomplete` function with an empty string
  - `?` is a single random value from the above;
  - `?N` represents a list of N random values;
  - `**` is `*` (all) minus `.` (default), which is commonly referred to as "others" in the `player` type
- Fix client side validation to disallow sending commands with incomplete arguments
- New commands `json-array-encode` and `json-array-decode`
- New command `resolve`, which resolves the argument value operators into lists.
- New commands `len`, `pick`, and `rand`.
- `run` now has an alias: `>`
- `replace` now has an alias: `//`
- `run` command now supports multiple commands delimited by `&&`
  - Slot operator allows you to insert the output of the previous command in a chain of commands separated by `&&`. For example: `> echo evaera && kill ||` (evaera dies)
- New command `edit` allows you to edit text within a text area
- New `join` and `map` commands
- New `goto-place`, `follow-player`, `rejoin`, and `get-player-place-instance` commands.
- New `refresh` command.
- New `uptime` command.
- Cmdr no longer removes preceding skipped arguments (`""`) when using AutoComplete on a later argument (#104)
- `GetCommandsAsStrings` has been renamed to `GetCommandNames`; old name still works for backwards compatibility

## v1.7.1

- Handle non-string error values correctly

## v1.7.0

- Cmdr now calls tostring on error objects emitted from commands (#144)
- Cmdr now includes the full trace back in error messages.
- [Aliases can now include type checking and name information in arguments](https://eryn.io/Cmdr/guide/MetaCommands.html#alias) (#56)
- New default command: "me". Displays the current player's name.
- Make `bring` and `to` commands built-in aliases for `teleport`. `to` has effectively moved from the `DefaultDebug` group to the `DefaultAdmin` group. (#115)
- The default activation key is now <kbd>F2</kbd>

## v1.6.0

- Add random selector for player type (#122)
- Fixed so TextBox is not selectable using controller (#124)
- Fixed AutoExec commands being executed multiple times (#127)
- Added configurable hide on lost focus behavior (#129)
- Added version command (#130)
- Fix Window auto complete cursor positions (#141)
- Add CommandContext:HasImplementation (#138)
- Commands will no longer run in-game if no BeforeRun hook is configured (#132)

## v1.5.0

- Adds AutoComplete IsPartial (#103)
- Added dynamic argument types (#93)
- Allow type inlining in command defs
- Duration type now allows negative values
- Fix a bug where sparse values in value list caused dropped arguments
- Added default command: respawn (#113)

## v1.4.0

- Add support for `ClientRun` (#97).

## v1.3.0

- Add `Prefixes` to Types
- Add `Registry:RegisterTypePrefix`
- Add `Registry:RegisterTypeAlias`
- Add `override` parameter to `Util.MakeListableType`

## v1.2.2

- Make new lines work in command window. (#84)

## v1.2.1

- Fix bug where Data did not get sent correctly (#85)

## v1.2.0

- Added `others` shorthand for players type
- Added APIs for showing and hiding the Cmdr window explicitly
- Added `CmdrClient:SetActivationUnlocksMouse` for freeing mouse upon activation

## v1.1.5

- Empty quoted sequences (`""`) can now be used to skip arguments which have default values

## v1.1.4

- Fix an issue where the `filter` argument of `RegisterDefaultCommands` was nonfunctional.

## v1.1.3

- Fix an issue where the arrow keys could be used to open auto complete when the menu is closed (#62)
- Make AutoExec commands only run on the client (#61)

## v1.1.2

**Command history**

- Up/down arrow now traverses command history when you haven't entered any text.
- New `history` utility command which dynamically returns your previously-entered commands based on a number index.
- New alias `! <number>` to re-run previous commands.
  - `! -1` re-reruns your last command.
  - `! 2` re-runs your second command.
- New alias `!!` to re-run your last command.
- New alias `^ <search> <replace>` to re-run your last command with string substitution, replacing `search` with `replace`.

**New utility commands**

- `history` (see above)
- `position [player]`: Returns the Vector3 position of a player (or yourself if omitted) as a string `X,Y,Z`.
- `replace <haystack> <needle> <replacement>`: Substitutes text inside `haystack` matching Lua pattern `needle` with `replacement`.
- `discard <command string>`: Identical to `run`, except the return value is discarded (always returns `""`).
- `clear`: Clears the console

**New default types**

- Plural primitives (strings, numbers, integers, booleans)
  - _Plural_ types simply resolve into an array of the named type.
- brickColor(s)
- teamColor(s): Resolve into a BrickColor based on the color of a Team
- color3(s)
- hexColor3(s): Resolve into a Color3 from a hexadecimal color
- brickColor3(s): Resolve into a Color3 from a BrickColor
- vector3(s), vector(2)s
- duration(s): Resolve human-readable times like 20Minutes, 2Hours, 1Year into a number of seconds.

**Usage improvements**

- Cmdr now supports escape sequences
  - `\\` for escaping a literal backslash
  - `\"` and `\'` for escaping quotes inside of strings
  - `\t`
    - Tab stops display as expected when `\t` is present in a line on the console
  - `\n`
    - New lines are not displayed in the console as of right now and are displayed as a space. However, `\n` literals may still be useful for custom commands.
  - `\xA9` (2-digit) and `\u2661` (4-digit) hexadecimal unicode escapes
  - `\$` for escaping argument replacements and embedded commands in command strings _only_.
  - Invalid escape sequences are left in-place.
- `help` command now lists command aliases
- `teleport` and `to` now accept a Vector3 with the `@` prefix

**API Improvements and Changes**

- Cmdr now enforces that types begin with a lowercase letter or digit for consistency.
- `Dispatcher:RegisterHooksIn`, `RegisterTypesIn`, and `RegisterCommandsIn` now allow nesting via folders.
- `Dispatcher:AddHook` has been renamed to `Dispatcher:RegisterHook`. The old name still exists as a fallback, but is undocumented and may be removed in the future.
- Cmdr now throws an error if a command has both `Data` and `Run` (not a bug, but if someone is doing this then they are confused)
- Hooks now have an optional third parameter `priority`. Hooks run in order of priority; lower numbers run first. The default priority is `0`.
- CommandContexts now have an empty `State` table. This is intended to be used in combination with the `BeforeRun` hook to allow you to add custom information to this command that you can consume inside of your command logic or other hooks.
  - For example, if you want many commands to have different behavior based on someone's rank, you can add their rank in the `State` table for your commands to consume and branch off of.
- New function `CmdrClient:SetMashToEnable(true)` to enable _Mash to Enable_ mode, which requires the player to press the activation key 7 times in quick succession to open the Cmdr menu for the first time. This is not meant as a security feature, but rather as a way to ensure that the console is not accidentally obtrusive to regular players of your game.
- New client-only function `Dispatcher:GetHistory()` to get an array of the local user's command history. This only includes commands actually typed by the user, no embedded or programmatically run commands.
- `Dispatcher:EvaluateAndRun` now accepts an options table in the third parameter rather than Data.
- Automatic Execution: Commands can now contain an `AutoExec` table which contains commands to execute immediately as the command is registered.
  - This is useful for registering aliases associated with your command or initializing state.
  - Commands listed in AutoExec are deferred until the end of the Lua cycle, which eliminates any possibility of ordering issues caused by commands being registered out of order.

**Utility methods**

- `Util.MakeEnumType` and `Util.MakeFuzzyFinder` now accept `Enum`s and arrays of tables with a `Name` key. (These functions can already accept: array of strings, array of Instances, array of EnumItems, or a single Instance whose children are used).
- New functions `Util.Map` and `Util.Each` for mapping values of an array and tuple respectively.
- New function `Util.MakeSequenceType` for quickly creating a type that contains a value sequence, like Vector3 or Color3. The delimeter can be either `,` or whitespace, checking `,` first.
- New functions `Util.SplitPrioritizedDelimeter`, `Util.ParseEscapeSequences`, and `Util.EmulateTabstops`.

**Bug fixes**

- `announce` command text is now filtered through chat filter
- Added an additional check that RoStrap is being used to help prevent false positives
- Fixed a bug preventing command data from being accessible

**roblox-ts npm package**

Cmdr is now available as an [npm package](https://www.npmjs.com/package/rbx-cmdr) for usage in [roblox-ts](https://roblox-ts.github.io/).
