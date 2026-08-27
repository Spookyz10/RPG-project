local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFX = {}

local EffectsFolder = ReplicatedStorage.Resources.Effects.Cyclone

local GROWTH_STEP = Vector3.new(0.7, 0.6, 0.7)
local GROWTH_ITERATIONS = 10

function VFX:Play(Character: Model)
	local RootPart = Character.PrimaryPart
	local UpperTorso = Character:FindFirstChild("UpperTorso")

	if not RootPart or not UpperTorso then
		return
	end

	local Wind1 = EffectsFolder.CycloneWind:Clone()
	Wind1.Parent = RootPart
	Wind1.Weld.Part0 = UpperTorso
	Debris:AddItem(Wind1, 0.7)

	local Wind2 = EffectsFolder.CycloneWind2:Clone()
	Wind2.Parent = RootPart
	Wind2.Weld.Part0 = UpperTorso

	local Wind3 = EffectsFolder.CycloneWind3:Clone()
	Wind3.Parent = RootPart
	Wind3.Weld.Part0 = UpperTorso
	Debris:AddItem(Wind3, 0.7)

	task.delay(0.6, function()
		if not Wind2 or not Wind2.Parent then
			return
		end

		for _ = 1, GROWTH_ITERATIONS do
			if not Wind2 or not Wind2.Parent then
				return
			end

			Wind2.Transparency += 0.05
			Wind2.Orientation = Vector3.new(0, Wind2.Orientation.Y, 0)
			Wind2.Mesh.Scale += GROWTH_STEP
			task.wait()
		end

		Debris:AddItem(Wind2, 0)
	end)
end

return VFX
