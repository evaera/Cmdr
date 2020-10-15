---
title: Registry
docs:
  desc: The registry handles registering commands, types, and hooks. Exists on both client and server.

  types:
    - name: TypeDefinition
      kind: interface
      type:
        DisplayName:
          type: string
          desc: Optionally overrides the user-facing name of this type in the autocomplete menu. If omitted, the registered name of this type will be used.
        Prefixes:
          type: string
          desc: String containing default <a href="https://eryn.io/Cmdr/guide/Commands.html#prefixed-union-types">Prefixed Union Types</a> for this type. This property should omit the initial type name, so this string should begin with a prefix character, e.g. `Prefixes = "# integer ! boolean"`.
        Transform:
          desc: "Transform is an optional function that is passed two values: the raw text, and the player running the command. Then, whatever values this function returns will be passed to all other functions in the type (`Validate`, `Autocomplete`, and `Parse`)."
          type:
            kind: union
            types:
              - nil
              - kind: function
                params: "rawText: string, executor: Player"
                returns: T
        Validate:
          desc: |
            The `Validate` function is passed whatever is returned from the Transform function (or the raw value if there is no Transform function). If the value is valid for the type, it should return `true`. If it the value is invalid, it should return two values: false, and a string containing an error message.

            If this function isn't present, anything will be considered valid.
          type:
            kind: union
            types:
              - nil
              - kind: function
                params: "value: T"
                returns:
                  - boolean
                  - string?
        ValidateOnce:
          desc: |
            This function works exactly the same as the normal `Validate` function, except it only runs once (after the user presses Enter). This should only be used if the validation process is relatively expensive or needs to yield. For example, the PlayerId type uses this because it needs to call `GetUserIdFromNameAsync` in order to validate.

            For the vast majority of types, you should just use `Validate` instead.
          type:
            kind: union
            types:
              - nil
              - kind: function
                params: "value: T"
                returns:
                  - boolean
                  - string?
        Autocomplete:
          desc: Should only be present for types that are possible to be auto completed. It should return an array of strings that will be displayed in the auto complete menu. It can also return a second value, which can be a  dictionary with options such as `IsPartial` as described above.
          type:
            kind: union
            types:
              - nil
              - kind: function
                params: "value: T"
                returns:
                  - array<string>
                  - type:
                      kind: union
                      types:
                        - nil
                        - kind: interface
                          type:
                            IsPartial:
                              type: boolean?
                              desc: If `true`, pressing Tab to auto complete won't continue onwards to the next argument.
        Parse:
          desc: Parse is the only required function in a type definition. It is the final step before the value is considered finalized. This function should return the actual parsed value that will be sent to the command functions.
          type:
            kind: function
            params: "value: T"
            returns: any
        Default:
          desc: |
            The `Default` function is optional and should return the "default" value for this type, as a **string**. For example, the default value of the `players` type is the name of the player who ran the command.
          type:
            kind: union
            types:
              - nil
              - kind: function
                params: "player: Player"
                returns:
                  - string
        Listable:
          type: boolean?
          desc: |
            If you set the optional key `Listable` to `true` in your table, this will tell Cmdr that comma-separated lists are allowed for this type. Cmdr will automatically split the list and parse each segment through your Transform, Validate, Autocomplete, and Parse functions individually, so you don't have to change the logic of your Type at all.

            The only limitation is that your Parse function **must return a table**. The tables from each individual segment's Parse will be merged into one table at the end of the parse step. The uniqueness of values is ensured upon merging, so even if the user lists the same value several times, it will only appear once in the final table.

    - name: CommandArgument
      kind: interface
      type:
        Type:
          type:
            kind: union
            types:
              - string
              - TypeDefinition
          desc: The argument type (case sensitive), or an inline TypeDefinition object
        Name:
          type: string
          desc: The argument name, this is displayed to the user as they type.
        Description:
          type: string
          desc: A description of what the argument is, this is also displayed to the user.
        Optional:
          type: boolean?
          desc: If this is present and set to `true`, then the user can run the command without filling out this value. The argument will be sent to your commands as `nil`.
        Default:
          type: any?
          desc: If present, the argument will be optional and if the user doesn't supply a value, your function will receive whatever you set this to. Default being set implies Optional = true, so Optional can be omitted.

    - name: CommandDefinition
      kind: interface
      type:
        Name:
          type: string
          desc: The name that's in auto complete and displayed to user.
        Aliases:
          type: array<string>
          desc: Aliases that are not in the autocomplete, but if matched will run this command just the same. For example, `m` might be an alias of `announce`.
        Description:
          type: string
          desc: A description of the command which is displayed to the user.
        Group:
          type: any?
          desc: Optional, can be be any value you wish. This property is intended to be used in hooks, so that you can categorize commands and decide if you want a specific user to be able to run them or not.
        Args:
          type: array<CommandArgument | function(context) → CommandArgument>
          desc: Array of `CommandArgument` objects, or functions that return `CommandArgument` objects.
        Data:
          desc: If your command needs to gather some extra data from the client that's only available on the client, then you can define this function. It should accept the CommandContext for the current command as an argument, and return a single value which will be available in the command with [[CommandContext.GetData]].
          type:
            kind: union
            types:
              - nil
              - kind: function
                params: "context: CommandContext, ...: any"
                returns: any
        ClientRun:
          desc: |
            If you want your command to run on the client, you can add this function to the command definition itself. It works exactly like the function that you would return from the Server module.

            - If this function returns a string, the command will run entirely on the client and won't touch the server (which means server-only hooks won't run).
            - If this function doesn't return anything, it will fall back to executing the Server module on the server.

            ::: warning
            If this function is present and there isn't a Server module for this command, it is considered an error to not return a string from this function.
            :::
          type:
            kind: union
            types:
              - nil
              - kind: function
                params: "context: CommandContext, ...: any"
                returns: string?
        AutoExec:
          desc: A list of commands to run automatically when this command is registered at the start of the game. This should primarily be used to register any aliases regarding this command with the built-in `alias` command, but can be used for initializing state as well. Command execution will be deferred until the end of the frame.
          type: array<string>

  properties:
    - name: Cmdr
      type: Cmdr | CmdrClient
      desc: A reference to Cmdr. This may either be the server or client version of Cmdr depending on where the code is running.

  functions:
    - name: RegisterTypesIn
      tags: [ 'server only' ]
      desc: Registers all types from within a container.
      params:
        - name: container
          type: Instance
    - name: RegisterType
      desc: Registers a type. This function should be called from within the type definition ModuleScript.
      params:
        - name: name
          type: string
        - name: typeDefinition
          type: TypeDefinition
    - name: RegisterTypePrefix
      since: v1.3.0
      desc: Registers a <a href="https://eryn.io/Cmdr/guide/Commands.html#prefixed-union-types">Prefixed Union Type</a> string for the given type. If there are already type prefixes for the given type name, they will be **concatenated**. This allows you to contribute prefixes for default types, like `players`.
      params:
        - name: name
          type: string
        - name: union
          type: string
          desc: The string should omit the initial type name, so this string should begin with a prefix character, e.g. `"# integer ! boolean"`.
    - name: RegisterTypeAlias
      since: v1.3.0
      desc: "Allows you to register a name which will be expanded into a longer type which will can be used as command argument types. For example, if you register the alias `\"stringOrNumber\"` it could be interpreted as `\"string # number\"` when used."
      params:
        - name: name
          type: string
        - name: union
          type: string
          desc: "The string should *include* the initial type name, e.g. `\"string # integer ! boolean\"`."
    - name: GetType
      desc: Returns a type definition with the given name, or nil if it doesn't exist.
      params:
        - name: name
          type: string
      returns: TypeDefinition?
    - name: GetTypeName
      since: v1.3.0
      desc: Returns a type name taking aliases into account. If there is no alias, the `name` parameter is simply returned as a pass through.
      params:
        - name: name
          type: string
      returns: string
    - name: RegisterHooksIn
      tags: [ 'server only' ]
      desc: Registers all hooks from within a container on both the server and the client. If you want to add a hook to the server or the client only (not on both), then you should use the [[Registry.RegisterHook]] method directly by requiring Cmdr in a server or client script.
      params:
        - name: container
          type: Instance
    - name: RegisterCommandsIn
      tags: [ 'server only' ]
      desc: Registers all commands from within a container.
      params:
        - name: container
          type: Instance
        - name: filter
          optional: true
          desc: If present, will be passed a command definition which will then only be registered if the function returns `true`.
          type:
            kind: function
            params:
              - name: command
                type: CommandDefinition
            returns: boolean
    - name: RegisterCommand
      tags: [ 'server only' ]
      desc: Registers an individual command directly from a module script and possible server script. For most cases, you should use [[Registry.RegisterCommandsIn]] instead.
      params:
        - name: commandScript
          type: ModuleScript
        - name: commandServerScript
          type: ModuleScript?
        - name: filter
          optional: true
          desc: If present, will be passed a command definition which will then only be registered if the function returns `true`.
          type:
            kind: function
            params:
              - name: command
                type: CommandDefinition
            returns: boolean
    - name: RegisterDefaultCommands
      tags: [ 'server only' ]
      desc: Registers the default set of commands.
      params:
        - name: groups
          type: array<string>
          desc: Limit registration to only commands which have their `Group` property set to thes.
      overloads:
        - params:
          - name: filter
            type:
              kind: function
              params:
                - name: command
                  type: CommandDefinition
              returns: boolean
    - name: GetCommand
      desc: Returns the CommandDefinition of the given name, or nil if not registered. Command aliases are also accepted.
      params:
        - name: name
          type: string
      returns: CommandDefinition?
    - name: GetCommands
      returns: array<CommandDefinition>
      desc: Returns an array of all commands (aliases not included).
    - name: GetCommandNames
      returns: array<string>
      desc: Returns an array of all command names.
    - name: RegisterHook
      desc: Adds a hook. This should probably be run on the server, but can also work on the client. Hooks run in order of priority (lower number runs first).
      params:
        - name: hookName
          type: "\"BeforeRun\" | \"AfterRun\""
        - name: callback
          type:
            kind: function
            params:
              - name: context
                type: CommandContext
            returns: string?
        - name: priority
          type: number?
    - name: GetStore
      desc: Returns a table saved with the given name. This is the same as [[CommandContext.GetStore]]
      params:
        - name: name
          type: string
      returns: table
---

<ApiDocs />
