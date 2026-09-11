local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuffEffects = require(ReplicatedStorage.Shared.BuffEffects)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local Logic = require(ReplicatedStorage.Shared.UI.Logic)

local Remote = {}

function Remote:Activate(Effect: string, Entity: Model, Function: string, Duration: number?, Stacks: number?)
	local VFX = require(ReplicatedStorage.Shared.CombatVFX)
 local supported = false
 for _, id in VFX.StatusNames do if id == Effect then supported = true; break end end
 if supported then
  if Function == "Start" then VFX:Status(Entity, Effect, Duration)
  elseif Function == "End" then VFX:StopStatus(Entity, Effect) end
 elseif BuffEffects[Effect] then
  if Function == "Start" then BuffEffects[Effect].Apply(Entity)
  elseif Function == "End" then BuffEffects[Effect].Stop(Entity) end
 end

	if Entity == UIConstants.Character then
		local BuffsUI = Logic["Buffs"]
		if BuffsUI then
			if Function == "Start" then
				BuffsUI:Start(Effect, Duration, Stacks)
			elseif Function == "End" then
				BuffsUI:Stop(Effect)
			end
		end
	end
end

return Remote
