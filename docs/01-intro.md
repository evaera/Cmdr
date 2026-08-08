---
sidebar_position: -1
---

# Introduction

:::info Feedback
This website is new and [your feedback](https://github.com/evaera/Cmdr/issues/new?assignees=&labels=scope%3Aixp&projects=&template=websitefeedback.md) will help improve it.
:::

## What is Cmdr and who is it for?

Cmdr is an extensible console built for the Roblox platform. It makes it easy for developers to write custom commands and straightforward for users to run them.

Originally designed for debugging, Cmdr has grown into a general-purpose command and administration system. You can use it for debugging, player administration, or custom game mechanics.

## Why should I use it?

- **Type-Safe Auto-Complete:** Catches typos and input mistakes before the user presses Enter. Command implementations receive fully typed, validated arguments automatically.
- **Unobtrusive & Responsive:** Integrates quietly into existing codebases without getting in the way. Executes heavy work on the client to provide immediate feedback, even on poor network connections.
- **Extensible Architecture:** Includes built-in commands and types, but lets you seamlessly plug in your own custom implementations.
- **Built-in Meta-Commands:** Supports command chaining, aliases, custom key bindings, and automated startup scripts.
- **Battle-Tested:** Used for over five years across games with billions of visits. Saves hundreds of hours compared to building a console from scratch.

## Why _shouldn't_ I use it?

Cmdr might not be the right tool for your game if:

- **You want a massive library of pre-made "admin" commands out of the box.** Cmdr ships with core utility commands, not a full suite of moderation or fun commands. You'll need to write the bulk of your command library yourself or adapt them from the [Cookbook](/docs/community/cookbook).
- **You or your team are still learning Luau.** Cmdr is developer-focused. You'll need to write your own [command implementations](/docs/commands-reference/commands), [permission hooks](/docs/commands-reference/hooks), and custom systems (like logging) from scratch using code.
- **Mobile or console players are your primary audience.** Cmdr is designed keyboard-first. While it works on other platforms, mobile UI support is basic and you'll need to build your own custom toggles or buttons for touch and controller users to open the console.

## How do I get started?

:::warning Do not modify the source code

Please **do not** modify the source code of Cmdr for your game. Use the API to customize behavior. Modifying core files makes receiving future updates significantly harder.

If you hit a limitation or bug, please [open an issue](https://github.com/evaera/cmdr/issues) or [contribute a fix](/docs/contribute/index).

:::

1. Follow the [Installation guide](/docs/getting-started/installation).
2. Review the core concepts in the documentation.
3. Reference the [API reference](/api/Cmdr) as needed for deeper integration.

_Note: Avoid third-party setup tutorials on YouTube or the DevForum, as they frequently contain outdated or incorrect practices._

## How do I get help with Cmdr?

:::tip Luau knowledge — <u>please read!</u>

Cmdr is designed for developers comfortable with [Luau](https://luau-lang.org).

Support channels exist exclusively for Cmdr-specific API issues. We cannot assist with general programming syntax or build custom command logic (e.g., "how do I make a fly command?").

:::

Stick to official resources for reliable setup instructions:

- **Documentation:** Use this site and the official [Cookbook](/docs/community/cookbook).
- **Discord:** Join the [Cmdr Discord server](https://discord.gg/xFzPVg5WXm) and post in the [`help`](https://discord.com/channels/1497725941974040731/1497730144260063334) channel.
