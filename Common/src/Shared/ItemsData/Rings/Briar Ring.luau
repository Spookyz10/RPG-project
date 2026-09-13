local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)
local Remote = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {
		["Attack"] = 2,
		["Defense"] = 0,
		["Health"] = 0,
		["Speed"] = 0,
		["Critical"] = 0,
		["Critical Power"] = 10,
	},
	Passive = "Venom",
	Data = {
		ID = "Briar Ring",
		Name = "Briar Ring",
		ItemType = "Equipment",
		SubType = "Ring",
		Level = 3,
		Rarity = "Rare",
		Stackable = false,
		SellsFor = 15,
		ActionName = "Equip",
		Description = "Venom: damaging hits mark enemies for 6s. Your attacks deal 15% more damage to enemies marked by you.",
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
