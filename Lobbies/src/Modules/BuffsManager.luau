local ModifierSystem = require(script.Parent.ModifierSystem)
local EventBus = require(script.Parent.EventBus)

local BuffsManager = {}

export type BuffConfig = {
	Property: string,
	Operation: ModifierSystem.Operation,
	Value: number,
	Duration: number,
	MaxStacks: number?,
	Source: any?,
	Tags: { string }?,
}

type ActiveBuff = {
	Property: string,
	Operation: ModifierSystem.Operation,
	Value: number,
	Stacks: number,
	MaxStacks: number,
	Source: any?,
	Tags: { string },
	ExpiresAt: number,
}

local Active: { [any]: { [string]: ActiveBuff } } = {}

local function getTargetBuffs(target: any): { [string]: ActiveBuff }
	local targetBuffs = Active[target]
	if not targetBuffs then
		targetBuffs = {}
		Active[target] = targetBuffs
	end
	return targetBuffs
end

local function applyModifier(target: any, buffId: string, buff: ActiveBuff)
	local value = buff.Value
	if buff.Operation ~= "Override" then
		value = buff.Value * buff.Stacks
	end

	ModifierSystem:AddModifier(target, buff.Property, buffId, buff.Operation, value, 0, buff.Source)
end

local function scheduleExpire(target: any, buffId: string, duration: number)
	local buffs = getTargetBuffs(target)
	local buff = buffs[buffId]
	if not buff then
		return
	end

	local expiresAt = os.clock() + duration
	buff.ExpiresAt = expiresAt

	task.delay(duration, function()
		local currentBuffs = Active[target]
		local currentBuff = currentBuffs and currentBuffs[buffId]
		if currentBuff and currentBuff.ExpiresAt == expiresAt then
			BuffsManager:Remove(target, buffId)
		end
	end)
end

function BuffsManager:Apply(target: any, buffId: string, config: BuffConfig)
	local buffs = getTargetBuffs(target)
	local existing = buffs[buffId]
	local maxStacks = config.MaxStacks or 1

	if existing then
		existing.Stacks = math.min(existing.Stacks + 1, maxStacks)
		existing.Value = config.Value
		existing.Operation = config.Operation
		existing.Property = config.Property
		existing.Source = config.Source or existing.Source
		existing.Tags = config.Tags or existing.Tags

		applyModifier(target, buffId, existing)
		scheduleExpire(target, buffId, config.Duration)

		EventBus:Fire("BuffStackChanged", target, buffId, existing.Stacks)
		return
	end

	local buff: ActiveBuff = {
		Property = config.Property,
		Operation = config.Operation,
		Value = config.Value,
		Stacks = 1,
		MaxStacks = maxStacks,
		Source = config.Source,
		Tags = config.Tags or {},
		ExpiresAt = 0,
	}

	buffs[buffId] = buff

	applyModifier(target, buffId, buff)
	scheduleExpire(target, buffId, config.Duration)

	EventBus:Fire("BuffApplied", target, buffId, buff)
end

function BuffsManager:Remove(target: any, buffId: string)
	local buffs = Active[target]
	local buff = buffs and buffs[buffId]
	if not buff then
		return
	end

	buffs[buffId] = nil
	ModifierSystem:RemoveModifier(target, buff.Property, buffId)

	if next(buffs) == nil then
		Active[target] = nil
	end

	EventBus:Fire("BuffRemoved", target, buffId)
end

function BuffsManager:HasBuff(target: any, buffId: string): boolean
	local buffs = Active[target]
	return buffs ~= nil and buffs[buffId] ~= nil
end

function BuffsManager:GetStacks(target: any, buffId: string): number
	local buffs = Active[target]
	local buff = buffs and buffs[buffId]
	return buff and buff.Stacks or 0
end

function BuffsManager:GetBuffsByTag(target: any, tag: string): { string }
	local buffs = Active[target]
	if not buffs then
		return {}
	end

	local result = {}
	for buffId, buff in buffs do
		if table.find(buff.Tags, tag) then
			table.insert(result, buffId)
		end
	end

	return result
end

function BuffsManager:ClearEntity(target: any)
	local buffs = Active[target]
	if not buffs then
		return
	end

	Active[target] = nil
	ModifierSystem:ClearTarget(target)

	for buffId in buffs do
		EventBus:Fire("BuffRemoved", target, buffId)
	end
end

return BuffsManager
