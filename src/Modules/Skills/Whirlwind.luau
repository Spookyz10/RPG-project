local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ClientRemotes = require(ServerStorage.Modules.ClientRemotes)
local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local Hitbox = require(ServerStorage.Modules.Hitbox)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Skill: Types.Skill = {
	Name = "Whirlwind",
	Cooldown = 5,
	Multiplier = 10,
}

function Skill:Activate(class: Types.Entity)
	local Character = class.Model
	ClientRemotes.SendClientEvent("SkillVFX", { All = true }, { Model = Character })
	if Character and Functions:isEntityAlive(class) then
		Hitbox:Create({
			Size = Vector3.new(10, 10, 10),
			Part = Character.PrimaryPart,
			Drag = true,
			Offset = nil,
			Time = 0.3,
			OnHit = function(_, HitEntity)
				DamageHandler:dealDamage(class, HitEntity, self.Multiplier)
			end,
		})
	end
end

return Skill
