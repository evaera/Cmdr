const HttpService = game:GetService("HttpService")

return function(_, url: string): string
	const success, response = pcall(HttpService.GetAsync, HttpService, url)

	return if success then response else `Failed to fetch URL: {response}`
end
