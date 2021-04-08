---
home: true
heroImage: /logo.png
actionText: Get Started →
actionLink: /guide/Setup
features:
- title: Integrates with your systems
  details: Make commands that integrate and control your existing systems. Use commands to help debug your game during development by triggering events in your game or print out targeted debug information.
- title: Type-Safe with Intelligent Auto-completion
  details: Discover commands and possible values for arguments naturally with game-state-aware auto-complete. Argument types are validated on the client and server, so in your command code you never have to worry about an argument being of the wrong type or missing.
- title: 100% Extensible
  details: Cmdr ships with a set of optional default commands for the very most commonly used commands for debugging your game, but the real power of Cmdr is its extensibility. You can register your own commands and argument types so Cmdr can be exactly what you need it to be.
footer: MIT licensed | Copyright © 2018-present eryn L. K.
---

<video controls style="margin: 0 auto; display: block">
  <source src="https://giant.gfycat.com/HatefulTanAzurewingedmagpie.mp4" />
</video>

<br><br>

Cmdr is designed specifically to write your own commands and argument types, so that it can fit with the rest of your game nicely. In addition to the standard admin commands (teleport, kill, kick), Cmdr is also great for debug commands in your game (say, if you wanted to have a command to give you a weapon, reset a round, teleport you between places in your universe).

Cmdr provides a friendly API that lets game developers choose if they want to register the default admin commands, register their own commands, choose a different key bind for activating the console, and disabling Cmdr altogether.

Cmdr has a robust and friendly type validation system (making sure strings are strings, players are players, etc), which can give end users real time command validation as they type, and automatic error messages. By the time the command actually gets to your code, you can be assured that all of the arguments are present and of the correct type.

If you have any questions, suggestions, or ideas for Cmdr, or you run into a bug, please don't hesitate to [open an issue](https://github.com/evaera/Cmdr/issues)! PRs are welcome as well.
