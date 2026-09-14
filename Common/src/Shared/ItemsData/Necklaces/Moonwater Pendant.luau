local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Remote = require(ReplicatedStorage.Shared.Utils.RemoteManager)
-- Crafting/drop sources and future passive proposals: Info/Forest.md.
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {["Attack"] = 0, ["Defense"] = 2, ["Health"] = 30, ["Speed"] = 1, ["Critical"] = 0, ["Critical Power"] = 0},
	Passive = "",
	Data = {
		ID = "Moonwater Pendant", Name = "Moonwater Pendant", ItemType = "Equipment", SubType = "Necklace",
		Level = 21, Rarity = "Rare", Stackable = false, SellsFor = 115,
		ActionName = "Equip", Description = "A polished stone holding the colors of Moonwater Crossing.",
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
