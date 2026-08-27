local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local Hitbox = require(ServerStorage.Modules.Hitbox)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Behavior = {} :: Types.SkillBehavior

function Behavior:Execute(caster: Player, definition: Types.SkillDefinition)
	local Character = caster.Character
	if not Character then
		return
	end

	if not Functions:isEntityAlive(Character) then
		return
	end

	RemoteManager.SendClientEvent("SkillVFX", { All = true }, "Cyclone", Character)
	RemoteManager.SendClientEvent("SkillAnimation", { All = true }, Character, "Cyclone", 0.1)

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

return Behavior
