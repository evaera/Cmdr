---
title: Dispatcher
docs:
  desc: The Dispatcher handles parsing, validating, and evaluating commands. Exists on both client and server.
  properties:
    - name: Cmdr
      type: Cmdr | CmdrClient
      desc: A reference to Cmdr. This may either be the server or client version of Cmdr depending on where the code is running.
  functions:
    - name: Run
      tags: [ 'client only' ]
      desc: This should be used to invoke commands programmatically as the local player. Accepts a variable number of arguments, which are all joined with spaces before being run. This function will raise an error if any validations occur, since it's only for hard-coded (or generated) commands.
      params:
        - name: '...'
          type: string
      returns: string
    - name: EvaluateAndRun
      desc: Runs a command as the given player. If called on the client, only text is required. Returns output or error test as a string.
      params:
        - name: commandText
          type: string
        - name: executor
          type: Player?
        - name: options
          optional: true
          desc: If `Data` is given, it will be available on the server with [[CommandContext.GetData]]
          type:
            kind: interface
            type:
              Data: any?
              IsHuman: boolean
      returns: string
    - name: GetHistory
      tags: [ 'client only' ]
      returns: array<string>
      desc: Returns an array of the user's command history. Most recent commands are inserted at the end of the array.
---

<ApiDocs />