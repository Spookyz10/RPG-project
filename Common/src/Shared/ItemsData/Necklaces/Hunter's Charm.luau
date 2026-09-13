local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)
local Remote = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = { ["Attack"] = 3, ["Defense"] = 0, ["Health"] = 0, ["Speed"] = 0, ["Critical"] = 3, ["Critical Power"] = 0 },
	Passive = "VenomHunter",
	Data = {
		ID = "Hunter's Charm",
		Name = "Hunter's Charm",
		ItemType = "Equipment",
		SubType = "Necklace",
		Level = 6,
		Rarity = "Rare",
		Stackable = false,
		SellsFor = 40,
		ActionName = "Equip",
		Description = "Hunter: deal 20% more damage to enemies above 70% health.",
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
