local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)
local Remote = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {
		["Attack"] = 0,
		["Defense"] = 1,
		["Health"] = 15,
		["Speed"] = 0,
		["Critical"] = 0,
		["Critical Power"] = 0,
	},
	Passive = "Regrowth",
	Data = {
		ID = "Bloom Pendant",
		Name = "Bloom Pendant",
		ItemType = "Equipment",
		SubType = "Necklace",
		Level = 3,
		Rarity = "Rare",
		Stackable = false,
		SellsFor = 20,
		Icon = "rbxassetid://78384343333611",
		ActionName = "Equip",
		Description = "Regrowth: every fifth damaging hit restores 4% of your maximum health.",
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
