local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DamageHandler = require(script.Parent.DamageHandler)
local Hitbox = require(script.Parent.Hitbox)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local AttackManager = {}

function AttackManager:Swing(class: Types.EntityLike)
	if Functions:isEntityAlive(class) then
		local PrimaryPart = class.Model.PrimaryPart
		if PrimaryPart then
			Hitbox:Create({
				Size = Vector3.new(5, 5, 5),
				Position = PrimaryPart.CFrame,
				Time = 0.5,
				Drag = true,
				OnHit = function(_, HitEntity)
					DamageHandler:dealDamage(10, HitEntity)
				end,
			})
		end
	end
end

return AttackManager
