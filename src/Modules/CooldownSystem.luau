local CooldownSystem = {}

local Cooldowns = {}

function CooldownSystem:StartCooldown(player: Player, key: string, duration: number): string
	if Cooldowns[player] and Cooldowns[player][key] then
		return "In cooldown"
	end
	Cooldowns[player] = { [key] = true }
	task.delay(duration, function()
		if Cooldowns[player][key] then
			Cooldowns[player][key] = nil
		end
	end)

	return "Added cooldown"
end

function CooldownSystem:IsInCooldown(player: Player, key: string)
	return Cooldowns[player] and Cooldowns[player][key]
end

function CooldownSystem:ResetCooldown(player: Player, key: string)
	if Cooldowns[player] and Cooldowns[player][key] then
		Cooldowns[player][key] = nil
	end
end

function CooldownSystem:resetAllCooldowns(player: Player)
	if Cooldowns[player] then
		Cooldowns[player] = nil
	end
end

return CooldownSystem
