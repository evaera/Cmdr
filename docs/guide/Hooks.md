---
title: Hooks
---

# Hooks

Hooks are callback functions that you can register which *hook* into the command execution process. Hooks are extremely useful: they can be used for implementing a custom permission system, logging commands, or overriding command output.

Hooks can be registered on both the server and the client. Server commands will run server and client hooks, and client commands will run only client hooks. Depending on your application, you may need to register hooks on one or both. For example, logging may only need to be registered on the server, but permissions might need to be registered on the client in addition to the server.

There can be many hooks of each type, and they are all run until one returns a string, which will replace the command response in the console.

## BeforeRun

The callback is passed the CommandContext for the relevant command. The hooks are the last thing to run before the command itself, so all properties are available.

This hook can be used to interrupt command execution (useful for permissions) by returning a string. The returned string will replace the command output on the executing user's screen. If the callback returns nothing (`nil`), then the command will run normally.

::: warning Security Warning
Commands will be blocked from running in-game unless you configure at least one BeforeRun hook.
:::

As a quick way to register hooks on both the server and the client, you can make a folder for your hooks, with module scripts in them which return a function. Similar to Types, if you call `Cmdr:RegisterHooksIn(yourFolderHere)` from the server, Cmdr will load all ModuleScripts in the folder on the server and the client, so you only need to write your code once.

```lua
-- A ModuleScript inside your hooks folder.
return function (registry)
	registry:RegisterHook("BeforeRun", function(context)
		if context.Group == "DefaultAdmin" and context.Executor.UserId ~= game.CreatorId then
			return "You don't have permission to run this command"
		end
	end)
end
```

## AfterRun

The AfterRun hook runs, as its name implies, directly after a command is run. The callback is also passed a CommandContext, but the `Response` property is now available, which is the response from the command implementation (what would normally be displayed after running the command).

If this callback returns a string, then it will replace the normal response on the user's screen. If the callback returns nothing (`nil`), then the response will be shown normally.

This hook is most useful for logging. Since we don't want to add this hook on the client in this example, we can just require the server version of Cmdr and add this hook directly right here (as opposed to what we did in the BeforeRun example, which adds the hook to the client as well):

```lua
Cmdr.Registry:RegisterHook("AfterRun", function(context)
  print(context.Response) -- see the actual response from the command execution
  return "Returning a string from this hook replaces the response message with this text"
end)
```
