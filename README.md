# Cmdr

**Cmdr** is a fully extensible command console for Roblox developers.

<p align="center">
  <img src="https://giant.gfycat.com/ChillyAjarGoldfish.gif" alt="Cmdr Demo" />
</p>

Cmdr is designed specifically so that you can write your own commands and argument types, so that it can fit right in with the rest of your game. In addition to the standard moderation commands (teleport, kill, kick, ban), Cmdr is also great for debug commands in your game (say, if you wanted to have a command to give you a weapon, reset a round, teleport you between places in your universe).

Cmdr provides a friendly API that lets the game developer choose if they want to register the default admin commands, register their own commands, choose a different key bind for activating the console, and disabling Cmdr altogether.

Cmdr has a robust and friendly type validation system (making sure strings are strings, players are players, etc), which can give end users realtime command validation as they type, and automatic error messages. By the time the command actually gets to your code, you can be assured that all of the arguments are present and of the correct type.

## Set-up

### Server
You should create a folder to keep your commands inside, and then register them on the server. You need to require Cmdr on the server *and* on the client for it to be fully loaded.

```lua
-- This is a script you would create in ServerScriptService, for example.
local Cmdr = require(path.to.Cmdr)
Cmdr:RegisterCommandsIn(script.Parent.CmdrCommands) -- Your folder
-- See below for the full API.
```

### Client

From the client, you also need to require the CmdrClient module. After the server code above runs, it'll be inserted into ReplicatedStorage automatically.

To prepare the GUI, download the Cmdr.rbxm model file and insert it into your game under StarterGui.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient")

-- Configurable, and you can choose multiple keys
Cmdr:SetActivationKeys({ Enum.KeyCode.Semicolon })
-- See below for the full API.
```

## Commands

Commands are defined in ModuleScripts that return a single table.

```lua
-- Teleport.lua, inside your commands folder as defined above.
return {
	Name = "teleport";
	Aliases = {"tp"};
	Description = "Teleports a player or set of players to one target.";
	Group = "Admin";
	Args = {
		{
			Type = "players";
			Name = "from";
			Description = "The players to teleport";
		},
		{
			Type = "player";
			Name = "to";
			Description = "The player to teleport to"
		}
	};
}
```

The implementation should be in a separate file, which is never delivered to the client. This module should only return one function. The module must be named the same thing as the definition module as described above, with the word "Server" appended to the end.

```lua
-- TeleportServer.lua

-- These arguments are guaranteed to exist and be correctly typed.
return function (context, fromPlayers, toPlayer)
  if toPlayer.Character and toPlayer:FindFirstChild("HumanoidRootPart") then
    local position = toPlayer.Character.HumanoidRootPart.CFrame

    for _, player in ipairs(fromPlayers) do
      if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = position
      end
    end

    return "Teleported players."
  end

  return "Target player has no character."
end
```

Alternatively, you can make a command run entirely on the client, by adding a `Run` function directly to the first module instead of having it be in a -`Server` script on its own.

## API

# Todo
- Write documentation
- Add more methods to command context
