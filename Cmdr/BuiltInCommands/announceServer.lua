return function (context, text)
	context:BroadcastEvent("Message", text, context.Executor)

	return "Created announcement."
end