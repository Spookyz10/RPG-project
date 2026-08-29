local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Behavior = {} :: Types.SkillBehavior

local HEAL_PERCENT = 0.25

function Behavior:Execute(caster: Player, definition: Types.SkillDefinition)
	local Character = caster.Character
	if not Character then
		return
	end

	if not Functions:isEntityAlive(Character) then
		return
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then
		return
	end

	RemoteManager.SendClientEvent("SkillVFX", { All = true }, "Blessing", Character)
	RemoteManager.SendClientEvent("SkillAnimation", { All = true }, Character, "Blessing", 0.1)

	DamageHandler:heal(Character, Character, Humanoid.MaxHealth * HEAL_PERCENT)
end

return Behavior
