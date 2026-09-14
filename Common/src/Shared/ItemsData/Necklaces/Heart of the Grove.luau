local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Remote = require(ReplicatedStorage.Shared.Utils.RemoteManager)
-- Crafting/drop sources and future passive proposals: Info/Forest.md.
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {["Attack"] = 3, ["Defense"] = 3, ["Health"] = 45, ["Speed"] = 0, ["Critical"] = 0, ["Critical Power"] = 0},
	Passive = "",
	Data = {
		ID = "Heart of the Grove", Name = "Heart of the Grove", ItemType = "Equipment", SubType = "Necklace",
		Level = 25, Rarity = "Epic", Stackable = false, SellsFor = 180,
		ActionName = "Equip", Description = "A fragment of Elderbark, still warm beneath its wooden shell.",
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
