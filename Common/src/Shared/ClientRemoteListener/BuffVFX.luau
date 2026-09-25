local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuffEffects = require(ReplicatedStorage.Shared.BuffEffects)
local CombatVFX = require(ReplicatedStorage.Shared.CombatVFX)
local Logic = require(ReplicatedStorage.Shared.UI.Logic)
local StatusDefinitions = require(ReplicatedStorage.Shared.StatusEffects)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local UIFeedback = require(ReplicatedStorage.Shared.UI.UIFeedback)

local Remote = {}
local worldEffects = {}
local localStacks: { [string]: number } = {}

for _, effectId in CombatVFX.StatusNames do
	worldEffects[effectId] = true
end

local function updateWorldEffect(effectId: string, entity: Model, action: string, duration: number?)
	local legacy = BuffEffects[effectId]
	if legacy then
		if action == "Start" or action == "Update" then
			legacy.Apply(entity, duration)
		elseif action == "End" then
			legacy.Stop(entity)
		end
		return
	end
	if worldEffects[effectId] then
		if action == "Start" or action == "Update" then
			CombatVFX:Status(entity, effectId, duration)
		elseif action == "End" then
			CombatVFX:StopStatus(entity, effectId)
		end
		return
	end
end

function Remote:Activate(effectId: string, entity: Model, action: string, duration: number?, stacks: number?)
	updateWorldEffect(effectId, entity, action, duration)
	if entity ~= UIConstants.Character then return end
	local buffs = Logic.Buffs
	if action == "Start" or action == "Update" then
		buffs:Start(effectId, duration, stacks)
		local previousStacks = localStacks[effectId] or 0
		local currentStacks = typeof(stacks) == "number" and stacks or previousStacks
		if effectId == "Fury" and currentStacks > previousStacks then
			UIFeedback.Status(effectId, (StatusDefinitions[effectId] or {}).Category, UIFeedback.Messages.FuryChargeGained)
		elseif action == "Start" then
			UIFeedback.Status(effectId, (StatusDefinitions[effectId] or {}).Category)
		end
		localStacks[effectId] = currentStacks
	elseif action == "End" then
		buffs:Stop(effectId)
		localStacks[effectId] = nil
	end
end

return Remote
