# Set-up

Once you've installed Cmdr, you'll need to set it up **on both the server and client** to get running. Your setup code could exist within your existing codebase (for instance, if you use a framework) or it could be done with simple scripts.

:::info Heads up

There are plenty of resources available to help you with Cmdr, such as this website and our Discord server, but we've been made aware of a number of DevForum guides and YouTube videos which provide incorrect or outdated instructions.

**We recommend you stick to our official resources, especially if you're new to Cmdr.** If you decide to use unofficial resources, then the level of support we can provide (for instance in our Discord server) is limited.

:::

## Modifying the source code

:::warning Do not modify the source code

Please **do not** modify the source code of Cmdr for your game. Instead, use its API to customise the behaviour you want. Modifying the source code makes it much harder for you to receive future updates.

There shouldn't be any reason why you need to modify the source code of Cmdr (unless you're [adding a new feature or fixing a bug](/docs/contribute)). If there's something you think we're missing, please [open an issue](https://github.com/evaera/cmdr/issues).

:::

Modifying the source code also includes putting your commands within Cmdr's `BuiltInCommands` folder; don't do it. You should never touch the `Cmdr` library or any of its components outside of code.

## Server setup

You should create a folder to keep your commands inside and then register them on the server. You only need to register commands, types and hooks on the server: Cmdr will automatically handle replication for you. There is no need to modify the actual Cmdr library itself.

```lua
-- This is a script you would create in ServerScriptService, for example
local ServerScriptService = game:GetService("ServerScriptService")
local Cmdr = require(path.to.Cmdr) -- e.g. ServerScriptService.Packages.Cmdr

Cmdr.Registry:RegisterDefaultCommands() -- Optional: This loads the default set of commands that Cmdr comes with.
-- Cmdr.Registry:RegisterCommandsIn(ServerScriptService.CmdrCommands) -- Optional: Register commands from your own folder.
-- You can also register types or hooks here: read on or check the API reference!
```

The [`Cmdr` object](/api/Cmdr) is the main server singleton. The [Registry](/api/Registry) is used on both the client and server, and it keeps track of all the commands, types and hooks that Cmdr knows about.

Cmdr will automatically create and insert into StarterGui its console interface (called Window). If you'd like to (optionally) customise the look of the Window, we have [a guide on this in our Advanced section](/docs/advanced/customisinginterface).

Cmdr will also insert into `ReplicatedStorage` the [`CmdrClient`](/api/CmdrClient) module. On top of being the client entry point (read on below!), this module also houses stuff for internal use, like replication (any commands, types and hooks the client needs to know about) and networking.

:::note You're not done yet!

Client setup is also required, you need to register Cmdr on the server _and_ client for it to load. Keep going! ↓

:::

## Client setup

From the client, you'll need to require the CmdrClient module.

Cmdr will place CmdrClient into ReplicatedStorage automatically, no action is required from you. This module includes things used by Cmdr internally, but also provides you - the developer - with [methods to customise and tweak Cmdr](/api/CmdrClient).

```lua
-- This is a local/client script you would create in StarterPlayerScripts, for example
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

-- Optional. Configurable, and you can choose multiple keys
Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })

-- You can call any extra methods here, like SetPlaceName, or access the registry to register a hook on the client only (if you want to!)
```

Activation keys are used to show or hide Cmdr. By default, this is just `F2` but you can have as many or as few keys as you'd like (even none).

## Next steps

By now, Cmdr is up and running, and will work fine in studio. However, you'll probably want to [write your own commands](/docs/commands) and to run any commands in a live server, you **must** [create a BeforeRun hook](/docs/hooks).

If you ever need help, you can check [the support page](/docs/intro#how-do-i-get-help-with-cmdr).
