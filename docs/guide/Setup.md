# Set-up

### Installation
#### Method 1 - Recommended

The easiest way to get started with Cmdr is to install the [RoStrap Roblox Studio plugin](https://www.roblox.com/library/725884332/RoStrap), open the RoStrap interface in a place, and then install "Cmdr". This will instantly download and build the newest version of Cmdr right from GitHub.

![Installation](https://user-images.githubusercontent.com/2489210/45920094-b27c3f80-be6d-11e8-9105-f358140b5a13.png)

#### Method 2 - Manual

You can download the latest model file release from the [releases section](https://github.com/evaera/Cmdr/releases/latest), but this may not always be the most up to date version of Cmdr. You'll want to put this is a server directory, like ServerScriptService.

#### Method 3 - Advanced

Cmdr has no dependencies, so it can also be easily included as a Git submodule and synced in with the rest of your project with [Rojo](https://github.com/LPGhatguy/rojo). If you don't know how to do this already, then please see method 1 :)

### Server
You should create a folder to keep your commands inside, and then register them on the server. You need to require Cmdr on the server *and* on the client for it to be fully loaded. However, you only need to register commands and types on the server. There should be no need to modify the actual Cmdr library itself.

```lua
-- This is a script you would create in ServerScriptService, for example.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources")) -- With RoStrap
local Cmdr = Resources:LoadLibrary("Cmdr") -- or if not using RoStrap: require(path.to.Cmdr)

Cmdr:RegisterDefaultCommands() -- This loads the default set of commands that Cmdr comes with. (Optional)
-- Cmdr:RegisterCommandsIn(script.Parent.CmdrCommands) -- Register commands from your own folder. (Optional)
-- See below for the full API.
```

The Cmdr GUI will be inserted into StarterGui if it doesn't already exist. You can customize the GUI to your liking (changing colors, etc.) if you play the game, copy the GUI, stop the game, and then paste it in to StarterGui. Of course, this is completely optional.

### Client

From the client, you also need to require the CmdrClient module.

If not using RoStrap, then after the server code above runs, CmdrClient will be inserted into ReplicatedStorage automatically.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources")) -- With RoStrap
local Cmdr = Resources:LoadLibrary("CmdrClient") -- Without RoStrap: require(ReplicatedStorage:WaitForChild("CmdrClient"))

-- Configurable, and you can choose multiple keys
Cmdr:SetActivationKeys({ Enum.KeyCode.Semicolon })
-- See below for the full API.
```