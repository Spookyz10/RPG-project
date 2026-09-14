local Root = script.Parent.Parent
local Controller = require(Root.Controller)
local Attacks = Root.Attacks
local Definition = {
	Config = require(game:GetService("ReplicatedStorage").Shared.MobCombatConfig)["Mosscap"],
	Basic = { Name = "Basic", Execute = require(Attacks.Melee), Windup = 0.65 },
	Skills = {
		{
			Name = "SporeBloom",
			Execute = require(Attacks.ForestBurst),
			Radius = 7,
			Pulses = 2,
			Windup = 1.2,
			Multiplier = 1.2,
			Effect = "SporeBloom",
			Cooldown = 9,
			Range = 14,
		},
	},
}
function Definition:Start(mob)
	Controller:Start(mob, self)
end
return Definition
