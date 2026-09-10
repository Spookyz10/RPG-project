local Root = script.Parent.Parent
local Controller = require(Root.Controller)
local Attacks = Root.Attacks
local Definition = {
 Config = require(game:GetService("ReplicatedStorage").Shared.MobCombatConfig)["Dire Bear"],
 Basic = { Name = "Basic", Execute = require(Attacks.Melee) },
 Skills = { { Name = "GroundSlam", Execute = require(Attacks.GroundSlam) }, { Name = "DoubleSwipe", Execute = require(Attacks.Melee), Size = Vector3.new(22, 14, 16), Count = 2, Multiplier = 1.2 }, { Name = "Roar", Execute = require(Attacks.Roar) } },
}
function Definition:Start(mob) Controller:Start(mob, self) end
return Definition
