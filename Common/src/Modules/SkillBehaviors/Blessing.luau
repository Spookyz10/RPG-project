local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Behavior = {} :: Types.SkillBehavior

local HEAL_PERCENT = 0.25
local HEAL_RADIUS = 20

function Behavior:Execute(caster: Player, definition: Types.SkillDefinition): AnimationTrack?
	local Character = caster.Character
	if not Character then
		return nil
	end

	if not Functions:isEntityAlive(Character) then
		return nil
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local casterRoot = Character:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not casterRoot then
		return nil
	end

	RemoteManager.SendClientEvent("SkillVFX", { All = true }, "Blessing", Character)

	for _, player in game:GetService("Players"):GetPlayers() do
		local target = player.Character
		local root = target and target:FindFirstChild("HumanoidRootPart")
		local targetHumanoid = target and target:FindFirstChildOfClass("Humanoid")
		if root and targetHumanoid and targetHumanoid.Health > 0
			and (root.Position - casterRoot.Position).Magnitude <= HEAL_RADIUS then
			DamageHandler:heal(Character, target, targetHumanoid.MaxHealth * HEAL_PERCENT)
		end
	end

	return nil
end

return Behavior
