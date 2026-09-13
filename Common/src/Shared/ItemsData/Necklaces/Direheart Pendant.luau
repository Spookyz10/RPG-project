local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)
local Remote = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {
		["Attack"] = 5,
		["Defense"] = 0,
		["Health"] = 50,
		["Speed"] = 0,
		["Critical"] = 0,
		["Critical Power"] = 20,
	},
	Passive = "Berserker",
	Data = {
		ID = "Direheart Pendant",
		Name = "Direheart Pendant",
		ItemType = "Equipment",
		SubType = "Necklace",
		Level = 15,
		Rarity = "Epic",
		Stackable = false,
		SellsFor = 75,
		Icon = "rbxassetid://131853418522302",
		ActionName = "Equip",
		Description = "Berserker: deal 25% more damage while at or below 40% health.",
	},
}
function Item:Elligable(data: Types.PlayerDataValue): boolean
	return data and data.Level() >= self.Data.Level
end
function Item:Action(uuid: string)
	Remote.SendServerEvent("EquipItem", uuid)
end
local TypedItem: Types.Equipment = Item
return TypedItem
