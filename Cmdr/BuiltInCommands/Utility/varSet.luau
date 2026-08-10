const ReplicatedStorage = game:GetService("ReplicatedStorage")

const BuiltInGuards = ReplicatedStorage.CmdrClient.Shared.BuiltInGuards
const IsDataStoreAvailable = require(BuiltInGuards.IsDataStoreAvailable) :: (number?) -> (any) -> string?

return {
	Name = "var=",
	Description = "Sets a stored value.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "storedKey",
			Name = "Key",
			Description = "The key to set, saved in your user data store. Keys prefixed with . are not saved. Keys prefixed with $ are game-wide. Keys prefixed with $. are game-wide and non-saved.",
		},
		{
			Type = "string",
			Name = "Value",
			Description = "Value or values to set.",
			Default = "",
		},
	},
	Guards = {
		IsDataStoreAvailable(1),
	},

	ClientRun = function(context: any, key: string)
		context:GetStore("vars_used")[key] = true
	end,
}
