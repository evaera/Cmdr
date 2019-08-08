-- luacheck: ignore

stds.roblox = {
	globals = {
		"game",
		"workspace",
		"script"
	},

	read_globals = {
		-- Global objects

		-- Global functions
		"spawn",
		"delay",
		"warn",
		"wait",
		"tick",
		"typeof",
		"settings",
		"utf8",

		-- Global Namespaces
		"Enum",
		"debug",

		math = {
			fields = {
				"clamp",
				"sign"
			}
		},

		-- Global types
		"Instance",
		"Vector2",
		"Vector3",
		"CFrame",
		"Color3",
		"UDim",
		"UDim2",
		"Rect",
		"TweenInfo",
		"Random",
		"BrickColor"
	}
}

max_line_length = false

ignore = { "self" }

std = "lua51+roblox"
