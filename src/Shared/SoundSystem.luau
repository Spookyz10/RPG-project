local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundSystem = {}

local Sounds = {} :: { Sound }

for _, Sound: Sound in ReplicatedStorage.Assets.SFX:GetDescendants() do
	if Sound:IsA("Sound") then
		Sounds[Sound] = true
	end
end

function SoundSystem:PlaySFX(SoundName: string)
	if Sounds[SoundName] then
		Sounds[SoundName]:Play()
	end
end

return SoundSystem
