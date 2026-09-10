local Remote = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)
local Item = {
 Kind = "Equipment",
 Stats = {["Attack"] = 2, ["Defense"] = 0, ["Health"] = 0, ["Speed"] = 0, ["Critical"] = 0, ["Critical Power"] = 10},
 Passive = "Venom",
 Data = { ID = "Briar Ring", Name = "Briar Ring", ItemType = "Equipment", SubType = "Ring", Level = 3, Rarity = "Rare", Stackable = false, SellsFor = 15, Icon = "rbxassetid://123995209972282", ActionName = "Equip", Description = "Venom: damaging hits mark enemies for 6s. Combine with Hunter's Charm for +20% damage against marked enemies." },
}
function Item:Elligable(data) return data and data.Level() >= self.Data.Level end
function Item:Action(uuid) Remote.SendServerEvent("EquipItem", uuid) end
return Item
