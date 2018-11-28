local teleport = require(script.Parent:WaitForChild("teleportServer"))

return function (context, fromPlayers)
	return teleport(context, fromPlayers, context.Executor)
end
