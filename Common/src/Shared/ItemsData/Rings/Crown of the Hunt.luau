local Remote = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)
local Item = {
 Kind = "Equipment",
 Stats = {["Attack"] = 6, ["Defense"] = 0, ["Health"] = 0, ["Speed"] = 0, ["Critical"] = 8, ["Critical Power"] = 35},
 Passive = "Executioner",
 Data = { ID = "Crown of the Hunt", Name = "Crown of the Hunt", ItemType = "Equipment", SubType = "Ring", Level = 15, Rarity = "Epic", Stackable = false, SellsFor = 75, Icon = "rbxassetid://123995209972282", ActionName = "Equip", Description = "Executioner: deal 25% more damage against targets at or below 30% health." },
}
function Item:Elligable(data) return data and data.Level() >= self.Data.Level end
function Item:Action(uuid) Remote.SendServerEvent("EquipItem", uuid) end
return Item
