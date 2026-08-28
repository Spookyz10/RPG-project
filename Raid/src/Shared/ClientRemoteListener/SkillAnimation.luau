local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnimationHandler = require(ReplicatedStorage.Shared.AnimationHandler)

local Remote = {}

function Remote:Activate(Character: Model, animName: string, fadeTime: number?, speed: number?)
	if not Character then
		return
	end

	local Handler = AnimationHandler.GetOrCreate(Character)
	Handler:Play(animName, fadeTime, speed)
end

return Remote
