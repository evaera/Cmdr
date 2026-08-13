export default function prismLuau(Prism) {
  Prism.languages.luau = {
    comment: [
      {
        pattern: /--!(?:strict|nonstrict|nolint|optimize)\b[^\r\n]*/,
        alias: ["comment", "directive"],
      },
      {
        pattern: /^#!.+/m,
        alias: ["comment", "special-comment"],
        greedy: true,
      },
      {
        pattern: /--\[(=*)\[[\s\S]*?\]\1\]/,
        greedy: true,
      },
      {
        pattern: /--[^\r\n]*/,
        greedy: true,
      },
    ],

    attribute: {
      pattern: /@\w+/,
      alias: "symbol",
    },

    string: [
      {
        pattern: /`(?:\\.|\{[\s\S]*?\}|[^`\\])*`/,
        greedy: true,
        inside: {
          interpolation: {
            pattern: /(^|[^\\])\{[\s\S]*?\}/,
            lookbehind: true,
            alias: "expression",
            inside: {
              "interpolation-punctuation": {
                pattern: /^\{|\}$/,
                alias: "punctuation",
              },
              rest: null,
              variable: /\b[a-zA-Z_]\w*\b/,
            },
          },
          string: /[\s\S]+/,
        },
      },
      {
        pattern: /(?:^|[^\]])\[(=*)\[[\s\S]*?\]\1\]/,
        lookbehind: true,
        greedy: true,
      },
      {
        pattern: /(["'])(?:(?!\1)[^\\\r\n]|\\[\s\S])*\1/,
        greedy: true,
      },
    ],

    number:
      /\b(?:0x[a-fA-F0-9_]+|0b[01_]+|(?:\d[_\d]*\.\d[_\d]*|\d[_\d]*)(?:[eE][+-]?\d[_\d]*)?)\b/,

    keyword:
      /\b(?:and|break|do|else|elseif|end|false|for|function|goto|if|in|local|nil|not|or|repeat|return|then|true|until|while|continue|const|type|export)\b/,

    "builtin-type": {
      pattern: /\b(?:any|boolean|buffer|never|number|string|thread|unknown)\b/,
      alias: "class-name",
    },

    "class-name":
      /\b(?:Axes|CatalogSearchParams|CFrame|Color3|ColorSequence|ColorSequenceKeypoint|DockWidgetPluginGuiInfo|Enum|Faces|Font|Instance|NumberRange|NumberSequence|NumberSequenceKeypoint|OverlapParams|PathWaypoint|PhysicalProperties|Random|Ray|RaycastParams|RaycastResult|RBXScriptConnection|RBXScriptSignal|Rect|Region3|Region3int16|Secret|SharedTable|TweenInfo|UDim|UDim2|Vector2|Vector2int16|Vector3|Vector3int16|[A-Z]\w*)\b/,

    metamethod: {
      pattern:
        /\b__(?:index|newindex|add|sub|mul|div|idiv|mod|pow|unm|len|concat|eq|lt|le|call|tostring|mode|metatable|type|iter)\b/,
      alias: "builtin",
    },

    builtin:
      /\b(?:_G|_VERSION|assert|bit32|buffer|coroutine|debug|error|getmetatable|ipairs|math|next|pairs|pcall|print|rawequal|rawget|rawlen|rawset|require|select|setmetatable|string|table|task|tonumber|tostring|type|typeof|unpack|utf8|xpcall|game|workspace|script|plugin|shared|UserSettings)\b/,

    function: /(?!\d)\w+(?=\s*(?:[\({"`]|\[\[))/,

    operator: /::|\.\.\.|\.\.=?|\/\/=?|==|~=|<=|>=|[+\-*\/%^#=<>]=?/,

    punctuation: /[()[\]{},;.:?]/,
  };

  Prism.languages.luau.string[0].inside.interpolation.inside.rest = Prism.languages.luau;
}
