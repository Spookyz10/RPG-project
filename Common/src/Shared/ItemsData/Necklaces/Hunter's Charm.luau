local Remote = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)
local Item = {
 Kind = "Equipment",
 Stats = {["Attack"] = 4, ["Defense"] = 0, ["Health"] = 0, ["Speed"] = 0, ["Critical"] = 5, ["Critical Power"] = 0},
 Passive = "VenomHunter",
 Data = { ID = "Hunter's Charm", Name = "Hunter's Charm", ItemType = "Equipment", SubType = "Necklace", Level = 8, Rarity = "Rare", Stackable = false, SellsFor = 40, Icon = "rbxassetid://123995209972282", ActionName = "Equip", Description = "Venom Hunter: deal 20% more damage to enemies marked by Venom." },
}
function Item:Elligable(data) return data and data.Level() >= self.Data.Level end
function Item:Action(uuid) Remote.SendServerEvent("EquipItem", uuid) end
return Item
