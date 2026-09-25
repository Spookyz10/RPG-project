local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Remote = require(ReplicatedStorage.Shared.Utils.RemoteManager)
-- Forest crafting, drops, builds, and model requirements: Info/Forest-content.md.
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {["Attack"] = 3, ["Defense"] = 0, ["Health"] = 0, ["Speed"] = 0, ["Critical"] = 5, ["Critical Power"] = 10},
	Passive = "BriarReprisal",
	Data = {
		ID = "Bramble Loop", Name = "Bramble Loop", ItemType = "Equipment", SubType = "Ring",
		Level = 19, Rarity = "Rare", Stackable = false, SellsFor = 100,
		ActionName = "Equip", Description = "Briar Reprisal: taking damage primes your next damaging hit to deal 25% more damage.",
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
