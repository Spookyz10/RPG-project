local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local BehaviorManager = require(ReplicatedStorage.Shared.Behavrios.BehaviorManager)
local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local Hitbox = require(ServerStorage.Modules.Hitbox)

local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Mob: Types.MobInfo = {
	HP = 100,
	MaxHP = 100,
	Level = 1,
	MaxLevel = 15,
	Data = {
		Stats = {
			Attack = 10,
			Defense = 0,
			CriticalChance = 0,
			CriticalPower = 0,
		},
	},
	XP = 10,
	Currencies = {
		Gold = 10,
		VillagePoints = 10,
	},
	Zone = "Village Outskirts",
	Drops = {
		["Wooden Sword"] = { Chance = 10, Amount = 1 },
	},
	RespawnTime = 10,
	GlobalDrops = false,
}

function Mob:Start(mob: Model, class: Types.Entity)
	local Humanoid = mob:FindFirstChild("Humanoid") :: Humanoid
	local RootPart = mob:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not RootPart then
		return
	end

	BehaviorManager.Active[mob] = true

	while mob and RootPart and BehaviorManager.Active[mob] do
		local Hitlist = class.HitList
		local targetPlayer = Functions:GetTargetPlayer(mob, Hitlist)
		if not targetPlayer then
			BehaviorManager:Reset(mob)
		end
		local targetCharacter = targetPlayer.Character
		local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart") :: BasePart
		if targetCharacter and targetRootPart then
			BehaviorManager:Move(Humanoid, targetRootPart.Position)

			if Functions:getDistance(RootPart, targetRootPart) > 50 then
				BehaviorManager:Reset(mob)
			end

			if Functions:getDistance(RootPart, targetRootPart) < 3 then
				local _, hitlist = Hitbox:Create({
					Size = Vector3.new(4, 4, 4),
					Part = targetRootPart,
					Offset = Vector3.new(0, 0, -3),
					Drag = false,
					Time = 0,
				})
				for hitPlayer, playerClass in hitlist.Players do
					if hitPlayer and Functions:isEntityAlive(playerClass) then
						DamageHandler:dealDamage(class, playerClass)
					end
				end
			end
		end
	end
end

return Mob
