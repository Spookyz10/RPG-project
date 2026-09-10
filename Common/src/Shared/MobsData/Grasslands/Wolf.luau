local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)

local Mob: Types.MobInfo = {
	Level = 8, MaxLevel = 15, XP = 160, RespawnTime = 12, GlobalDrops = false,
	Data = { Stats = { Attack = 16, Defense = 2, Critical = 0, Health = 180, Speed = 20 } },
	Currencies = { Gold = 20 },
	Drops = {
["Hunter's Charm"] = { Chance = 7, Amount = 1 },
["Bloodfang Ring"] = { Chance = 5, Amount = 1 },
 ["Wolf's Fang"] = { Chance = 50, Amount = 1 } },
}

return Mob
