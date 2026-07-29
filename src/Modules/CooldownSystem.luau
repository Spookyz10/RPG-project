local Players = game:GetService("Players")

local CooldownSystem = {}

local Cooldowns: { [Player]: { [string]: number } } = {}

local function getPlayerCooldowns(player: Player)
	local playerCooldowns = Cooldowns[player]
	if not playerCooldowns then
		playerCooldowns = {}
		Cooldowns[player] = playerCooldowns
	end
	return playerCooldowns
end

function CooldownSystem:StartCooldown(player: Player, key: string, duration: number): boolean
	local playerCooldowns = getPlayerCooldowns(player)

	if playerCooldowns[key] and playerCooldowns[key] > os.clock() then
		return false
	end

	local endTime = os.clock() + duration
	playerCooldowns[key] = endTime

	task.delay(duration, function()
		local currentCooldowns = Cooldowns[player]
		if currentCooldowns and currentCooldowns[key] == endTime then
			currentCooldowns[key] = nil
		end
	end)

	return true
end

function CooldownSystem:IsInCooldown(player: Player, key: string): boolean
	local playerCooldowns = Cooldowns[player]
	if not playerCooldowns or not playerCooldowns[key] then
		return false
	end
	return playerCooldowns[key] > os.clock()
end

function CooldownSystem:GetTimeLeft(player: Player, key: string): number
	local playerCooldowns = Cooldowns[player]
	if not playerCooldowns or not playerCooldowns[key] then
		return 0
	end
	return math.max(0, playerCooldowns[key] - os.clock())
end

function CooldownSystem:ResetCooldown(player: Player, key: string)
	local playerCooldowns = Cooldowns[player]
	if playerCooldowns then
		playerCooldowns[key] = nil
	end
end

function CooldownSystem:ResetAllCooldowns(player: Player)
	Cooldowns[player] = nil
end

Players.PlayerRemoving:Connect(function(player)
	Cooldowns[player] = nil
end)

return CooldownSystem
