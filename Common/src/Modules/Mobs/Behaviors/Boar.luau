local Root = script.Parent.Parent
local Controller = require(Root.Controller)
local Attacks = Root.Attacks
local Definition = {
 Config = require(game:GetService("ReplicatedStorage").Shared.MobCombatConfig)["Boar"],
 Basic = { Name = "Basic", Execute = require(Attacks.Melee) },
 Skills = { { Name = "Rush", Execute = require(Attacks.Rush) } },
}
function Definition:Start(mob) Controller:Start(mob, self) end
return Definition
