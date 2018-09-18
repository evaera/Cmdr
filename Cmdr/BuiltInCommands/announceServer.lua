return function (context, text)
	context:BroadcastEvent("Message", ("[Announcement] %s"):format(text))
	context:Reply("Bluh bli", Color3.fromRGB(0, 0, 255))

	return "Created announcement."
end