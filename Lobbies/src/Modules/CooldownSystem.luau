local ModifierSystem = require(script.Parent.ModifierSystem)

local CooldownSystem = {}

local Cooldowns: { [Instance]: { [string]: number } } = {}

local function getEntityCooldowns(entity: Instance)
	local entityCooldowns = Cooldowns[entity]
	if not entityCooldowns then
		entityCooldowns = {}
		Cooldowns[entity] = entityCooldowns
	end
	return entityCooldowns
end

local function GetModifierCharacter(entity: Instance): Instance?
	if entity:IsA("Player") then
		return (entity :: Player).Character
	elseif entity:IsA("Model") then
		return entity
	end
	return nil
end

function CooldownSystem:StartCooldown(entity: Instance, key: string, duration: number): boolean
	local entityCooldowns = getEntityCooldowns(entity)

	local ModifierTarget = GetModifierCharacter(entity)
	local FinalDuration = ModifierTarget and ModifierSystem:Aggregate(ModifierTarget, "CooldownDuration", duration)
		or duration

	if entityCooldowns[key] and entityCooldowns[key] > os.clock() then
		return false
	end

	local endTime = os.clock() + FinalDuration
	entityCooldowns[key] = endTime

	task.delay(FinalDuration, function()
		local currentCooldowns = Cooldowns[entity]
		if currentCooldowns and currentCooldowns[key] == endTime then
			currentCooldowns[key] = nil
		end
	end)

	return true
end

function CooldownSystem:IsInCooldown(entity: Instance, key: string): boolean
	local entityCooldowns = Cooldowns[entity]
	if not entityCooldowns or not entityCooldowns[key] then
		return false
	end
	return entityCooldowns[key] > os.clock()
end

function CooldownSystem:GetTimeLeft(entity: Instance, key: string): number
	local entityCooldowns = Cooldowns[entity]
	if not entityCooldowns or not entityCooldowns[key] then
		return 0
	end
	return math.max(0, entityCooldowns[key] - os.clock())
end

function CooldownSystem:ResetCooldown(entity: Instance, key: string)
	local entityCooldowns = Cooldowns[entity]
	if entityCooldowns then
		entityCooldowns[key] = nil
	end
end

function CooldownSystem:ResetAllCooldowns(entity: Instance)
	Cooldowns[entity] = nil
end

function CooldownSystem.OnPlayerRemoved(Player: Player)
	Cooldowns[Player] = nil
end

return CooldownSystem
