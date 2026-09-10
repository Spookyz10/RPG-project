local Root = script.Parent.Parent
local Controller = require(Root.Controller)
local Attacks = Root.Attacks
local Definition = {
 Config = require(game:GetService("ReplicatedStorage").Shared.MobCombatConfig)["Wolf"],
 Basic = { Name = "Basic", Execute = require(Attacks.Melee) },
 Skills = { { Name = "TailSpin", Execute = require(Attacks.TailSpin), FreeRotation = true } },
}
function Definition:Start(mob) Controller:Start(mob, self) end
return Definition
