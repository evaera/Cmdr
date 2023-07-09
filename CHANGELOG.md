# v1.12.0

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

# v1.11.0

- Add support for new Roblox CoreGui Chat
- Add ArgumentOperatorAliases option to types which allows specifying short hands like "me", "others", "all", etc for any type

# v1.10.0
- Improve help command
- Alias command now supports optional arguments
- Legacy RoStrap support has been removed
- Command string text size is now capped at 100K
- Improved error messages when registering commands
- Improved docs
- Improved automatic line sizing
- Fix bug causing var and varSet to yield on require which could make clients fetch server modules too late
- The `run-lines` command now runs on the client

# v1.9.0
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

# v1.8.4
- Fix an error when using function arguments.

# v1.8.3
- "% teamPlayers" prefix was accidentally removed from `players` type, so this adds it back.

# v1.8.2
- Fix pressing tab doesn't insert space (#149)

# v1.8.1
- Fixes issue with autocomplete in lists
- Fixes init-run command in unpublished games
- Fix boolean type erroring given the empty string

# v1.8.0
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

# v1.7.1
- Handle non-string error values correctly

# v1.7.0
- Cmdr now calls tostring on error objects emitted from commands (#144)
- Cmdr now includes the full trace back in error messages.
- [Aliases can now include type checking and name information in arguments](https://eryn.io/Cmdr/guide/MetaCommands.html#alias) (#56)
- New default command: "me". Displays the current player's name.
- Make `bring` and `to` commands built-in aliases for `teleport`. `to` has effectively moved from the `DefaultDebug` group to the `DefaultAdmin` group. (#115)
- The default activation key is now <kbd>F2</kbd>

# v1.6.0

- Add random selector for player type (#122)
- Fixed so TextBox is not selectable using controller (#124)
- Fixed AutoExec commands being executed multiple times (#127)
- Added configurable hide on lost focus behavior (#129)
- Added version command (#130)
- Fix Window auto complete cursor positions (#141)
- Add CommandContext:HasImplementation (#138)
- Commands will no longer run in-game if no BeforeRun hook is configured (#132)

# v1.5.0

- Adds AutoComplete IsPartial (#103)
- Added dynamic argument types (#93)
- Allow type inlining in command defs
- Duration type now allows negative values
- Fix a bug where sparse values in value list caused dropped arguments
- Added default command: respawn (#113)

# v1.4.0

- Add support for `ClientRun` (#97).

# v1.3.0

- Add `Prefixes` to Types
- Add `Registry:RegisterTypePrefix`
- Add `Registry:RegisterTypeAlias`
- Add `override` parameter to `Util.MakeListableType`

# v1.2.2

- Make new lines work in command window. (#84)

# v1.2.1

- Fix bug where Data did not get sent correctly (#85)

# v1.2.0

- Added `others` shorthand for players type
- Added APIs for showing and hiding the Cmdr window explicitly
- Added `CmdrClient:SetActivationUnlocksMouse` for freeing mouse upon activation

# v1.1.5
- Empty quoted sequences (`""`) can now be used to skip arguments which have default values

# v1.1.4
- Fix an issue where the `filter` argument of `RegisterDefaultCommands` was nonfunctional.

# v1.1.3
- Fix an issue where the arrow keys could be used to open auto complete when the menu is closed (#62)
- Make AutoExec commands only run on the client (#61)

# v1.1.2
## Command history
  - Up/down arrow now traverses command history when you haven't entered any text.
  - New `history` utility command which dynamically returns your previously-entered commands based on a number index.
  - New alias `! <number>` to re-run previous commands.
    - `! -1` re-reruns your last command.
    - `! 2` re-runs your second command.
  - New alias `!!` to re-run your last command.
  - New alias `^ <search> <replace>` to re-run your last command with string substitution, replacing `search` with `replace`.

## New utility commands
  - `history` (see above)
  - `position [player]`: Returns the Vector3 position of a player (or yourself if omitted) as a string `X,Y,Z`.
  - `replace <haystack> <needle> <replacement>`: Substitutes text inside `haystack` matching Lua pattern `needle` with `replacement`.
  - `discard <command string>`: Identical to `run`, except the return value is discarded (always returns `""`).
  - `clear`: Clears the console

## New default types
  - Plural primitives (strings, numbers, integers, booleans)
    - *Plural* types simply resolve into an array of the named type.
  - brickColor(s)
  - teamColor(s): Resolve into a BrickColor based on the color of a Team
  - color3(s)
  - hexColor3(s): Resolve into a Color3 from a hexadecimal color
  - brickColor3(s): Resolve  into a Color3 from a BrickColor
  - vector3(s), vector(2)s
  - duration(s): Resolve human-readable times like 20Minutes, 2Hours, 1Year into a number of seconds.

## Usage improvements
- Cmdr now supports escape sequences
  - `\\` for escaping a literal backslash
  - `\"` and `\'` for escaping quotes inside of strings
  - `\t`
    - Tab stops display as expected when `\t` is present in a line on the console
  - `\n`
    - New lines are not displayed in the console as of right now and are displayed as a space. However, `\n` literals may still be useful for custom commands.
  - `\xA9` (2-digit) and `\u2661` (4-digit) hexadecimal unicode escapes
  - `\$` for escaping argument replacements and embedded commands in command strings *only*.
  - Invalid escape sequences are left in-place.
- `help` command now lists command aliases
- `teleport` and `to` now accept a Vector3 with the `@` prefix

## API Improvements and Changes
- Cmdr now enforces that types begin with a lowercase letter or digit for consistency.
- `Dispatcher:RegisterHooksIn`, `RegisterTypesIn`, and `RegisterCommandsIn` now allow nesting via folders.
- `Dispatcher:AddHook` has been renamed to `Dispatcher:RegisterHook`. The old name still exists as a fallback, but is undocumented and may be removed in the future.
- Cmdr now throws an error if a command has both `Data` and `Run` (not a bug, but if someone is doing this then they are confused)
- Hooks now have an optional third parameter `priority`. Hooks run in order of priority; lower numbers run first. The default priority is `0`.
- CommandContexts now have an empty `State` table. This is intended to be used in combination with the `BeforeRun` hook to allow you to add custom information to this command that you can consume inside of your command logic or other hooks.
  - For example, if you want many commands to have different behavior based on someone's rank, you can add their rank in the `State` table for your commands to consume and branch off of.
- New function `CmdrClient:SetMashToEnable(true)` to enable *Mash to Enable* mode, which requires the player to press the activation key 7 times in quick succession to open the Cmdr menu for the first time. This is not meant as a security feature, but rather as a way to ensure that the console is not accidentally obtrusive to regular players of your game.
- New client-only function `Dispatcher:GetHistory()` to get an array of the local user's command history. This only includes commands actually typed by the user, no embedded or programmatically run commands.
- `Dispatcher:EvaluateAndRun` now accepts an options table in the third parameter rather than Data.
- Automatic Execution: Commands can now contain an `AutoExec` table which contains commands to execute immediately as the command is registered.
  - This is useful for registering aliases associated with your command or initializing state.
  - Commands listed in AutoExec are deferred until the end of the Lua cycle, which eliminates any possibility of ordering issues caused by commands being registered out of order.

## Utility methods
- `Util.MakeEnumType` and `Util.MakeFuzzyFinder` now accept `Enum`s and arrays of tables with a `Name` key. (These functions can already accept: array of strings, array of Instances, array of EnumItems, or a single Instance whose children are used).
- New functions `Util.Map` and `Util.Each` for mapping values of an array and tuple respectively.
- New function `Util.MakeSequenceType` for quickly creating a type that contains a value sequence, like Vector3 or Color3. The delimeter can be either `,` or whitespace, checking `,` first.
- New functions `Util.SplitPrioritizedDelimeter`, `Util.ParseEscapeSequences`, and `Util.EmulateTabstops`.

## Bug fixes
- `announce` command text is now filtered through chat filter
- Added an additional check that RoStrap is being used to help prevent false positives
- Fixed a bug preventing command data from being accessible

## roblox-ts npm package
Cmdr is now available as an [npm package](https://www.npmjs.com/package/rbx-cmdr) for usage in [roblox-ts](https://roblox-ts.github.io/).
