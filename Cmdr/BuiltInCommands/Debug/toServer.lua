local teleport = require(script.Parent.Parent:WaitForChild("Admin"):WaitForChild("teleportServer"))

return function (context, toPlayer)
	return teleport(context, { context.Executor }, toPlayer)
end
