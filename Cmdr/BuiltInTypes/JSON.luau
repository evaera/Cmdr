const HttpService = game:GetService("HttpService")

return function(registry: any)
	registry:RegisterType("json", {
		Validate = function(text: string): boolean
			return pcall(HttpService.JSONDecode, HttpService, text)
		end,

		Parse = function(text: string): { [string]: any } | any
			return HttpService:JSONDecode(text)
		end,
	})
end
