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
	local Character = class.Model

	if Character and Functions:isEntityAlive(class) then
		Hitbox:Create({
			Size = Vector3.new(6, 7, 15),
			Part = Character.PrimaryPart,
			Drag = false,
			Offset = Vector3.new(0, 0, -3),
			Time = 0.3,
			Caster = Character,
			OnHit = function(hitModel, HitEntity)
				RemoteManager.SendClientEvent(
					"SkillVFX",
					{ All = true },
					"Consecutive Slashes",
					hitModel.PrimaryPart.Position
				)
				for _ = 1, 5 do
					DamageHandler:dealDamage(class, HitEntity, self.Multiplier)
				end
			end,
		})

		Character:PivotTo(Character:GetPivot() * CFrame.new(0, 0, -15))
	end
end

return Skill
