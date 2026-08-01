local Players = game:GetService("Players")

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

function CooldownSystem:StartCooldown(entity: Instance, key: string, duration: number): boolean
	local entityCooldowns = getEntityCooldowns(entity)

	if entityCooldowns[key] and entityCooldowns[key] > os.clock() then
		return false
	end

	local endTime = os.clock() + duration
	entityCooldowns[key] = endTime

	task.delay(duration, function()
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

Players.PlayerRemoving:Connect(function(player)
	Cooldowns[player] = nil
end)

return CooldownSystem
