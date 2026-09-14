local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

-- Prices are deliberately tied to permanent stat value: Speed and Critical are scarce upgrades.
local Shop: Types.Shop = {
	["Small Health Potion"] = { itemType = "Consumable", Cost = { Gold = 35 }, MaxPurchase = 25 },
	["Small Attack Potion"] = { itemType = "Consumable", Cost = { Gold = 60 }, MaxPurchase = 25 },
	["Small Defense Potion"] = { itemType = "Consumable", Cost = { Gold = 60 }, MaxPurchase = 25 },
	["Small Speed Potion"] = { itemType = "Consumable", Cost = { Gold = 180 }, MaxPurchase = 25 },
	["Small Critical Potion"] = { itemType = "Consumable", Cost = { Gold = 240 }, MaxPurchase = 25 },
}

return Shop
