const ReplicatedStorage = game:GetService("ReplicatedStorage")

const BuiltInGuards = ReplicatedStorage.CmdrClient.Shared.BuiltInGuards
const NonEmptyString = require(BuiltInGuards.NonEmptyString) :: (number) -> (any) -> string?

return {
	Name = "announce",
	Aliases = { "m" },
	Description = "Makes a server-wide announcement.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "string",
			Name = "Text",
			Description = "The announcement text.",
		},
	},
	Guards = {
		NonEmptyString(1),
	},
}
