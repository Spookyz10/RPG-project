local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Remote = require(ReplicatedStorage.Shared.Utils.RemoteManager)
-- Crafting/drop sources and future passive proposals: Info/Forest.md.
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {
		["Attack"] = 222220,
		["Defense"] = 222229,
		["Health"] = 522225,
		["Speed"] = 63,
		["Critical"] = 110,
		["Critical Power"] = 1230,
	},
	Passive = "",
	Data = {
		ID = "Admin Armor",
		Name = script.Name,
		ItemType = "Equipment",
		SubType = "Armor",
		Level = 23,
		Rarity = "Epic",
		Stackable = false,
		SellsFor = 160,
		ActionName = "Equip",
		Description = "Layered bark armor engraved with dormant forest runes.",
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
