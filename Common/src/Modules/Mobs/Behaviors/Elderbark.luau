local Root = script.Parent.Parent
local Controller = require(Root.Controller)
local Attacks = Root.Attacks
local Definition = {
	Config = require(game:GetService("ReplicatedStorage").Shared.MobCombatConfig)["Elderbark"],
	Basic = { Name = "Basic", Execute = require(Attacks.Melee), Windup = 0.85 },
	Skills = {
		{
			Name = "HeartSlam",
			Execute = require(Attacks.ForestBurst),
			Radius = 18,
			Windup = 1.5,
			Multiplier = 1.5,
			Knockback = 35,
			Effect = "HeartSlam",
			Cooldown = 14,
			Range = 24,
		},
		{ Name = "MarkedRoots", Execute = require(Attacks.MarkedRoots), Cooldown = 16, Range = 55 },
		{
			Name = "RootSweep",
			Execute = require(Attacks.Melee),
			Size = Vector3.new(26, 18, 20),
			Windup = 1.2,
			Multiplier = 1.4,
			Effect = "RootSweep",
			Cooldown = 13,
			Range = 20,
		},
	},
}
function Definition:Start(mob)
	Controller:Start(mob, self)
end
return Definition
