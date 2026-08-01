local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local Hitbox = require(ServerStorage.Modules.Hitbox)
local BehaviorManager = require(ServerStorage.Modules.Mobs.BehaviorManager)
local CooldownSystem = require(ServerStorage.Modules.CooldownSystem)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Behavior = {}

local SPECIAL_ATTACK_COOLDOWN = 4
local WINDUP_TIME = 2
local INDICATOR_COLOR = { Main = Color3.fromRGB(199, 8, 8), Display = Color3.fromRGB(255, 0, 0) }

local function SendSquareIndicator(RootPart: BasePart, Offset: CFrame?, Size: Vector3, Time: number)
	local HitboxCFrame = Offset and (RootPart.CFrame * Offset) or RootPart.CFrame
	local IndicatorSize = Vector3.new(Size.X, 0.3, Size.Z)

	local GroundCFrame = Functions:GetGroundCFrame(HitboxCFrame.Position, { RootPart.Parent }, nil, HitboxCFrame)

	RemoteManager.SendClientEvent(
		"Indicator",
		{ All = true },
		"Square",
		INDICATOR_COLOR,
		GroundCFrame,
		Time,
		IndicatorSize
	)
end

local function SendDashPathIndicator(RootPart: BasePart, Size: Vector3, DashDistance: number, Time: number)
	local Direction = RootPart.CFrame.LookVector
	local StartPosition = RootPart.Position
	local EndPosition = StartPosition + Direction * DashDistance
	local Center = StartPosition:Lerp(EndPosition, 0.5)

	local PathLength = DashDistance + Size.Z
	local PathSize = Vector3.new(Size.X, 0.3, PathLength)

	local FacingCFrame = CFrame.lookAt(Center, Center + Direction)
	local GroundCFrame = Functions:GetGroundCFrame(Center, { RootPart.Parent }, nil, FacingCFrame)

	RemoteManager.SendClientEvent("Indicator", { All = true }, "Square", INDICATOR_COLOR, GroundCFrame, Time, PathSize)

	return Direction
end

function Behavior:Start(mob: Model, class: Types.Entity)
	if BehaviorManager.Active[mob] then
		return
	end

	local Humanoid = mob:FindFirstChild("Humanoid") :: Humanoid
	local RootPart = mob:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not RootPart then
		return
	end

	local Attacks = {
		["Spin"] = 50,
		["Slam"] = 20,
		["Dash"] = 30,
	}

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

			if not IsAttacking and not CooldownSystem:IsInCooldown(mob, "SpecialAttack") then
				local ChosenAttack = Functions:RollAttack(Attacks)

				if ChosenAttack == "Spin" then
					IsAttacking = true
					CooldownSystem:StartCooldown(mob, "SpecialAttack", SPECIAL_ATTACK_COOLDOWN)

					local Size = Vector3.new(5, 5, 5)
					local Offset = nil

					SendSquareIndicator(RootPart, Offset, Size, WINDUP_TIME)

					Humanoid.WalkSpeed = 0

					task.delay(WINDUP_TIME, function()
						if BehaviorManager.Active[mob] and RootPart and RootPart.Parent then
							Hitbox:Create({
								Size = Size,
								Part = RootPart,
								Offset = Offset,
								Time = nil,
								Caster = mob,
								Drag = false,
								OnHit = function(_, HitEntity)
									DamageHandler:dealDamage(class, HitEntity)
								end,
							})
							if Humanoid and Humanoid.Parent then
								Humanoid.WalkSpeed = 16
							end
						end
						IsAttacking = false
					end)
				elseif ChosenAttack == "Slam" then
					IsAttacking = true
					CooldownSystem:StartCooldown(mob, "SpecialAttack", SPECIAL_ATTACK_COOLDOWN)

					local Size = Vector3.new(9, 9, 9)
					local Offset = CFrame.new(0, 0, -3)

					SendSquareIndicator(RootPart, Offset, Size, WINDUP_TIME)

					Humanoid.WalkSpeed = 0

					task.delay(WINDUP_TIME, function()
						if BehaviorManager.Active[mob] and RootPart and RootPart.Parent then
							Hitbox:Create({
								Size = Size,
								Part = RootPart,
								Offset = Offset,
								Time = nil,
								Caster = mob,
								Drag = false,
								OnHit = function(_, HitEntity)
									DamageHandler:dealDamage(class, HitEntity)
								end,
							})
							if Humanoid and Humanoid.Parent then
								Humanoid.WalkSpeed = 16
							end
						end
						IsAttacking = false
					end)
				elseif ChosenAttack == "Dash" then
					IsAttacking = true
					CooldownSystem:StartCooldown(mob, "SpecialAttack", SPECIAL_ATTACK_COOLDOWN)

					local Size = Vector3.new(9, 9, 9)
					local DashDistance = 15

					local Direction = SendDashPathIndicator(RootPart, Size, DashDistance, WINDUP_TIME)

					Humanoid.WalkSpeed = 0

					task.delay(WINDUP_TIME, function()
						if BehaviorManager.Active[mob] and RootPart and RootPart.Parent then
							Hitbox:Create({
								Size = Size,
								Part = RootPart,
								Offset = nil,
								Time = DashDistance / 7.5,
								Caster = mob,
								Drag = true,
								OnHit = function(_, HitEntity)
									DamageHandler:dealDamage(class, HitEntity)
								end,
							})
							local DashTweenInfo =
								TweenInfo.new(DashDistance / 7.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
							TweenService:Create(RootPart, DashTweenInfo, {
								Position = RootPart.Position + Direction * DashDistance,
							}):Play()
						end
						IsAttacking = false
					end)
				end
			end

			if
				not IsAttacking
				and Functions:getDistance(RootPart, targetRootPart) < 3
				and not CooldownSystem:IsInCooldown(mob, "MeleeAttack")
			then
				CooldownSystem:StartCooldown(mob, "MeleeAttack", 1)

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

		task.wait(0.1)
	end
end

return Behavior
