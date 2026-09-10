local Remote = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)
local Item = {
 Kind = "Equipment",
 Stats = {["Attack"] = 0, ["Defense"] = 1, ["Health"] = 20, ["Speed"] = 0, ["Critical"] = 0, ["Critical Power"] = 0},
 Passive = "Regrowth",
 Data = { ID = "Bloom Pendant", Name = "Bloom Pendant", ItemType = "Equipment", SubType = "Necklace", Level = 4, Rarity = "Rare", Stackable = false, SellsFor = 20, Icon = "rbxassetid://123995209972282", ActionName = "Equip", Description = "Regrowth: every fifth damaging hit restores 4% of your maximum health." },
}
function Item:Elligable(data) return data and data.Level() >= self.Data.Level end
function Item:Action(uuid) Remote.SendServerEvent("EquipItem", uuid) end
return Item
