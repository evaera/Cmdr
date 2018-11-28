local teleport = require(script.Parent:WaitForChild("teleportServer"))

return function (context, toPlayer)
	return teleport(context, { context.Executor }, toPlayer)
end
