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