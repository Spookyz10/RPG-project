local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local Hitbox = require(ServerStorage.Modules.Hitbox)
local BehaviorManager = require(ServerStorage.Modules.Mobs.BehaviorManager)
local CooldownSystem = require(ServerStorage.Modules.CooldownSystem)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local ATTACK_RANGE = 4
local WINDUP_TIME = 1
local ATTACK_COOLDOWN = 1.5

local DEFAULT_SIZE = Vector3.new(6, 6, 6)
local DEFAULT_OFFSET = CFrame.new(0, 0, -3)

export type Config = {
	Size: Vector3?,
	Offset: CFrame?,
}

local BasicMeleeBehavior = {}
BasicMeleeBehavior.__index = BasicMeleeBehavior

function BasicMeleeBehavior.new(config: Config?)
	local self = setmetatable({}, BasicMeleeBehavior)

	self.Size = (config and config.Size) or DEFAULT_SIZE
	self.Offset = (config and config.Offset) or DEFAULT_OFFSET

	return self
end

function BasicMeleeBehavior:Start(mob: Model, class: Types.Entity)
	if BehaviorManager.Active[mob] then
		return
	end

	local Humanoid = mob:FindFirstChild("Humanoid") :: Humanoid
	local RootPart = mob:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not RootPart then
		return
	end

	BehaviorManager.Active[mob] = true

	local IsAttacking = false

	while mob and mob.Parent and RootPart and RootPart.Parent and BehaviorManager.Active[mob] do
		local Hitlist = class.HitList
		local targetPlayer = Functions:GetTargetPlayer(mob, Hitlist)
		if not targetPlayer then
			BehaviorManager:Reset(mob)
			break
		end

		local targetCharacter = targetPlayer.Character
		local targetRootPart = targetCharacter and (targetCharacter:FindFirstChild("HumanoidRootPart") :: BasePart)

		if targetCharacter and targetRootPart then
			if not IsAttacking then
				BehaviorManager:Move(Humanoid, targetRootPart.Position)
			end

			if Functions:getDistance(RootPart, targetRootPart) > 50 then
				BehaviorManager:Reset(mob)
				break
			end

			if
				not IsAttacking
				and Functions:getDistance(RootPart, targetRootPart) < ATTACK_RANGE
				and not CooldownSystem:IsInCooldown(mob, "MeleeAttack")
			then
				IsAttacking = true
				Humanoid.WalkSpeed = 0

				local HitboxCFrame = RootPart.CFrame * self.Offset
				local IndicatorSize = Vector3.new(self.Size.X, 0.3, self.Size.Z)

				local GroundCFrame = Functions:GetGroundCFrame(HitboxCFrame.Position, { mob }, nil, HitboxCFrame)

				RemoteManager.SendClientEvent(
					"Indicator",
					{ All = true },
					"BasicMelee",
					{ Main = Color3.fromRGB(199, 8, 8), Display = Color3.fromRGB(255, 0, 0) },
					GroundCFrame,
					WINDUP_TIME,
					IndicatorSize
				)

				task.delay(WINDUP_TIME, function()
					if mob and mob.Parent and RootPart and RootPart.Parent and BehaviorManager.Active[mob] then
						local StillValid = targetCharacter.Parent and targetRootPart.Parent

						if StillValid and Functions:getDistance(RootPart, targetRootPart) < ATTACK_RANGE then
							CooldownSystem:StartCooldown(mob, "MeleeAttack", ATTACK_COOLDOWN)

							Hitbox:Create({
								Size = self.Size,
								Part = RootPart,
								Offset = self.Offset,
								Drag = false,
								Time = 0,
								Caster = mob,
								OnHit = function(_, HitEntity)
									if Functions:isEntityAlive(HitEntity) then
										DamageHandler:dealDamage(class, HitEntity)
									end
								end,
							})
						end

						if Humanoid and Humanoid.Parent then
							Humanoid.WalkSpeed = 16
						end
					end
					IsAttacking = false
				end)
			end
		end

		task.wait(0.1)
	end
end

return BasicMeleeBehavior
