local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuffEffects = require(ReplicatedStorage.Shared.BuffEffects)

local Remote = {}

function Remote:Activate(Effect: string, Entity: Model, Function: string)
	if BuffEffects[Effect] then
		if Function == "Start" then
			BuffEffects[Effect].Apply(Entity)
		elseif Function == "End" then
			BuffEffects[Effect].Stop(Entity)
		end
	end
end

return Remote
