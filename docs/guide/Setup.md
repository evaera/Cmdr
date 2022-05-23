---
title: Setup
---
# Set-up

### Installation
Pick one of the below methods to install Cmdr:

<!-- #### Recommended

The easiest way to get started with Cmdr is to install the [RoStrap Roblox Studio plugin](https://www.roblox.com/library/725884332/RoStrap), open the RoStrap interface in a place, and then install "Cmdr". This will instantly download and build the newest version of Cmdr right from GitHub.

![Installation](https://user-images.githubusercontent.com/2489210/45920094-b27c3f80-be6d-11e8-9105-f358140b5a13.png) -->

#### Manual

You can download the latest model file release from the [releases section](https://github.com/evaera/Cmdr/releases/latest), but this may not always be the most up to date version of Cmdr. You'll want to put this in a server directory, like ServerScriptService.

#### Advanced

Cmdr has no dependencies, so it can also be easily included as a Git submodule and synced in with the rest of your project with [Rojo](https://github.com/LPGhatguy/rojo). If you don't know how to do this already, then please see method 1 :)

### Warning

::: warning DO NOT MODIFY SOURCE CODE TO CHANGE BEHAVIOR
Please **do not** modify the source code of Cmdr for your game. Instead, use its API to customize the behavior you want. Modifying the source code makes it much harder for you to receive feature updates.

There should be **no reason** to modify the source code of Cmdr (unless you are adding a brand new feature or fixing a bug).
:::

### Server setup (required)

You should create a folder to keep your commands inside, and then register them on the server. However, you only need to register commands and types on the server. There should be no need to modify the actual Cmdr library itself.

:::: tabs
<!-- ::: tab "Using RoStrap"
```lua
-- This is a script you would create in ServerScriptService, for example.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local Cmdr = Resources:LoadLibrary("Cmdr")

Cmdr:RegisterDefaultCommands() -- This loads the default set of commands that Cmdr comes with. (Optional)
-- Cmdr:RegisterCommandsIn(script.Parent.CmdrCommands) -- Register commands from your own folder. (Optional)
```
::: -->
::: tab ""
```lua
-- This is a script you would create in ServerScriptService, for example.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = require(path.to.Cmdr)

Cmdr:RegisterDefaultCommands() -- This loads the default set of commands that Cmdr comes with. (Optional)
-- Cmdr:RegisterCommandsIn(script.Parent.CmdrCommands) -- Register commands from your own folder. (Optional)
```
:::
::::

The Cmdr GUI will be inserted into StarterGui if it doesn't already exist. You can customize the GUI to your liking (changing colors, etc.) if you play the game, copy the GUI, stop the game, and then paste it in to StarterGui. Of course, this is completely optional.

::: warning CLIENT SETUP ALSO REQUIRED
You need to require Cmdr on the server *and* on the client for it to be fully loaded. Keep going! ↓
:::

### Client setup (required)

From the client, you also need to require the CmdrClient module.

<!--If not using RoStrap, then--> After the server code above runs, CmdrClient will be inserted into ReplicatedStorage automatically.

:::: tabs
<!-- ::: tab "Using RoStrap"
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local Cmdr = Resources:LoadLibrary("CmdrClient")

-- Configurable, and you can choose multiple keys
Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })
-- See below for the full API.
```
::: -->
::: tab ""
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

-- Configurable, and you can choose multiple keys
Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })
-- See below for the full API.
```
:::
::::

<script>
  export default {
    mounted () {
      this.$nextTick(() => {
        document.querySelectorAll(".tabs-component-tab a").forEach(el => {
          el.addEventListener("click", e => {
            e.preventDefault()
            history.pushState(null, null, el.href)
          })
        })
      })
    }
  }
</script>
