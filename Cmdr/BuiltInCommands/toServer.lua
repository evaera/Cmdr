local teleport = require(script.Parent:WaitForChild("teleportServer"))

return function (context, toPlayer)
  teleport(context, { context.Executor }, toPlayer)
end