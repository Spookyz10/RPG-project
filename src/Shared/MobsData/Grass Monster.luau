local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local BehaviorManager = require(ReplicatedStorage.Shared.Behavrios.BehaviorManager)
local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local Hitbox = require(ServerStorage.Modules.Hitbox)
local MobClass = require(ReplicatedStorage.Shared.MobClass)
local PlayerClass = require(ReplicatedStorage.Shared.PlayerClass)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)

local Mob = {
	HP = 100,
	MaxHP = 100,
	Data = {
		Stats = {
			Attack = 10,
			Defense = 0,
			CriticalChance = 0,
			CriticalPower = 0,
		},
	},
	XP = 10,
	Gold = 10,
	Drops = {
		["Wooden Sword"] = { Chance = 10, Amount = 1 },
	},
}

local function getHighestDamagePlayer(hitlist: { [Player]: number }): Player?
	local HighestDamage = 0
	local HighestPlayer = nil
	for player, damage in hitlist do
		local playerClass = PlayerClass.getPlayerInfo(player)
		if not Functions:isEntityAlive(playerClass) then
			continue
		end

		if damage > HighestDamage then
			HighestDamage = damage
			HighestPlayer = player
		end
	end

	return HighestPlayer
end

function Mob:Start(mob: Model, class: MobClass.MobInfo)
	local Humanoid = mob:FindFirstChild("Humanoid") :: Humanoid
	local RootPart = mob:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not RootPart then
		return
	end

	BehaviorManager.Active[mob] = true

	while mob and RootPart and BehaviorManager.Active[mob] do
		local Hitlist = class.Data.HitList
		local targetPlayer = getHighestDamagePlayer(Hitlist)
		local targetCharacter = targetPlayer.Character
		local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart") :: BasePart
		if targetCharacter and targetRootPart then
			BehaviorManager:Move(Humanoid, targetRootPart.Position)

			if Functions:getDistance(RootPart, targetRootPart) > 50 then
				BehaviorManager:Cancel(mob)
			end

			if Functions:getDistance(RootPart, targetRootPart) < 3 then
				local _, hitlist =
					Hitbox:Create({ Size = Vector3.new(4, 4, 4), Position = targetRootPart + Vector3.new(0, 0, -3) })
				for hitPlayer, playerClass in hitlist.Players do
					if hitPlayer and Functions:isEntityAlive(playerClass) then
						DamageHandler:dealDamage(Mob.Data.Stats.Attack, playerClass)
					end
				end
			end
		end
	end
end

return Mob
