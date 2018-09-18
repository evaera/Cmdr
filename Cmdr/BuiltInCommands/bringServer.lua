local teleport = require(script.Parent:WaitForChild("teleportServer"))

return function (context, fromPlayers)
  teleport(context, fromPlayers, context.Executor)
end