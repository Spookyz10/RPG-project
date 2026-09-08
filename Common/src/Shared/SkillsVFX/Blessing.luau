local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local VFX = {}

local EffectsFolder = ReplicatedStorage.Resources.Effects.Blessing

function VFX:Play(Character: Model)
	local RootPart = Character.PrimaryPart
	if not RootPart then
		return
	end

	local Light = EffectsFolder.Light:Clone()
	Light.Parent = workspace
	Light.CFrame = RootPart.CFrame

	TweenService:Create(Light, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
		Size = Vector3.new(20, 0.05, 20),
		Transparency = 1,
	}):Play()

	Debris:AddItem(Light, 0.9)
end

return VFX
