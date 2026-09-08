local ModifierSystem = require(script.Parent.ModifierSystem)
local EventBus = require(script.Parent.EventBus)

local BuffsManager = {}

export type EffectConfig = {
	Property: string,
	Operation: ModifierSystem.Operation,
	Value: number,
	Duration: number,
	Priority: number?,
	Source: any?,
	Tags: { string }?,
}

type Effect = {
	Property: string,
	Operation: ModifierSystem.Operation,
	Value: number,
	Priority: number,
	Source: any?,
	Tags: { string },
	ExpiresAt: number,
}

type EffectGroup = {
	Entries: { Effect },
	ActiveEntry: Effect?,
}

local Groups: { [any]: { [string]: EffectGroup } } = {}

local function GetGroup(target: any, effectId: string, create: boolean?): EffectGroup?
	local targetGroups = Groups[target]
	if not targetGroups then
		if not create then
			return nil
		end
		targetGroups = {}
		Groups[target] = targetGroups
	end

	local group = targetGroups[effectId]
	if not group and create then
		group = { Entries = {}, ActiveEntry = nil }
		targetGroups[effectId] = group
	end

	return group
end

local function RecomputeActive(target: any, effectId: string)
	local group = GetGroup(target, effectId)
	if not group then
		return
	end

	local Best: Effect? = nil
	for _, entry in group.Entries do
		if not Best or entry.Priority > Best.Priority then
			Best = entry
		end
	end

	local Previous = group.ActiveEntry

	if Previous and Previous ~= Best then
		ModifierSystem:RemoveModifier(target, Previous.Property, effectId)
	end

	group.ActiveEntry = Best

	if Best then
		ModifierSystem:AddModifier(
			target,
			Best.Property,
			effectId,
			Best.Operation,
			Best.Value,
			Best.Priority,
			Best.Source
		)

		if Previous ~= Best then
			EventBus:Fire("EffectActivated", target, effectId, Best)
		end
	end
end

local function RemoveEntry(target: any, effectId: string, entry: Effect)
	local group = GetGroup(target, effectId)
	if not group then
		return
	end

	local index = table.find(group.Entries, entry)
	if not index then
		return
	end

	table.remove(group.Entries, index)

	EventBus:Fire("EffectExpired", target, effectId, entry)

	if #group.Entries == 0 then
		local targetGroups = Groups[target]
		if targetGroups then
			targetGroups[effectId] = nil
			if next(targetGroups) == nil then
				Groups[target] = nil
			end
		end
		return
	end

	RecomputeActive(target, effectId)
end

local function ScheduleExpiry(target: any, effectId: string, entry: Effect, duration: number)
	local Snapshot = entry.ExpiresAt

	task.delay(duration, function()
		if entry.ExpiresAt ~= Snapshot then
			return
		end

		RemoveEntry(target, effectId, entry)
	end)
end

function BuffsManager:Apply(target: any, effectId: string, config: EffectConfig)
	local group = GetGroup(target, effectId, true) :: EffectGroup
	local Priority = config.Priority or config.Value

	local Existing: Effect? = nil
	for _, entry in group.Entries do
		if entry.Priority == Priority then
			Existing = entry
			break
		end
	end

	local Entry: Effect

	if Existing then
		Existing.Value = config.Value
		Existing.Operation = config.Operation
		Existing.Property = config.Property
		Existing.Source = config.Source or Existing.Source
		Existing.Tags = config.Tags or Existing.Tags
		Existing.ExpiresAt = os.clock() + config.Duration
		Entry = Existing
	else
		Entry = {
			Property = config.Property,
			Operation = config.Operation,
			Value = config.Value,
			Priority = Priority,
			Source = config.Source,
			Tags = config.Tags or {},
			ExpiresAt = os.clock() + config.Duration,
		}
		table.insert(group.Entries, Entry)
	end

	EventBus:Fire("EffectApplied", target, effectId, Entry)

	ScheduleExpiry(target, effectId, Entry, config.Duration)

	RecomputeActive(target, effectId)
end

function BuffsManager:Remove(target: any, effectId: string)
	local group = GetGroup(target, effectId)
	if not group then
		return
	end

	for _, entry in table.clone(group.Entries) do
		RemoveEntry(target, effectId, entry)
	end
end

function BuffsManager:HasEffect(target: any, effectId: string): boolean
	local group = GetGroup(target, effectId)
	return group ~= nil and #group.Entries > 0
end

function BuffsManager:HasBuff(target: any, effectId: string): boolean
	return self:HasEffect(target, effectId)
end

function BuffsManager:IsEffectActive(target: any, effectId: string): boolean
	local group = GetGroup(target, effectId)
	return group ~= nil and group.ActiveEntry ~= nil
end

function BuffsManager:GetEffectsByTag(target: any, tag: string): { string }
	local targetGroups = Groups[target]
	if not targetGroups then
		return {}
	end

	local result = {}
	for effectId, group in targetGroups do
		for _, entry in group.Entries do
			if table.find(entry.Tags, tag) then
				table.insert(result, effectId)
				break
			end
		end
	end

	return result
end

function BuffsManager:ClearEntity(target: any)
	local targetGroups = Groups[target]
	if not targetGroups then
		return
	end

	Groups[target] = nil
	ModifierSystem:ClearTarget(target)

	for effectId, group in targetGroups do
		for _, entry in group.Entries do
			EventBus:Fire("EffectExpired", target, effectId, entry)
		end
	end
end

return BuffsManager
