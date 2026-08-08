return function(registry: any)
	const urlType = {
		Validate = function(text: string): (boolean, string?)
			if text:match("^https?://.+$") then
				return true
			end

			return false, "URLs must begin with http:// or https://"
		end,

		Parse = function(text: string): string
			return text
		end,
	}

	registry:RegisterType("url", urlType)
	registry:RegisterType("urls", registry.Cmdr.Util.MakeListableType(urlType))
end
