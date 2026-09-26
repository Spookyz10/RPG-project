local Root = script.Parent.Parent
local Controller = require(Root.Controller)
local Attacks = Root.Attacks
local Definition = {
	Config = require(game:GetService("ReplicatedStorage").Shared.MobCombatConfig).Elderbark,
	Basic = { Name = "Basic", Execute = require(Attacks.Melee), Windup = 0.6, Multiplier = 1.1 },
	Skills = {
		{ Name = "HeartSlam", Execute = require(Attacks.ForestBurst), Radius = 21, Windup = 1.05,
			Multiplier = 1.55, Knockback = 28, Effect = "HeartSlam", EchoEffect = "HeartEcho",
			Pulses = 2, PulseGap = 0.65, RepeatDamage = true, Cooldown = 12, Range = 29 },
		{ Name = "MarkedRoots", Execute = require(Attacks.MarkedRoots), Cooldown = 12, Range = 80,
			Waves = 3, Windup = 0.85, Radius = 8, Multiplier = 1.3 },
		{ Name = "RootSweep", Execute = require(Attacks.Melee), Size = Vector3.new(32, 18, 27),
			Windup = 0.7, Count = 2, Multiplier = 1.35, Effect = "RootSweep", Cooldown = 11, Range = 30 },
		{ Name = "ThornFan", Execute = require(Attacks.ElderPatterns), Pattern = "Fan",
			Windup = 0.85, Multiplier = 1.5, Cooldown = 13, Range = 80 },
		{ Name = "GroveRupture", Execute = require(Attacks.ElderPatterns), Pattern = "Rupture",
			Windup = 0.95, Multiplier = 1.45, Cooldown = 16, Range = 80 },
		{ Name = "RootCascade", Execute = require(Attacks.ElderPatterns), Pattern = "Cascade",
			Windup = 0.75, Multiplier = 1.4, Cooldown = 14, Range = 80 },
	},
}
function Definition:Start(mob)
	Controller:Start(mob, self)
end
return Definition
