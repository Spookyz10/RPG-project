local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local ItemRecipe: Types.Recipes = {}

ItemRecipe.Recipe = {
	["Wolf's Fang"] = { Amount = 1 },
	["Wilderbone"] = { Amount = 1 },
	["Dark Ivy "] = { Amount = 1 },
}

function ItemRecipe.GetRequirement(Data: Types.PlayerData): (boolean, string)
	return Data.Level > 1, "You need at least level 1 to craft this item."
end

return ItemRecipe
