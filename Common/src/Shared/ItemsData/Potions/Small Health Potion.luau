local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local getCappedInfo = require(ReplicatedStorage.Shared.getCappedInfo)
local Item = {
	Kind = "Consumable" :: "Consumable",
	Amount = 1,
	Stat = "Health" :: "Health",
	Data = {
		SellsFor = 10,
		ItemType = "Consumable",
		SubType = "Potion",
		Name = script.Name,
		Stackable = true,
		Cap = 25,
		Icon = "rbxassetid://99188339640927",
		Rarity = "Common",
		Level = 1,
		Description = "Gain +1 Health (up to the stat cap), fully restore your health, and remove all debuffs. Healing and cleansing still work at the stat cap.",
		ActionName = "Use",
		ID = "Small Health Potion",
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
