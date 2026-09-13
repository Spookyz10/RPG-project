local Root = script.Parent.Parent
local Controller = require(Root.Controller)
local Attacks = Root.Attacks
local Definition = {
 Config = require(game:GetService("ReplicatedStorage").Shared.MobCombatConfig)["Dire Bear"],
 Basic = { Name = "Basic", Execute = require(Attacks.Melee) },
 Skills = {
  { Name = "Jump", Execute = require(Attacks.Jump), Cooldown = 12, Range = 45 },
  { Name = "Roar", Execute = require(Attacks.Roar), Cooldown = 10, Range = 24 },
  { Name = "Stomp", Execute = require(Attacks.GroundSlam), Cooldown = 7, Range = 24 },
  { Name = "Cavefall", Execute = require(Attacks.Cavefall), Cooldown = 14, Range = 35 },
 },
}
function Definition:Start(mob) Controller:Start(mob, self) end
return Definition
