local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Remote = require(ReplicatedStorage.Shared.Utils.RemoteManager)
-- Crafting/drop sources and future passive proposals: Info/Forest.md.
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {["Attack"] = 18, ["Defense"] = 0, ["Health"] = 0, ["Speed"] = 0, ["Critical"] = 0, ["Critical Power"] = 0},
	Passive = "",
	WeaponType = "Solo",
	Data = {
		ID = "Thornwood Blade", Name = "Thornwood Blade", ItemType = "Equipment", SubType = "Weapon",
		Level = 18, Rarity = "Rare", Stackable = false, SellsFor = 110,
		ActionName = "Equip", Description = "A light blade carved from interlocking forest thorns.",
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
