local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SkillsVFX = require(ReplicatedStorage.Shared.SkillsVFX)

local Remote = {}

function Remote:Activate(Skill: string, ...)
	local VFXModule = SkillsVFX[Skill]
	if VFXModule then
		VFXModule:Play(...)
	end
end

return Remote
