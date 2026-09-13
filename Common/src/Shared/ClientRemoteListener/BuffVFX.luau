local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuffEffects = require(ReplicatedStorage.Shared.BuffEffects)
local CombatVFX = require(ReplicatedStorage.Shared.CombatVFX)
local Logic = require(ReplicatedStorage.Shared.UI.Logic)
local StatusDefinitions = require(ReplicatedStorage.Shared.StatusEffects)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local UIFeedback = require(ReplicatedStorage.Shared.UI.UIFeedback)

local Remote = {}
local worldEffects = {}

for _, effectId in CombatVFX.StatusNames do
	worldEffects[effectId] = true
end

local function updateWorldEffect(effectId: string, entity: Model, action: string, duration: number?)
	if worldEffects[effectId] then
		if action == "Start" or action == "Update" then
			CombatVFX:Status(entity, effectId, duration)
		elseif action == "End" then
			CombatVFX:StopStatus(entity, effectId)
		end
		return
	end
	local legacy = BuffEffects[effectId]
	if not legacy then return end
	if action == "Start" or action == "Update" then
		legacy.Apply(entity)
	elseif action == "End" then
		legacy.Stop(entity)
	end
end

function Remote:Activate(effectId: string, entity: Model, action: string, duration: number?, stacks: number?)
	updateWorldEffect(effectId, entity, action, duration)
	if entity ~= UIConstants.Character then return end
	local buffs = Logic.Buffs
	if action == "Start" or action == "Update" then
		buffs:Start(effectId, duration, stacks)
		if action == "Start" then
			UIFeedback.Status(effectId, (StatusDefinitions[effectId] or {}).Category)
		end
	elseif action == "End" then
		buffs:Stop(effectId)
	end
end

return Remote
