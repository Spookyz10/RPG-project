local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local AnimationHandler = require(ReplicatedStorage.Shared.AnimationHandler)
local Data = require(ReplicatedStorage.Shared.Data).server
local BuffsManager = require(ServerStorage.Modules.BuffsManager)
local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local Hitbox = require(ServerStorage.Modules.Hitbox)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Behavior = {} :: Types.SkillBehavior

local EFFECT_ID = "Lure Jab"
local BASE_DEFENSE_MULTIPLIER = 0.5
local BASE_DURATION = 5

function Behavior:Execute(caster: Player, definition: Types.SkillDefinition): AnimationTrack?
	local Character = caster.Character
	if not Character then
		return nil
	end

	if not Functions:isEntityAlive(Character) then
		return nil
	end

	local PlayerData = Data.Service:waitForData(caster) :: Types.PlayerData
	local RuneInfo = PlayerData and Functions:GetEquippedItemInfo(PlayerData, "Rune")
	local Override = RuneInfo and RuneInfo.EffectOverrides and RuneInfo.EffectOverrides[EFFECT_ID]

	local DefenseMultiplier = (Override and Override.Value) or BASE_DEFENSE_MULTIPLIER
	local HealPercent = Override and Override.HealPercent

	RemoteManager.SendClientEvent("SkillVFX", { All = true }, "Lure Jab", Character)

	local Handler = AnimationHandler.GetOrCreate(Character)
	local Track = Handler:Play("Lure Jab", 0.1)

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
				Property = "Defense",
				Operation = "Multiply",
				Value = DefenseMultiplier,
				Duration = BASE_DURATION,
				Source = caster,
			})

			RemoteManager.SendClientEvent("BuffVFX", { All = true }, EFFECT_ID, HitEntity, "Start", BASE_DURATION)

			task.delay(BASE_DURATION, function()
				RemoteManager.SendClientEvent("BuffVFX", { All = true }, EFFECT_ID, HitEntity, "End")
			end)

			if HealPercent then
				local Humanoid = Character:FindFirstChildOfClass("Humanoid")
				if Humanoid then
					DamageHandler:heal(Character, Character, Humanoid.MaxHealth * HealPercent)
				end
			end
		end,
	})

	return Track
end

return Behavior
