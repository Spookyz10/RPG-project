local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)
local Remote = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {
		["Attack"] = 0,
		["Defense"] = 0,
		["Health"] = 0,
		["Speed"] = 0,
		["Critical"] = 5,
		["Critical Power"] = 15,
	},
	Passive = "Predator",
	Data = {
		ID = "Bloodfang Ring",
		Name = "Bloodfang Ring",
		ItemType = "Equipment",
		SubType = "Ring",
		Level = 8,
		Rarity = "Rare",
		Stackable = false,
		SellsFor = 50,
		ActionName = "Equip",
		Description = "Predator: critical hits heal you for 8% of damage dealt.",
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
