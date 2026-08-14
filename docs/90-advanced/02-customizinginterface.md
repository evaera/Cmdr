# Customizing the interface

:::warning Updating

If an update is released that changes the structure of the Cmdr interface, your UI customizations may break.

We recommend against disabling auto-update features (such as pinning your version in Wally), but customizing the interface means you must be vigilant of new releases and verify your changes when updating.

:::

When required on the client, Cmdr dynamically generates its console interface (called the Window) and inserts it directly into the local player's `PlayerGui`. It is never cloned into or parented to `StarterGui`.

## Accessing the GUI via API

The intended and supported way to customize the Cmdr console layout, theme, or behavior is by accessing the interface directly through the client-side API. Once you have initialized the client, you can reference the `Cmdr.Gui` property.

```luau title="StarterPlayer/StarterPlayerScripts/CmdrClientSetup.luau"
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

-- Access the generated ScreenGui directly from the API
const consoleGui = Cmdr.Gui

-- Access the main text-display console window frame
const mainConsoleFrame = consoleGui:WaitForChild("Frame")
mainConsoleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainConsoleFrame.BackgroundTransparency = 0.2

-- Access the autocomplete utility window frame
const autocompleteMenu = consoleGui:WaitForChild("Autocomplete")
autocompleteMenu.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
```

Because `Cmdr.Gui` gives you a direct reference to the active `ScreenGui` instance, you can safely write visual styling extensions, apply custom UI themes, or listen to UI state changes immediately after activation without worrying about character spawn timing or race conditions.

## Replacing the Cmdr interface

If a `Cmdr` instance exists in `StarterGui`, CmdrClient will always wait for it to be inserted into the `PlayerGui`.

This allows advanced uses to entirely replace the Cmdr interface, but we don't recommend this.
