local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Remote = require(ReplicatedStorage.Shared.Utils.RemoteManager)
-- Forest crafting, drops, builds, and model requirements: Info/Forest-content.md.
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {["Attack"] = 27, ["Defense"] = 2, ["Health"] = 20, ["Speed"] = 0, ["Critical"] = 0, ["Critical Power"] = 15},
	Passive = "DeepRoots",
	WeaponType = "Solo",
	Data = {
		ID = "Heartwood Cleaver", Name = "Heartwood Cleaver", ItemType = "Equipment", SubType = "Weapon",
		Level = 25, Rarity = "Epic", Stackable = false, SellsFor = 190,
		ActionName = "Equip", Description = "Deep Roots: every fifth damaging hit deals 35% more damage and restores 5% of your maximum Health.",
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
 