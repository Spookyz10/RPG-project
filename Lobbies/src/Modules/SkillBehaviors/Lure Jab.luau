local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local BuffsManager = require(ServerStorage.Modules.BuffsManager)
local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local Hitbox = require(ServerStorage.Modules.Hitbox)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Behavior = {} :: Types.SkillBehavior

local EFFECT_ID = "LureJab"
local BASE_VALUE = 1.5
local BASE_DURATION = 5

function Behavior:Execute(caster: Player, definition: Types.SkillDefinition)
	local Character = caster.Character
	if not Character then
		return
	end

	if not Functions:isEntityAlive(Character) then
		return
	end

	local PlayerData = Data.Service:waitForData(caster) :: Types.PlayerData
	local RuneInfo = PlayerData and Functions:GetEquippedItemInfo(PlayerData, "Rune")
	local Override = RuneInfo and RuneInfo.EffectOverrides and RuneInfo.EffectOverrides[EFFECT_ID]

	local EffectValue = (Override and Override.Value) or BASE_VALUE
	local HealPercent = Override and Override.HealPercent

	Hitbox:Create({
		Size = Vector3.new(10, 10, 10),
		Part = Character.PrimaryPart,
		Drag = true,
		Offset = nil,
		Time = 0.3,
		Caster = Character,
		OnHit = function(_, HitEntity)
			DamageHandler:dealDamage(Character, HitEntity, definition.Multiplier)

			BuffsManager:Apply(HitEntity, EFFECT_ID, {
				Property = "IncomingDamage",
				Operation = "Multiply",
				Value = EffectValue,
				Duration = BASE_DURATION,
				Source = caster,
			})

			if HealPercent then
				local Humanoid = Character:FindFirstChildOfClass("Humanoid")
				if Humanoid then
					DamageHandler:heal(Character, Character, Humanoid.MaxHealth * HealPercent)
				end
			end
		end,
	})
end

return Behavior
