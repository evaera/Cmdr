# Security

Cmdr is designed with security as a top priority. It provides strict server-side argument validation, explicit permission hooks, and clear separation between client-side UI display and server-authoritative execution.

---

## Can exploiters run my commands?

**Not unless you explicitly permit them to.**

Exploiters have complete control over their local client environment and can fire remote signals directly to the server to attempt to invoke commands with forged arguments. However, Cmdr protects your game through several security layers:

- **Dual-side type validation:** Cmdr validates argument types on both the client and the server. Even if an exploiter bypasses client-side checks or fires raw network requests, the server re-validates all arguments before any command code is run.
- **Mandatory server authorization:** Non-default commands are automatically blocked from running in live games unless you register at least one `BeforeRun` hook on the server.
- **Server-authoritative execution:** Command logic executes strictly on the server. Returning an error string from a server `BeforeRun` hook halts command execution immediately, preventing any code from touching server state.

---

## How permission hooks work

Cmdr uses `BeforeRun` hooks to evaluate whether a user is allowed to execute a command.

Because exploiters can manipulate or bypass client code, permissions must **always** be checked on the server:

- **Client `BeforeRun` hooks:** Provide immediate user feedback in the local console UI without making an unnecessary network request.
- **Server `BeforeRun` hooks:** Serve as the actual security boundary. If a server hook returns an error string, execution stops completely.

```lua title="Server authorization hook"
return function(registry: any)
	registry:RegisterHook("BeforeRun", function(context: any): string?
		-- Restrict admin commands to the place creator
		if context.Group == "Admin" and context.Executor.UserId ~= game.CreatorId then
			return "You do not have permission to run this command."
		end
	end)
end
```

---

## Command replication and `BeforeCommandRegister`

Understanding how Cmdr handles command definition files is essential for maintaining secure games:

### Definitions replicate to the client

When command definition modules are stored in a folder accessible to the client (such as `ReplicatedStorage`), Roblox replicates those assets to all connected players. Exploiters can read client-replicated scripts, command names, argument signatures, and client-side code.

### What `BeforeCommandRegister` does (and does not do)

The `BeforeCommandRegister` hook runs on the **client** to filter which commands are loaded into the local UI menu.

- **What it does:** Hides sensitive commands from console autocomplete, search listings, and local command execution for specific players.
- **What it does NOT do:** It does **not** stop definition files from replicating to the client, nor does it secure server endpoints. An exploiter can still inspect client memory to read command names and attempt to invoke them over the network.

> **Key takeaway:** `BeforeCommandRegister` is purely a visual and UX filter to keep console menus clean. Never rely on hidden command names or client-side filtering as a security mechanism. Always authorize commands on the server using a `BeforeRun` hook.

---

## Noteworthy internals

For security-focused developers, a few aspects of Cmdr's architecture are worth highlighting:

### Server implementation isolation

Cmdr splits command definitions from command implementations. Definition modules (which specify command names and argument types) are placed in client-accessible folders. Implementation scripts (`*Server.lua`), however, remain strictly in server storage (such as `ServerScriptService`). Cmdr never delivers the server implementation to the client.

### Payload parsing and type coercion

When a client sends a command request to the server, Cmdr does not blindly evaluate string input on the server. The server re-parses raw input through your registered argument types and constructs a clean [`CommandContext`](/api/CommandContext). If an argument fails type validation or parsing on the server, execution fails before hitting your command logic.

### Client-side execution isolation

Commands with a `ClientRun` function or local utilities execute exclusively on the client that invoked them. Even if an exploiter modifies client-side utilities or local command scripts, those changes only affect their local client environment and cannot corrupt state on the server or for other players.

---

## Best practices for a secure setup

1. **Always enforce permissions on the server:** Ensure every admin or elevated command is guarded by a server-side `BeforeRun` hook.
2. **Keep server logic out of client scripts:** Place server-side logic strictly inside server scripts (`ServerScriptService`). Use `ClientRun` only for local UI manipulation or client-side feedback.
3. **Assume replicated assets are public:** Treat all command definitions, argument types, and client-side hooks as public information readable by any client.
