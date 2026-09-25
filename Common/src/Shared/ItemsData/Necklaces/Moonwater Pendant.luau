local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Remote = require(ReplicatedStorage.Shared.Utils.RemoteManager)
-- Forest crafting, drops, builds, and model requirements: Info/Forest-content.md.
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {["Attack"] = 0, ["Defense"] = 2, ["Health"] = 30, ["Speed"] = 2, ["Critical"] = 4, ["Critical Power"] = 15},
	Passive = "MoonlitCadence",
	Data = {
		ID = "Moonwater Pendant", Name = "Moonwater Pendant", ItemType = "Equipment", SubType = "Necklace",
		Level = 21, Rarity = "Rare", Stackable = false, SellsFor = 115,
		ActionName = "Equip", Description = "Moonlit Cadence: every fourth damaging hit is a guaranteed critical hit with +50% Critical Power.",
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
