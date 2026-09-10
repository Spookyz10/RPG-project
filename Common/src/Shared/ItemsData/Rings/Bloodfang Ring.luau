local Remote = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)
local Item = {
	Kind = "Equipment",
	Stats = {
		["Attack"] = 0,
		["Defense"] = 0,
		["Health"] = 0,
		["Speed"] = 0,
		["Critical"] = 6,
		["Critical Power"] = 20,
	},
	Passive = "Predator",
	Data = {
		ID = "Bloodfang Ring",
		Name = "Bloodfang Ring",
		ItemType = "Equipment",
		SubType = "Ring",
		Level = 10,
		Rarity = "Rare",
		Stackable = false,
		SellsFor = 50,
		Icon = "rbxassetid://123995209972282",
		ActionName = "Equip",
		Description = "Predator: critical hits heal you for 8% of damage dealt.",
	},
}
function Item:Elligable(data)
	return data and data.Level() >= self.Data.Level
end
function Item:Action(uuid)
	Remote.SendServerEvent("EquipItem", uuid)
end
return Item
