local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local Hitbox = require(ServerStorage.Modules.Hitbox)
local BehaviorManager = require(ServerStorage.Modules.Mobs.BehaviorManager)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Behavior = {}

function Behavior:Start(mob: Model, class: Types.Entity)
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

return Behavior
