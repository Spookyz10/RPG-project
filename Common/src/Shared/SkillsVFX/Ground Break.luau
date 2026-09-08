local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFX = {}

local EffectsFolder = ReplicatedStorage.Resources.Effects["Ground Break"]

local FADE_STEPS = 10
local FADE_WAIT = 0.05
local DEBRIS_COLOR = "Brown"

local function SmallGroundExplosion(position: Vector3)
	for _ = 1, math.random(6, 10) do
		local Piece = Instance.new("Part")
		Piece.Name = "SDebris"
		Piece.CanCollide = false
		Piece.BrickColor = BrickColor.new(DEBRIS_COLOR)
		Piece.Material = Enum.Material.SmoothPlastic
		Piece.Size = Vector3.new(math.random(4, 6), math.random(4, 6), math.random(4, 6))
		Piece.Position = position
		Piece.Velocity = Vector3.new(math.random(-36, 30), math.random(20, 30), math.random(-36, 36)) * 2
		Piece.Parent = workspace
		Debris:AddItem(Piece, 3)
	end
end

function VFX:Play(Character: Model)
	local RootPart = Character.PrimaryPart
	if not RootPart then
		return
	end

	local Origin = RootPart.CFrame * CFrame.new(0, -3, -5)

	local Crack = EffectsFolder.Crack:Clone()
	Crack.Parent = workspace
	Crack.CFrame = Origin

	local Explosion = EffectsFolder.Explosion:Clone()
	Explosion.Parent = workspace
	Explosion.CFrame = Origin * CFrame.new(0, Explosion.Size.Y / 2, 0)

	SmallGroundExplosion(Origin.Position)

	task.spawn(function()
		task.wait(1)

		local Decal = Crack:FindFirstChildOfClass("Decal")

		for i = 1, FADE_STEPS do
			task.wait(FADE_WAIT)

			if Decal then
				Decal.Transparency = i / FADE_STEPS
			end

			Explosion.Transparency = i / FADE_STEPS
		end

		Crack:Destroy()
		Explosion:Destroy()
	end)
end

return VFX
