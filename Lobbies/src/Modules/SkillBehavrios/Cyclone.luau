local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local Hitbox = require(ServerStorage.Modules.Hitbox)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Behavior = {} :: Types.SkillBehavior

function Behavior:Execute(caster: Player, definition: Types.SkillDefinition)
	local Character = caster.Character
	if not Character then
		return
	end

	if Functions:isEntityAlive(Character) then
		Hitbox:Create({
			Size = Vector3.new(10, 10, 10),
			Part = Character.PrimaryPart,
			Drag = true,
			Offset = nil,
			Time = 0.3,
			Caster = Character,
			OnHit = function(_, HitEntity)
				DamageHandler:dealDamage(Character, HitEntity, definition.Multiplier)
			end,
		})
	end
end

return Behavior
