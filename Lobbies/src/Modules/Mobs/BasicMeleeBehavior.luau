local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local Hitbox = require(ServerStorage.Modules.Hitbox)
local BehaviorManager = require(ServerStorage.Modules.Mobs.BehaviorManager)
local CooldownSystem = require(ServerStorage.Modules.CooldownSystem)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Players = game:GetService("Players")

local ATTACK_COOLDOWN = 1.5

local DEFAULT_SIZE = Vector3.new(6, 6, 6)
local DEFAULT_OFFSET = CFrame.new(0, 0, -3)
local DEFAULT_BUFFER = 4

export type Config = {
	Size: Vector3?,
	Offset: CFrame?,
	Buffer: number?,
}

local BasicMeleeBehavior = {}
BasicMeleeBehavior.__index = BasicMeleeBehavior

function BasicMeleeBehavior.new(config: Config?)
	local self = setmetatable({}, BasicMeleeBehavior)

	self.Size = (config and config.Size) or DEFAULT_SIZE
	self.Offset = (config and config.Offset) or DEFAULT_OFFSET
	self.Buffer = (config and config.Buffer) or DEFAULT_BUFFER

	return self
end

function BasicMeleeBehavior:Start(mob: Model)
	if BehaviorManager.Active[mob] then
		return
	end

	local Humanoid = mob:FindFirstChild("Humanoid") :: Humanoid
	local RootPart = mob:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not RootPart then
		return
	end

	BehaviorManager.Active[mob] = true

	while mob and mob.Parent and RootPart and RootPart.Parent and BehaviorManager.Active[mob] do
		local Hitlist = {}
		local HasHits = false
		local HitListFolder = mob:FindFirstChild("HitList")
		if HitListFolder then
			for _, entry in HitListFolder:GetChildren() do
				local player = Players:GetPlayerByUserId(tonumber(entry.Name))
				if player then
					Hitlist[player] = entry.Value
					HasHits = true
				end
			end
		end

		local targetPlayer = Functions:GetTargetPlayer(mob, HasHits and Hitlist or nil)

		if not targetPlayer then
			BehaviorManager:Reset(mob)
			break
		end

		local targetCharacter = targetPlayer.Character
		local targetRootPart = targetCharacter and (targetCharacter:FindFirstChild("HumanoidRootPart") :: BasePart)

		if targetCharacter and targetRootPart then
			local Distance = Functions:getDistance(RootPart, targetRootPart)

			if Distance > 50 then
				BehaviorManager:Reset(mob)
				break
			end

			if Distance > self.Buffer then
				Humanoid.WalkSpeed = 16
				BehaviorManager:Move(Humanoid, targetRootPart.Position)
			else
				Humanoid.WalkSpeed = 0

				if not CooldownSystem:IsInCooldown(mob, "MeleeAttack") then
					CooldownSystem:StartCooldown(mob, "MeleeAttack", ATTACK_COOLDOWN)

					Hitbox:Create({
						Size = self.Size,
						Part = RootPart,
						Offset = self.Offset,
						Drag = false,
						Time = 0,
						Caster = mob,
						OnHit = function(_, HitEntity)
							if Functions:isEntityAlive(HitEntity) and not Functions:isClassMob(HitEntity) then
								DamageHandler:dealDamage(mob, HitEntity)
							end
						end,
					})
				end
			end
		else
			Humanoid.WalkSpeed = 16
		end

		task.wait(0.1)
	end
end

return BasicMeleeBehavior
