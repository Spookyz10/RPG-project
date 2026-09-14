local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Remote = require(ReplicatedStorage.Shared.Utils.RemoteManager)
-- Crafting/drop sources and future passive proposals: Info/Forest.md.
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {["Attack"] = 26, ["Defense"] = 0, ["Health"] = 0, ["Speed"] = 0, ["Critical"] = 0, ["Critical Power"] = 0},
	Passive = "",
	WeaponType = "Solo",
	Data = {
		ID = "Heartwood Cleaver", Name = "Heartwood Cleaver", ItemType = "Equipment", SubType = "Weapon",
		Level = 25, Rarity = "Epic", Stackable = false, SellsFor = 190,
		ActionName = "Equip", Description = "A heavy edge carved from the heart of the ancient grove.",
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
