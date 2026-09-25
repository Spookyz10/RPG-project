local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Remote = require(ReplicatedStorage.Shared.Utils.RemoteManager)
-- Forest crafting, drops, builds, and model requirements: Info/Forest-content.md.
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {["Attack"] = 4, ["Defense"] = 4, ["Health"] = 55, ["Speed"] = 0, ["Critical"] = 0, ["Critical Power"] = 0},
	Passive = "VerdantPact",
	Data = {
		ID = "Heart of the Grove", Name = "Heart of the Grove", ItemType = "Equipment", SubType = "Necklace",
		Level = 25, Rarity = "Epic", Stackable = false, SellsFor = 180,
		ActionName = "Equip", Description = "Verdant Pact: every fifth damaging hit restores 6% of your maximum Health; deal 10% more damage while at or below half Health.",
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
