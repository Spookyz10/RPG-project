local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundManager = require(ReplicatedStorage.Shared.SoundManager)

local Remote = {}

function Remote:Activate(Character: Model)
	if not Character then
		return
	end

	local RootPart = Character.PrimaryPart
	if not RootPart then
		return
	end

	SoundManager:PlayAttackSound(RootPart)
end

return Remote
