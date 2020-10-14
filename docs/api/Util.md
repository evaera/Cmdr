---
title: Util
docs:
  types:
    - name: NamedObject
      kind: interface
      desc: Any object with a `Name` property.
      type:
        Name: string

  functions:
    - name: MakeDictionary
      params: "array: array<T>"
      returns: dictionary<T, true>
      static: true
      desc: Accepts an array and flips it into a dictionary, its values becoming keys in the dictionary with the value of `true`.
    - name: Map
      static: true
      desc: Maps values from one array to a new array. Passes each value through the given callback and uses its return value in the same position in the new array.
      params:
        - name: array
          type: array<T>
        - name: mapper
          type:
            kind: function
            params: "value: T, index: number"
            returns: U
      returns: array<U>
    - name: Each
      static: true
      desc: "Maps arguments #2-n through callback and returns all values as tuple."
      params:
        - name: mapper
          type:
            kind: function
            params: "value: T"
            returns: U
        - name: "..."
          type: T
      returns: U...
    - name: MakeFuzzyFinder
      static: true
      desc: |
        Makes a fuzzy finder for the given set or container. You can pass an array of strings, array of instances, array of EnumItems, array of dictionaries with a Name key or an instance (in which case its children will be used).
      params:
        - name: set
          type:
            kind: union
            types:
              - array<string>
              - array<Instance>
              - array<EnumItem>
              - "array<NamedObject>"
              - Instance
      returns:
        - type:
            kind: function
            params:
              - name: text
                type: string
              - name: returnFirst
                type: boolean?
            returns: any
          desc: Accepts a string and returns a table of matching objects. Exact matches are inserted in the front of the resultant array.
    - name: GetNames
      static: true
      params: "instances: array<NamedObject>"
      returns: array<string>
      desc: Accepts an array of instances (or anything with a Name property) and maps them into an array of their names.
    - name: SplitStringSimple
      static: true
      params: "text: string, separator: string"
      returns: array<string>
      desc: Slits a string into an array split by the given separator.
    - name: SplitString
      static: true
      params: "text: string, max: number?"
      returns: array<string>
      desc: Splits a string by spaces, but taking double-quoted sequences into account which will be treated as a single value.
    - name: TrimString
      static: true
      params: "text: string"
      returns: string
      desc: Trims whitespace from both sides of a string.
    - name: GetTextSize
      static: true
      params: "text: string, label: TextLabel, size: Vector2?"
      returns: Vector2
      desc: Returns the text bounds size as a Vector2 based on the given label and optional display size. If size is omitted, the absolute width is used.
    - name: MakeEnumType
      static: true
      params: "type: string, values: array<string | { Name: string }>"
      returns: TypeDefinition
      desc: Makes an Enum type out of a name and an array of strings. See Enum Values.
    - name: MakeListableType
      static: true
      params: "type: TypeDefinition, override?: dictionary"
      returns: TypeDefinition
      desc: Takes a singular type and produces a plural (listable) type out of it.
    - name: MakeSequenceType
      static: true
      desc: |
        A helper function that makes a type which contains a sequence, like Vector3 or Color3. The delimeter can be either `,` or whitespace, checking `,` first. options is a table that can contain:

        - `TransformEach`: a function that is run on each member of the sequence, transforming it individually.
        - `ValidateEach`: a function is run on each member of the sequence validating it. It is passed the value and the index at which it occurs in the sequence. It should return true if it is valid, or false and a string reason if it is not.

        And one of:

        - `Parse`: A function that parses all of the values into a single type.
        - `Constructor`: A function that expects the values unpacked as parameters to create the parsed object. This is a shorthand that allows you to set Constructor directly to Vector3.new, for example.
      params:
        - name: options
          type:
            kind: intersection
            types:
              - kind: interface
                type:
                  TransformEach:
                    kind: function
                    params: "value: any"
                  ValidateEach:
                    kind: function
                    params: "value: any, index: number"
                    returns:
                      - boolean
                      - string
              - kind: union
                parens: true
                types:
                  - kind: interface
                    type:
                      Parse:
                        kind: function
                        params: "values: array<any>"
                        returns: any
                  - kind: interface
                    type:
                      Constructor:
                        kind: function
                        params: "...: any"
    - name: SplitPrioritizedDelimeter
      static: true
      params: "text: string, delimters: array<string>"
      returns: array<string>
      desc: Splits a string by a single delimeter chosen from the given set. The first matching delimeter from the set becomes the split character.
    - name: SubstituteArgs
      static: true
      desc: Accepts a string with arguments (such as $1, $2, $3, etc) and a table or function to use with string.gsub. Returns a string with arguments replaced with their values.
      params:
        - name: text
          type: string
        - name: replace
          type:
            kind: union
            types:
              - array<string>
              - dictionary<string, string>
              - kind: function
                params: "var: string"
                returns: string
      returns: string
    - name: RunEmbeddedCommands
      static: true
      params: "dispatcher: Dispatcher, commandString: string"
      returns: string
      desc: Accepts the current dispatcher and a command string. Parses embedded commands from within the string, evaluating to the output of the command when run with `dispatcher:EvaluateAndRun`. Returns the response string.
    - name: EmulateTabstops
      static: true
      params: "text: string, tabWidth: number"
      returns: string
      desc: Returns a string emulating `\t` tab stops with spaces.
    - name: ParseEscapeSequences
      static: true
      params: "text: string"
      returns: string
      desc: Replaces escape sequences with their fully qualified characters in a string. This only parses `\n`, `\t`, `\uXXXX`, and `\xXX` where `X` is any hexadecimal character.


---

<ApiDocs />