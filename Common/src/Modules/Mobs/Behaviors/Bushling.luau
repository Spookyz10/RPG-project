local Root = script.Parent.Parent
local Controller = require(Root.Controller)
local Attacks = Root.Attacks
local Definition = {
 Config = require(game:GetService("ReplicatedStorage").Shared.MobCombatConfig)["Bushling"],
 Basic = { Name = "Basic", Execute = require(Attacks.Melee), Status = "Poison" },
 Skills = { { Name = "Spikes", Execute = require(Attacks.Spikes) } },
}
function Definition:Start(mob) Controller:Start(mob, self) end
return Definition
