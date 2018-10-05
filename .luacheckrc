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

ignore = { "111" }

std = "lua51+roblox"