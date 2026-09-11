local RS = game:GetService("ReplicatedStorage")
local Definitions = require(RS.Shared.StatusEffects)
local Behaviors = require(script.Parent.StatusEffectBehaviors)
local Modifiers = require(script.Parent.ModifierSystem)
local Events = require(script.Parent.EventBus)
local Manager = {}
local Entities = {}

local function removeModifier(target, id, entry)
	if entry and entry.Property then Modifiers:RemoveModifier(target, entry.Property, "Status:" .. id) end
end

local function selectActive(target, id, group)
	local best
	for _, entry in group.Entries do
		if not best or entry.Priority > best.Priority then best = entry end
	end
	local previous = group.Active
	removeModifier(target, id, previous)
	group.Active = best
	if best and best.Property then
		Modifiers:AddModifier(target, best.Property, "Status:" .. id, best.Operation, best.Value, best.Priority, best.Source)
	end
	if best then
		if best.Attribute then target:SetAttribute(best.Attribute, true) end
		Events:Fire("StatusEffectChanged", target, id, best)
	elseif previous then
		if previous.Attribute then target:SetAttribute(previous.Attribute, nil) end
		Events:Fire("StatusEffectRemoved", target, id, previous)
	end
end

function Manager:Apply(target, id, options)
	options = options or {}
	local definition = Definitions[id]
	assert(definition, "Unknown status effect: " .. tostring(id))
	local humanoid = target:FindFirstChildOfClass("Humanoid")
	if not target.Parent or not humanoid or humanoid.Health <= 0 then return end
	local config = table.clone(definition)
	for key, value in options do config[key] = value end
	assert(config.Duration == nil or (config.Duration > 0 and config.Duration < math.huge), "Duration must be finite and positive")
	assert(config.Interval == nil or (config.Interval > 0 and config.Interval < math.huge), "Interval must be finite and positive")
	local priority = config.Priority or 0
	local entity = Entities[target]
	if not entity then entity = {}; Entities[target] = entity end
	local group = entity[id]
	if not group then group = { Entries = {} }; entity[id] = group end
	local previous = group.Entries[priority]
	-- Refresh replaces the same priority; it does not start a second ticking loop.
	config.Priority = priority
	config.Stacks = math.clamp(config.Stacks or 1, 1, config.MaxStacks or 1)
	config.ExpiresAt = config.Duration and os.clock() + config.Duration or math.huge
	config.NextTick = config.Interval and os.clock() + config.Interval or math.huge
	config.State = previous and previous.State or {}
	group.Entries[priority] = config
	local behavior = Behaviors[id]
	if behavior and behavior.OnApply then behavior.OnApply(target, config, previous ~= nil) end
	selectActive(target, id, group)
	return config
end

function Manager:Remove(target, id)
	local entity = Entities[target]
	local group = entity and entity[id]
	if not group then return end
	entity[id] = nil
	group.Entries = {}
	selectActive(target, id, group)
	local behavior = Behaviors[id]
	if behavior and behavior.OnRemove then behavior.OnRemove(target) end
	if next(entity) == nil then Entities[target] = nil end
end

function Manager:Get(target, id)
	local group = Entities[target] and Entities[target][id]
	return group and group.Active
end

function Manager:HasEffect(target, id) return self:Get(target, id) ~= nil end

function Manager:GetEffectsByTag(target, tag)
	local result = {}
	for id, group in Entities[target] or {} do
		if group.Active and table.find(group.Active.Tags or {}, tag) then table.insert(result, id) end
	end
	return result
end

function Manager:ClearDebuffs(target)
 for id, group in table.clone(Entities[target] or {}) do
  local debuff = Definitions[id] and Definitions[id].Category == "Debuff"
  for _, entry in group.Entries do
   if entry.Category == "Debuff" then debuff = true; break end
  end
  if debuff then self:Remove(target, id) end
 end
end

function Manager:ClearEntity(target)
	for id in table.clone(Entities[target] or {}) do self:Remove(target, id) end
end

-- A single scheduler owns all lifetimes. Explicit stepping also supports deterministic tests.
function Manager:Step(now)
	for target, entity in table.clone(Entities) do
		local humanoid = target:FindFirstChildOfClass("Humanoid")
		if not target.Parent or not humanoid or humanoid.Health <= 0 then self:ClearEntity(target); continue end
		for id, group in table.clone(entity) do
			local active = group.Active
			local behavior = Behaviors[id]
			while active and active.NextTick <= math.min(now, active.ExpiresAt) do
				active.NextTick += active.Interval
				if behavior and behavior.OnTick then behavior.OnTick(target, active) end
				if humanoid.Health <= 0 or self:Get(target, id) ~= active then break end
			end
			if entity[id] ~= group then continue end
			if humanoid.Health <= 0 then self:ClearEntity(target); break end
			local changed = false
			for priority, entry in group.Entries do
				if now >= entry.ExpiresAt then group.Entries[priority] = nil; changed = true end
			end
			if next(group.Entries) == nil then self:Remove(target, id)
			elseif changed then
				selectActive(target, id, group)
				-- Suppressed effects do not accumulate deferred ticks.
				if group.Active.Interval then group.Active.NextTick = now + group.Active.Interval end
			end
		end
	end
end

return Manager
