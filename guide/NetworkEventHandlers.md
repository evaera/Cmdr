---
title: Network Event Handlers
---

# Network Event Handlers

Some commands that run on the server might need to also do something on the client, or on every client. Network event handlers are callback functions that you can set to run when a server command sends a message back to the client. Only one handler can be set to a certain event at a time, so it's possible to change the handler for a specific event without needing to re-implement the entire command yourself.

For example, consider the default `announce` command, which creates a message on every player's screen. By default, this creates a system chat message with the given text, because Cmdr has a default event handler for the `"Message"` event, which the `announce` command broadcasts,

If you wanted to display announcements some other way, you could just override the default event handler:

```lua
CmdrClient:HandleEvent("Message", function (text, player)
	print("Announcement from", player.Name, text)
end)
```

You can send events from your own commands on the server (or to the local player if in a client-only command) by using `context:SendEvent(player, ...)` and `context:BroadcastEvent(...)`. The built-in `context:Reply(text)` method actually uses `SendEvent` under the hood, whose default handler on the client is set to just add a new line to the console window with the given text.