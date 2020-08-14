---
title: CommandContext
docs:
  properties:
    - name: Cmdr
      type: Cmdr | CmdrClient
      desc: A reference to Cmdr. This may either be the server or client version of Cmdr depending on where the command is running.
    - name: Dispatcher
      type: Dispatcher
      desc: The dispatcher that created this command.
    - name: Name
      type: string
      desc: The name of the command.
    - name: Alias
      type: string
      desc: The specific alias of this command that was used to trigger this command (may be the same as `Name`)
    - name: RawText
      type: string
      desc: The raw text that was used to trigger this command.
    - name: Group
      desc: The group this command is a part of. Defined in command definitions, typically a string.
    - name: State
      desc: A blank table that can be used to store user-defined information about this command's current execution. This could potentially be used with hooks to add information to this table which your command or other hooks could consume.
      type: table
    - name: Aliases
      type: array<string>
      desc: Any aliases that can be used to also trigger this command in addition to its name.
    - name: Description
      type: string
      desc: The description for this command from the command definition.
    - name: Executor
      type: Player
      desc: The player who ran this command.
    - name: RawArguments
      type: array<string>
      desc: An array of strings which is the raw value for each argument.
    - name: Arguments
      type: array<ArgumentContext>
      desc: An array of ArgumentContext objects, the parsed equivalent to RawArguments.
    - name: Response
      type: string?
      desc: The command output, if the command has already been run. Typically only accessible in the AfterRun hook.

  functions:
    - name: GetArgument
      params:
        - name: index
          type: number
      returns: ArgumentContext
      desc: Returns the ArgumentContext for the given index.
    - name: GetData
      desc: Returns the command data that was sent along with the command. This is the return value of the Data function from the command definition.
    - name: GetStore
      params:
        - name: name
          type: string
      returns: table
      desc: Returns a table of the given name. Always returns the same table on subsequent calls. Useful for storing things like ban information. Same as [[Registry.GetStore]].
    - name: SendEvent
      params: "player: Player, event: string"
      desc: Sends a network event of the given name to the given player. See Network Event Handlers.
    - name: BroadcastEvent
      params: "event: string, ...: any"
      desc: Broadcasts a network event to all players. See Network Event Handlers.
    - name: Reply
      params: "text: string, color: Color3?"
      desc: Prints the given text in the user's console. Useful for when a command needs to print more than one message or is long-running. You should still `return` a string from the command implementation when you are finished, `Reply` should only be used to send additional messages before the final message.
    - name: HasImplementation
      desc: |
       Returns `true` if the command has an implementation on this machine. For example, this function will return `false` from the client if you call it on a command that only has a server-side implementation.
       Note that commands can potentially run on both the client and the server, so what this property returns on the server is not related to what it returns on the client, and vice versa. Likewise, receiving a return value of `true` on the client does not mean that the command won't run on the server, because Cmdr commands can run a first part on the client and a second part on the server.
       This function only answers one question if you run the command; does it run any code as a result of that on this machine?
      returns: boolean
      since: v1.6.0
---

<ApiDocs />
