local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Shop: Types.Shop = {
	["Vital Jab"] = {
		itemType = "Skill",
		Cost = {
			Gold = 100,
		},
	},
}

return Shop
