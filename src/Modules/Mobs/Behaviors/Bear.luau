local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local IndicatorSystem = require(ReplicatedStorage.Shared.IndicatorSystem)
local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local Hitbox = require(ServerStorage.Modules.Hitbox)
local BehaviorManager = require(ServerStorage.Modules.Mobs.BehaviorManager)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Behavior = {}

function Behavior:Start(mob: Model, class: Types.Entity)
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

			local ChosenAttack = Functions:RollAttack(Attacks)

			if ChosenAttack == "Spin" then
				RemoteManager.SendClientEvent(
					"Indicator",
					{ All = true },
					"Spin",
					{ Main = Color3.fromRGB(199, 8, 8), Display = Color3.fromRGB(255, 0, 0) },
					RootPart.Position + Vector3.new(0, -3.5, 0),
					2
				)

				Humanoid.WalkSpeed = 0

				task.delay(2, function()
					Hitbox:Create({
						Size = Vector3.new(5, 5, 5),
						Part = RootPart,
						Offset = nil,
						Time = nil,
						Caster = mob,
						Drag = false,
						OnHit = function(_, HitEntity)
							DamageHandler:dealDamage(class, HitEntity)
						end,
					})
					Humanoid.WalkSpeed = 16
				end)
			elseif ChosenAttack == "Slam" then
				RemoteManager.SendClientEvent(
					"Indicator",
					{ All = true },
					"Slam",
					{ Main = Color3.fromRGB(199, 8, 8), Display = Color3.fromRGB(255, 0, 0) },
					RootPart.Position + Vector3.new(0, -3.5, -3),
					2
				)

				Humanoid.WalkSpeed = 0

				task.delay(2, function()
					Hitbox:Create({
						Size = Vector3.new(9, 9, 9),
						Part = RootPart,
						Offset = CFrame.new(0, 0, -3),
						Time = nil,
						Caster = mob,
						Drag = false,
						OnHit = function(_, HitEntity)
							DamageHandler:dealDamage(class, HitEntity)
						end,
					})
					Humanoid.WalkSpeed = 16
				end)
			elseif ChosenAttack == "Dash" then
				RemoteManager.SendClientEvent(
					"Indicator",
					{ All = true },
					"Dash",
					{ Main = Color3.fromRGB(199, 8, 8), Display = Color3.fromRGB(255, 0, 0) },
					RootPart.Position + Vector3.new(0, -3.5, -3.5),
					2
				)

				Humanoid.WalkSpeed = 0

				task.delay(2, function()
					Hitbox:Create({
						Size = Vector3.new(9, 9, 9),
						Part = RootPart,
						Offset = nil,
						Time = 2,
						Caster = mob,
						Drag = true,
						OnHit = function(_, HitEntity)
							DamageHandler:dealDamage(class, HitEntity)
						end,
					})
					local TweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
					TweenService:Create(RootPart, TweenInfo, { Position = RootPart.Position + Vector3.new(0, 0, -15) })
				end)
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

return Behavior
