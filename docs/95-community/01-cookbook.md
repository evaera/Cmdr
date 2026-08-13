# Cookbook

Welcome to the Cmdr cookbook! Here you will find practical recipes and code patterns for implementing common administrative workflows, custom user interfaces, and advanced network routines.

---

## Sending custom client notifications with network events

Cmdr allows commands running on the server to dispatch messages to specific clients or broadcast them to every client using `context:SendEvent` and `context:BroadcastEvent`.

This recipe demonstrates how to create a `notify` command that safely filters text input and sends a titled pop-up notification with custom durations to targeted players.

:::warning Text Filtering Requirements

Roblox requires all user-generated text displayed to other players to be filtered on the server. Failure to filter user input can lead to moderation action.

:::

### Command definition (`notify.luau`)

Define the command structure, requiring target players, a title, a body message, and an optional duration.

```luau
return {
	Name = "notify",
	Aliases = { "toast" },
	Description = "Sends a client-side screen notification to targeted players.",
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Targets",
			Description = "The player(s) who will receive the notification",
		},
		{
			Type = "string",
			Name = "Title",
			Description = "The header title of the notification",
		},
		{
			Type = "string",
			Name = "Message",
			Description = "The main body text of the notification",
		},
		{
			Type = "duration",
			Name = "Duration",
			Description = "How long the notification stays on screen",
			Optional = true,
			Default = 5,
		},
	},
}
```

---

### Server implementation (`notifyServer.luau`)

Filter both the `Title` and `Message` arguments through `TextService:FilterStringAsync()` using the command executor's `UserId`. Once filtered, dispatch the payload to the target clients.

```luau
const TextService = game:GetService("TextService")

const function filterText(text: string, fromUserId: number): string?
	const success, filterResult = pcall(TextService.FilterStringAsync, TextService, text, fromUserId)

	if not (success and filterResult) then
		return
	end

	const broadcastSuccess, filteredString = pcall(filterResult.GetNonChatStringForBroadcastAsync, filterResult)

	return broadcastSuccess and filteredString
end

return function(context: any, targets: { Player }, title: string, message: string, duration: number): string
	const authorUserId = context.Executor.UserId

	-- Filter title and message before sending to target players
	const filteredTitle = filterText(title, authorUserId)
	const filteredMessage = filterText(message, authorUserId)

	if not (filteredTitle and filteredMessage) then
		return "Failed to filter notification text."
	end

	for _, player in ipairs(targets) do
		context:SendEvent(player, "ShowNotification", filteredTitle, filteredMessage, duration)
	end

	return `Notification sent to {#targets} player(s).`
end
```

:::tip Broadcasting to Everyone

If you want to broadcast a notification to every connected player at once, use `context:BroadcastEvent("ShowNotification", filteredTitle, filteredMessage, duration)` instead of looping over players.

:::

---

### Client event listener (`CmdrClient.luau`)

Register a listener on the client with `CmdrClient:HandleEvent` to receive the filtered payload and trigger your UI logic.

```luau
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const StarterGui = game:GetService("StarterGui")

const Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

-- Listen for the custom "ShowNotification" network event
Cmdr:HandleEvent("ShowNotification", function(title: string, message: string, duration: number)
	-- Replace this with your custom UI/notification framework logic
	print(`[Notification Received] {title}: {message} (Duration: {duration}s)`)

	-- Example StarterGui notification call:
	StarterGui:SetCore("SendNotification", {
		Title = title,
		Text = message,
		Duration = duration,
	})
end)
```
