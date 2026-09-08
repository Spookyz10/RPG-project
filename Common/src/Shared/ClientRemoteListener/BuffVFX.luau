local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuffEffects = require(ReplicatedStorage.Shared.BuffEffects)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local Logic = require(ReplicatedStorage.Shared.UI.Logic)

local Remote = {}

function Remote:Activate(Effect: string, Entity: Model, Function: string, Duration: number?)
	if BuffEffects[Effect] then
		if Function == "Start" then
			BuffEffects[Effect].Apply(Entity)
		elseif Function == "End" then
			BuffEffects[Effect].Stop(Entity)
		end
	end

	if Entity == UIConstants.Character then
		local BuffsUI = Logic["Buffs"]
		if BuffsUI then
			if Function == "Start" then
				BuffsUI:Start(Effect, Duration or 0)
			elseif Function == "End" then
				BuffsUI:Stop(Effect)
			end
		end
	end
end

return Remote
