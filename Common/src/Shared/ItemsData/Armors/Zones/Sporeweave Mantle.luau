local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Remote = require(ReplicatedStorage.Shared.Utils.RemoteManager)
-- Crafting/drop sources and future passive proposals: Info/Forest.md.
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {["Attack"] = 0, ["Defense"] = 6, ["Health"] = 30, ["Speed"] = 0, ["Critical"] = 0, ["Critical Power"] = 0},
	Passive = "",
	Data = {
		ID = "Sporeweave Mantle", Name = "Sporeweave Mantle", ItemType = "Equipment", SubType = "Armor",
		Level = 16, Rarity = "Rare", Stackable = false, SellsFor = 95,
		ActionName = "Equip", Description = "A breathable mantle woven from resilient spore silk.",
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
