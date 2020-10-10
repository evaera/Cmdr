---
title: "Meta-Commands"
---

# Meta-Commands

The `bind`, `alias`, and `run` commands make use of *command strings*. A command string is raw text made up of a command name and possibly predefined arguments that is run in the background as a command itself. Before these command strings are run, they are preprocessed, replacing arguments (in the format `$1`, `$2`, `$3`, etc.) and embedded commands with their textual values.

## Embedded commands
Sub-commands may be embedded inside command strings, in the format `${command arg1 arg2 arg3}`. These sub-commands are evaluated just before the command string is run, and are run every time the command string runs. They evaluate to whatever the command returns as output.

Embedded commands are nestable: `run echo ${run echo ${echo hello}!}` (displays `"hello!"`). We use `run` here instead of just running `echo` directly, because embedded commands are only evaluated in the preprocess step of commands that use *command strings* (which is only `run`, `alias`, and `bind`).

By default, if the evaluated command output has a space in it, the return value will be encapsulated in quote marks so that the entire value is perceived as one argument to Cmdr. In cases where it's desirable for Cmdr to parse each word as a separate argument, you can use use a literal syntax: `run teleport ${{"echo first second"}​}` (in this example, "first" and "second" would then become the first and second arguments to the `teleport` command, instead of the first argument being "first second")

## Run
Run is the simplest of the bunch, and does right what it says on the tin. It runs whatever text you give it immediately as a command. This is useful, because it evaluates embedded commands within the command string before running.

```
run ${{"echo kill me"}}
```

Commands can contain more than one distinct command, delimited by `&&`. This can be escaped by adding an additional ampersand, for example: `&&&`. You can escape an additional level by adding more. `&&&&` is a two level deep escape.

When using `&&`, you can access the previous command's output by using the `||` slot operator. For example

`run echo evaera && kill ||` (evaera dies)

The `run` command has a single-character alias, `>`, which can also be used to invoke it.

## Bind
Bind is a command that allows you to run a certain command string every time some event happens. The default bind type is by user input (mouse or keyboard input), but you can also bind to other events.

This is very powerful: You could define a command, like `cast_ability`, which casts a certain move in your game. Then, you could have a keybindings menu that allows the user to rebind keys, and whenever they do, it runs `CmdrClient:Run("bind", keyCode.Name, "cast_ability", abilityId)` in the background. By separating the user input from our hypothetical ability code, our code is made more robust as we can now trigger abilities from a number of possible events, in addition to the bound key.

If you prefix the first argument with `@`, you can instead select a player to bind to, which will run this command string every time that player chats. You can get the chat text by using `$1` in your command string.

In the future, you will be able to bind to network events as described in the previous section by prefixing the first argument with `!`.

The `unbind` command can be used to unbind anything that `bind` can bind.

## Alias
The alias command lets you create a new, single command out of a command string. Alias commands can contain more than one distinct command, delimited by `&&`. You can also accept arguments from the command with `$1` through `$5`.

```
alias farewell announce Farewell, $1! && kill $1
```

Then, if we run `farewell evaera`, it would make an announcement saying "Farewell, evaera!" and then kill the player called "evaera".

As another example, you could create a command that killed anyone your mouse was currently hovering over like so:

```
alias pointer_of_death kill ${hover}
```

### Types and Descriptions

You can optionally provide types, names, and descriptions to your alias arguments, like so: `$1{type|Name|Description here}`. For example:

```
alias goodbye kill $1{player|Player|The player you want to kill.}
```

Name and Description are optional. These are all okay:
- `alias goodbye kill $1{player}`
- `alias goodbye kill $1{player|Player}`
- `alias goodbye kill $1{player|Player|The player you want to kill.}`

Additionally, you can supply a description for the command itself:

```
alias "goodbye|Kills a player." kill $1{player|Player|The player you want to kill.}
```