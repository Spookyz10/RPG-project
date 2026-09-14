local Root = script.Parent.Parent
local Controller = require(Root.Controller)
local Attacks = Root.Attacks
local Definition = {
	Config = require(game:GetService("ReplicatedStorage").Shared.MobCombatConfig)["Hollow Sentinel"],
	Basic = { Name = "Basic", Execute = require(Attacks.Melee), Windup = 0.65 },
	Skills = {
		{ Name = "RootLanes", Execute = require(Attacks.RootLanes), Cooldown = 11, Range = 28 },
	},
}
function Definition:Start(mob)
	Controller:Start(mob, self)
end
return Definition
