local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Shop: Types.Shop = {
	["Vital Jab"] = {
		itemType = "Skill",
		Cost = {
			Gold = 100,
		},
	},
	["Consecutive Slashes"] = {
		itemType = "Skill",
		Cost = {
			Gold = 1000,
		},
	},
}

return Shop
