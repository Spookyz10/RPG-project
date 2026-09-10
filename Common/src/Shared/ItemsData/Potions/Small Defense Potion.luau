local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local getCappedInfo = require(ReplicatedStorage.Shared.getCappedInfo)
local Item = {
	Kind = "Consumable" :: "Consumable",
	Amount = 1,
	Stat = "Defense" :: "Defense",
	Data = {
		SellsFor = 10,
		ItemType = "Consumable",
		SubType = "Potion",
		Name = script.Name,
		Stackable = true,
		Cap = 25,
		Icon = "rbxassetid://115748822332547",
		Rarity = "Common",
		Level = 1,
		Description = "Drink this to gain +1 Defense",
		ActionName = "Use",
		ID = "Small Defense Potion",
	},
}

function Item:Elligable(PlayerData: Types.PlayerDataValue): boolean
	return PlayerData and PlayerData.Level() >= Item.Data.Level
end

function Item:Action(UUID: string)
	RemoteManager.SendServerEvent("EquipItem", UUID)
end

function Item:Use(Data: Types.PlayerDataValue)
	if Data.ExtraStats[Item.Stat]() <= getCappedInfo[Item.Stat] then
		local newStat = math.min(Data.ExtraStats[Item.Stat]() + Item.Amount, getCappedInfo[Item.Stat])
		Data.ExtraStats[Item.Stat](newStat)
	end
end

local TypedItem: Types.Consumable = Item
return TypedItem
