local Root = script.Parent.Parent
local Controller = require(Root.Controller)
local Attacks = Root.Attacks
local Definition = {
	Config = require(game:GetService("ReplicatedStorage").Shared.MobCombatConfig)["Thornback Stag"],
	Basic = { Name = "Basic", Execute = require(Attacks.Melee), Windup = 0.65 },
	Skills = {
		{ Name = "AntlerRush", Execute = require(Attacks.AntlerRush), Cooldown = 10, Range = 30 },
	},
}
function Definition:Start(mob)
	Controller:Start(mob, self)
end
return Definition
