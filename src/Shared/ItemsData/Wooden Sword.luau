local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Item: Types.Equipment = {
	Stats = {
		Attack = 1,
		Defense = 0,
		CriticalChance = 0,
		CriticalPower = 0,
		Luck = 0,
		Speed = 0,
	},
	Passive = "",
	Data = {
		SellsFor = 10,
		ItemType = "Equipment",
		SubType = "Weapon",
		Name = "Wooden Sword",
		Stackable = false,
	},
}

function Item:CanEquip(PlayerData: Types.PlayerData): boolean
	return PlayerData and PlayerData.Level() >= 1
end

return Item
