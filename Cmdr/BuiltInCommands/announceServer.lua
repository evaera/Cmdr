return function (context, text)
	context:BroadcastEvent("Message", ("[Announcement] %s"):format(text))

	return "Created announcement."
end