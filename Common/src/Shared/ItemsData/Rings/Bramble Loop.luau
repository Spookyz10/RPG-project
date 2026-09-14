local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Remote = require(ReplicatedStorage.Shared.Utils.RemoteManager)
-- Crafting/drop sources and future passive proposals: Info/Forest.md.
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {["Attack"] = 3, ["Defense"] = 0, ["Health"] = 0, ["Speed"] = 0, ["Critical"] = 5, ["Critical Power"] = 10},
	Passive = "",
	Data = {
		ID = "Bramble Loop", Name = "Bramble Loop", ItemType = "Equipment", SubType = "Ring",
		Level = 19, Rarity = "Rare", Stackable = false, SellsFor = 100,
		ActionName = "Equip", Description = "A thorn ring worn by hunters of the deep forest.",
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
