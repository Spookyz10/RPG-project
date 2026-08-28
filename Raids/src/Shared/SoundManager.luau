local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SoundManager = {}

local SFXFolder = ReplicatedStorage.Resources.SFX

local ATTACK_SOUNDS = { "Attack1", "Attack2" }
local HIT_SOUNDS = { "Hit1", "Hit2" }

local function PlayRandomFrom(list: { string }, rootPart: BasePart?)
	if not rootPart then
		return
	end

	local SoundName = list[math.random(1, #list)]
	local Template = SFXFolder:FindFirstChild(SoundName) :: Sound?
	if not Template then
		return
	end

	local NewSound = Template:Clone()
	NewSound.Parent = rootPart
	NewSound:Play()

	Debris:AddItem(NewSound, 5)
end

function SoundManager:PlayAttackSound(rootPart: BasePart?)
	PlayRandomFrom(ATTACK_SOUNDS, rootPart)
end

function SoundManager:PlayHitSound(rootPart: BasePart?)
	PlayRandomFrom(HIT_SOUNDS, rootPart)
end

return SoundManager
