local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local BuffsManager = require(ServerStorage.Modules.BuffsManager)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Behavior = {} :: Types.SkillBehavior

local EFFECT_ID = "Safeguard"
local BASE_REDUCTION = 0.3
local BASE_DURATION = 5

function Behavior:Execute(caster: Player, definition: Types.SkillDefinition)
	local Character = caster.Character
	if not Character then
		return
	end

	if not Functions:isEntityAlive(Character) then
		return
	end

	RemoteManager.SendClientEvent("SkillAnimation", { All = true }, Character, "Safeguard", 0.1)
	RemoteManager.SendClientEvent("BuffVFX", { All = true }, EFFECT_ID, Character, "Start", BASE_DURATION)

	BuffsManager:Apply(Character, EFFECT_ID, {
		Property = "IncomingDamage",
		Operation = "Multiply",
		Value = BASE_REDUCTION,
		Duration = BASE_DURATION,
		Source = caster,
	})

	task.delay(BASE_DURATION, function()
		RemoteManager.SendClientEvent("BuffVFX", { All = true }, EFFECT_ID, Character, "End")
	end)
end

return Behavior
