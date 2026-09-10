local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)

local Mob: Types.MobInfo = {
	Level = 1, MaxLevel = 15, XP = 50, RespawnTime = 8, GlobalDrops = false,
	Data = { Stats = { Attack = 5, Defense = 0, Critical = 0, Health = 45, Speed = 12 } },
	Currencies = { Gold = 5 },
	Drops = {
["Briar Ring"] = { Chance = 8, Amount = 1 },
["Bloom Pendant"] = { Chance = 6, Amount = 1 },
 ["Dark Ivy"] = { Chance = 35, Amount = 1 } },
}

return Mob
