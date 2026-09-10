local Remote = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)
local Item = {
 Kind = "Equipment",
 Stats = {["Attack"] = 0, ["Defense"] = 4, ["Health"] = 25, ["Speed"] = 0, ["Critical"] = 0, ["Critical Power"] = 0},
 Passive = "Bulwark",
 Data = { ID = "Ironhide Band", Name = "Ironhide Band", ItemType = "Equipment", SubType = "Ring", Level = 6, Rarity = "Rare", Stackable = false, SellsFor = 30, Icon = "rbxassetid://123995209972282", ActionName = "Equip", Description = "Bulwark: take 15% less hit damage while at or above 70% health." },
}
function Item:Elligable(data) return data and data.Level() >= self.Data.Level end
function Item:Action(uuid) Remote.SendServerEvent("EquipItem", uuid) end
return Item
