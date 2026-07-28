local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local Hitbox = require(ServerStorage.Modules.Hitbox)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local SharedSkills = require(ReplicatedStorage.Shared.Skills)

local Skill = SharedSkills["Consecutive Slashes"] :: Types.Skill

function Skill:Activate(class: Types.Entity)
	for _ = 1, 10 do
		local Character = class.Model
		RemoteManager.SendClientEvent("SkillVFX", { All = true }, "Consecutive Slashes", Character)
		if Character and Functions:isEntityAlive(class) then
			Hitbox:Create({
				Size = Vector3.new(20, 20, 20),
				Part = Character.PrimaryPart,
				Drag = true,
				Offset = Vector3.new(0, 0, -3),
				Time = 0.3,
				Caster = Character,
				OnHit = function(_, HitEntity)
					DamageHandler:dealDamage(class, HitEntity, self.Multiplier)
				end,
			})
		end
	end
end

return Skill
