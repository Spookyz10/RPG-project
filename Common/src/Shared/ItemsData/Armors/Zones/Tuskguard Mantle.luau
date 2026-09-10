local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)
local Remote = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)
local Item = {
	Kind = "Equipment" :: "Equipment",
	Stats = {
		["Attack"] = 0,
		["Defense"] = 5,
		["Health"] = 35,
		["Speed"] = 0,
		["Critical"] = 0,
		["Critical Power"] = 0,
	},
	Passive = "LastStand",
	Data = {
		ID = "Tuskguard Mantle",
		Name = "Tuskguard Mantle",
		ItemType = "Equipment",
		SubType = "Armor",
		Level = 7,
		Rarity = "Rare",
		Stackable = false,
		SellsFor = 35,
		Icon = "rbxassetid://123995209972282",
		ActionName = "Equip",
		Description = "Last Stand: take 25% less hit damage while at or below 35% health.",
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
