---
title: ArgumentContext
docs:
  properties:
    - name: Command
      type: CommandContext
      desc: The command that this argument belongs to.
    - name: Name
      type: string
      desc: The name of this argument.
    - name: Type
      type: TypeDefinition
      desc: The type definition for this argument.
    - name: Required
      type: boolean
      desc: Whether or not this argument was required.
    - name: Executor
      type: Player
      desc: The player that ran the command this argument belongs to.
    - name: RawValue
      type: string
      desc: The raw, unparsed value for this argument.
    - name: RawSegments
      type: array<string>
      desc: An array of strings representing the values in a comma-separated list, if applicable.
    - name: Prefix
      type: string
      desc: The prefix used in this argument (like `%` in `%Team`). Empty string if no prefix was used. See Prefixed Union Types for more details.

  functions:
    - name: GetValue
      returns: any
      desc: Returns the parsed value for this argument.
    - name: GetTransformedValue
      params: "segment: number"
      returns: any...
      desc: Returns the *transformed* value from this argument, see Types.

---

<ApiDocs />