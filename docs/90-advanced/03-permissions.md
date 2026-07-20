# Permissions

Because Cmdr is an open-facing console, implementing a secure permission system is critical. This is achieved using `BeforeRun` **hooks**.

:::warning Security Warning

Commands will be completely blocked from running in a live game unless you register at least one `BeforeRun` hook.

:::

## The golden rule: client vs. server

When writing permissions, keep this rule in mind: **Never trust the client.**

Registering hooks using `Cmdr.Registry:RegisterHooksIn()` clones your code to both the client and the server. This is convenient for basic validation and providing immediate feedback. However, an exploiter can always bypass or manipulate client-side hooks.

- **Client Commands:** If a command runs purely on the client via `ClientRun`, an exploiter could run it anyway. This is fine for visual or local utilities (like performance toggles), as exploiters can already modify their own client.
- **Server Commands:** Any command that alters the game state, manages data, or affects other players **must** be enforced by a hook running securely on the server.

---

## Simple group-based permissions

The safest architectural pattern for permissions is to **deny all groups by default** and selectively allowlist specific ones.

When you define a command, you can give it a custom `Group` string (e.g., `"Admin"` or `"Moderator"`). Your hook can read `context.Group` to determine what authorization level is required. Non-sensitive built-in command groups like `DefaultUtil` should be allowlisted for everyone, along with `UserAlias` (which handles internal user-created command shortcuts).

```lua title="hooks/Permissions.luau"
local GroupService = game:GetService("GroupService")

local ALLOWED_USER_IDS = {
	123456, -- Replace with actual UserIds
}

-- Groups that anyone is allowed to run (utilities, help commands, aliases)
local PUBLIC_GROUPS = {
	"DefaultUtil",
	"UserAlias",
}

local MIN_RANK_REQUIRED = 250 -- e.g., Admin rank in your Roblox group
local GROUP_ID = 0000000 -- Replace with your Roblox GroupId

return function(registry)
	registry:RegisterHook("BeforeRun", function(context)
		local player = context.Executor

		-- Always allow non-sensitive, structural, or utility groups
		if table.find(PUBLIC_GROUPS, context.Group) then
			return nil
		end

		-- Always allow the game creator or explicitly allowlisted IDs
		if player.UserId == game.CreatorId or table.find(ALLOWED_USER_IDS, player.UserId) then
			return nil
		end

		-- Restrict administrative command groups via GroupService checks
		if context.Group == "Admin" or context.Group == "DefaultAdmin" then
			local success, result = pcall(GroupService.GetRolesInGroupAsync, GroupService, player.UserId, GROUP_ID)

			if not success or not result.IsMember then
				return "You do not have permission to run administrative commands."
			end

			-- Check if any assigned roles meet or exceed the required minimum rank
			local authorized = false
			for _, role in ipairs(result.Roles) do
				if role.Rank >= MIN_RANK_REQUIRED then
					authorized = true
					break
				end
			end

			if not authorized then
				return "You do not have permission to run administrative commands."
			end

			return nil
		end

		-- Catch-all deny for safety
		return "This command group is restricted."
	end)
end
```

---

## Using persistent server stores for mod/ban bystems

If your command needs to dynamically change a player's permission status mid-game (like a session-based `ban` or `tempmod` command), you can use Cmdr's built-in memory storage via `registry:GetStore()`.

:::info

Cmdr stores are **in-memory tables unique to the current server instance**. They are not automatically synchronized between the server and the client, nor do they persist across multiple game sessions via Roblox's `DataStoreService`.

:::

Because the client and server do not share memory space, registering a hook that reads a shared store via `RegisterHooksIn` will fail on the client. Instead, keep this hook strictly on the server by registering it directly in your server startup script rather than a shared folder.

```lua title="ServerScriptService/CmdrSetup.luau"
local Cmdr = require(path.to.Cmdr)

-- Retrieve or initialize a unique in-memory list for this server instance
local banStore = Cmdr.Registry:GetStore("BannedPlayers")

Cmdr.Registry:RegisterHook("BeforeRun", function(context)
	local player = context.Executor

	-- Prevent session-banned players from executing anything on the server
	if table.find(banStore, player.UserId) then
		return "You have been restricted from using Cmdr in this server instance."
	end
end)
```

Any server-side command can then modify this in-memory list directly:

```lua title="commands/BanServer.luau"
return function(context, targetPlayer)
	local banStore = context:GetStore("BannedPlayers")

	-- Only append to the list if they aren't already tracked
	if not table.find(banStore, targetPlayer.UserId) then
		table.insert(banStore, targetPlayer.UserId)
	end

	return `Player {targetPlayer.Name} has been barred from using console commands for the remainder of this session.`
end
```

---

## Gathering sensitive context via client data

Sometimes, verifying a permission requires information that only the client knows, such as what they are looking at or clicking on. However, because an exploiter can spoof client data, you must cross-verify the returned data on the server.

For example, imagine a `moderatorClick` command that targets whatever player the moderator is currently hovering their mouse over.

First, the command definition uses `Data` to grab the target client-side:

```lua title="commands/ModeratorClick.luau"
local Players = game:GetService("Players")

return {
	Name = "moderatorclick",
	Aliases = { "modclick" },
	Description = "Performs an action on the player under your cursor.",
	Group = "Admin",
	Args = {},
	Data = function()
		-- Runs on the client
		local mouse = Players.LocalPlayer:GetMouse()
		local target = mouse.Target

		if target and target.Parent:FindFirstChild("Humanoid") then
			local targetPlayer = Players:GetPlayerFromCharacter(target.Parent)
			if targetPlayer then
				return targetPlayer.UserId
			end
		end
		return nil
	end,
}
```

Next, your server hook ensures that the executor is actually allowed to send data from this command, preventing standard users from mimicking the network call:

```lua title="hooks/VerifyClickData.luau"
local GroupService = game:GetService("GroupService")

local MIN_RANK_REQUIRED = 250
local GROUP_ID = 123456

return function(registry)
	registry:RegisterHook("BeforeRun", function(context)
		-- Explicitly block non-admins from passing payload data through this command
		if context.Name == "moderatorclick" and context.Group == "Admin" then
			local player = context.Executor

			local success, result = pcall(GroupService.GetRolesInGroupAsync, GroupService, player.UserId, GROUP_ID)
			if not success or not result.IsMember then
				return "Bypassing data parameters is prohibited."
			end

			local authorized = false
			for _, role in ipairs(result.Roles) do
				if role.Rank >= MIN_RANK_REQUIRED then
					authorized = true
					break
				end
			end

			if not authorized then
				return "Bypassing data parameters is prohibited."
			end

			-- Retrieve the safe payload gathered from the client
			local targetUserId = context:GetData()
			if not targetUserId then
				return "No valid target selected."
			end
		end
	end)
end
```
