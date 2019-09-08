const fetch = require('node-fetch')
const fs = require('fs')

const dataTypes = ["Axes","BrickColor","CFrame","Color3","ColorSequence","ColorSequenceKeypoint","DockWidgetPluginGuiInfo","Enum","EnumItem","Enums","Faces","Instance","NumberRange","NumberSequence","NumberSequenceKeypoint","PathWaypoint","PhysicalProperties","Random","Ray",'RBXScriptConnection',"RBXScriptSignal","Rect","Region3","Region3int16","TweenInfo","UDim","UDim2","Vector2","Vector2int16","Vector3","Vector3int16"]

async function main () {
  const req = await fetch('https://raw.githubusercontent.com/CloneTrooper1019/Roblox-Client-Watch/roblox/API-Dump.json')

  const api = await req.json()

  const types =
    api.Classes.map(c => ({
      name: c.Name,
      link: `https://developer.roblox.com/en-us/api-reference/class/${c.Name}`
    }))
    .concat(api.Enums.map(e => ({
      name: `Enum.${e.Name}`,
      link: `https://developer.roblox.com/en-us/api-reference/enum/${e.Name}`
    })))
    .concat(dataTypes.map(t => ({
      link: `https://developer.roblox.com/en-us/api-reference/datatype/${t}`,
      name: t
    })))
    .reduce((a, v) => {
      a[v.name] = { link: v.link }
      return a
    }, {})

  fs.writeFileSync('types.json', JSON.stringify(types))
}

main()