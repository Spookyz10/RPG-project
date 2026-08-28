local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local getCappedInfo = require(ReplicatedStorage.Shared.getCappedInfo)
local Item: Types.Consumable = {
	Kind = "Consumable",
	Amount = 1,
	Stat = "Defense",
	Data = {
		SellsFor = 10,
		ItemType = "Consumable",
		SubType = "Potion",
		Name = script.Name,
		Stackable = true,
		Cap = 999,
		Icon = "rbxassetid://3269592325",
		Rarity = "Common",
		Level = 1,
		Description = "Drink this to gain +1 Defense",
		ActionName = "Use",
		ID = "Small Defense Potion",
	},
}

function Item:Elligable(PlayerData: Types.PlayerData): boolean
	return PlayerData and PlayerData.Level() >= Item.Data.Level
end

function Item:Action(UUID: string)
	RemoteManager.SendServerEvent("EquipItem", UUID)
end

function Item:Use(Data: Types.PlayerData)
	if Data.ExtraStats[Item.Stat]() <= getCappedInfo[Item.Stat] then
		local newStat = math.min(Data.ExtraStats[Item.Stat] + Item.Amount, getCappedInfo[Item.Stat])
		Data.ExtraStats[Item.Stat](newStat)
	end
end

return Item
