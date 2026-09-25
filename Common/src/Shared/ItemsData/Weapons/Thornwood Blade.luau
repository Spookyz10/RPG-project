local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Remote = require(ReplicatedStorage.Shared.Utils.RemoteManager)
-- Forest crafting, drops, builds, and model requirements: Info/Forest-content.md.
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {["Attack"] = 20, ["Defense"] = 0, ["Health"] = 0, ["Speed"] = 1, ["Critical"] = 3, ["Critical Power"] = 10},
	Passive = "ThornTempo",
	WeaponType = "Solo",
	Data = {
		ID = "Thornwood Blade", Name = "Thornwood Blade", ItemType = "Equipment", SubType = "Weapon",
		Level = 19, Rarity = "Rare", Stackable = false, SellsFor = 110,
		ActionName = "Equip", Description = "Thorn Tempo: every third damaging hit deals 30% more damage.",
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
