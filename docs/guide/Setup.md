---
title: Setup
---
# Set-up

### Installation
Pick one of the below methods to install Cmdr:

#### Manual

You can download the latest model file release from the [releases section](https://github.com/evaera/Cmdr/releases/latest), but this may not always be the most up to date version of Cmdr. You'll want to put this in a server directory, like ServerScriptService.

#### Advanced

Cmdr has no dependencies, so it can also be easily included as a Git submodule and synced in with the rest of your project with [Rojo](https://github.com/LPGhatguy/rojo). If you don't know how to do this already, then please see method 1 :)

#### via Wally

Cmdr is also available on Wally [here](https://wally.run/package/evaera/cmdr). You can install it by adding the following to your project's `wally.toml`. See Wally's [Manifest Format](https://github.com/UpliftGames/wally#manifest-format) for more info.
```toml
[server-dependencies]
Cmdr = "evaera/cmdr@1.9.0"
```

### Warning

::: warning DO NOT MODIFY SOURCE CODE TO CHANGE BEHAVIOR
Please **do not** modify the source code of Cmdr for your game. Instead, use its API to customize the behavior you want. Modifying the source code makes it much harder for you to receive feature updates.

There should be **no reason** to modify the source code of Cmdr (unless you are adding a brand new feature or fixing a bug).
:::

### Server setup (required)

You should create a folder to keep your commands inside, and then register them on the server. However, you only need to register commands and types on the server. There should be no need to modify the actual Cmdr library itself.

```lua
-- This is a script you would create in ServerScriptService, for example.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = require(path.to.Cmdr)

Cmdr:RegisterDefaultCommands() -- This loads the default set of commands that Cmdr comes with. (Optional)
-- Cmdr:RegisterCommandsIn(script.Parent.CmdrCommands) -- Register commands from your own folder. (Optional)
```

The Cmdr GUI will be inserted into StarterGui if it doesn't already exist. You can customize the GUI to your liking (changing colors, etc.) if you play the game, copy the GUI, stop the game, and then paste it in to StarterGui. Of course, this is completely optional.

::: warning CLIENT SETUP ALSO REQUIRED
You need to require Cmdr on the server *and* on the client for it to be fully loaded. Keep going! ↓
:::

### Client setup (required)

From the client, you also need to require the CmdrClient module.

After the server code above runs, CmdrClient will be inserted into ReplicatedStorage automatically.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

-- Configurable, and you can choose multiple keys
Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })
-- See below for the full API.
```

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
