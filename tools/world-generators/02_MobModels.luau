-- Standalone Edit-mode generator. All limbs are Motor6D connected, ready for animation.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play first")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local function folder(parent, name)
	local f = parent:FindFirstChild(name) or Instance.new("Folder"); f.Name = name; f.Parent = parent; return f
end
local staging = Instance.new("Folder"); staging.Name = "Grasslands"
local definitions = {
	{"Bushling", Color3.fromRGB(75, 135, 53), Vector3.new(3, 3, 2.5)},
	{"Wolf", Color3.fromRGB(132, 145, 155), Vector3.new(3, 3, 5)},
	{"Boar", Color3.fromRGB(110, 78, 57), Vector3.new(4, 3, 5)},
	{"Dire Bear", Color3.fromRGB(65, 48, 40), Vector3.new(7, 6, 9)},
}
for _, def in definitions do
	local model = Instance.new("Model"); model.Name = def[1]
	local function body(name, size, pos, color, parentPart, shape, rotation)
		local p = Instance.new(shape or "Part"); p.Name = name; p.Size = size; p.Position = pos
		p.CFrame = CFrame.new(pos) * (rotation or CFrame.identity)
		p.Color = color; p.Material = Enum.Material.SmoothPlastic; p.Anchored = false
		p.CanCollide = false; p.Massless = true; p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
		p.Parent = model
		if parentPart then
			local motor = Instance.new("Motor6D"); motor.Name = name .. "Joint"
			motor.Part0 = parentPart; motor.Part1 = p; motor.C0 = parentPart.CFrame:ToObjectSpace(p.CFrame); motor.Parent = parentPart
		end
		return p
	end
	local size = def[3]
	local root = body("HumanoidRootPart", Vector3.new(size.X * 0.7, size.Y, size.Z * 0.7), Vector3.zero, def[2])
	root.Transparency = 1; root.CanCollide = true; root.Massless = false; model.PrimaryPart = root
	local torso = body("Torso", size, Vector3.zero, def[2], root)
	local head = body("Head", Vector3.new(size.X * 0.8, size.Y * 0.8, size.X * 0.7), Vector3.new(0, size.Y * 0.25, -size.Z * 0.57), def[2], torso)
	for _, side in {-1, 1} do
		body("Eye", Vector3.new(0.28, 0.3, 0.2), head.Position + Vector3.new(side * size.X * 0.22, 0.3, -head.Size.Z / 2), Color3.fromRGB(255, 216, 98), head)
		body("Ear", Vector3.new(size.X * 0.25, size.Y * 0.4, size.X * 0.22), head.Position + Vector3.new(side * size.X * 0.3, head.Size.Y * 0.6, 0), def[2], head)
		for _, rear in {-1, 1} do
			body((rear == 1 and "Back" or "Front") .. (side == 1 and "RightLeg" or "LeftLeg"), Vector3.new(size.X * 0.28, size.Y * 0.75, size.X * 0.3), Vector3.new(side * size.X * 0.36, -size.Y * 0.55, rear * size.Z * 0.32), def[2], torso)
		end
		if def[1] == "Boar" then
			body("Tusk", Vector3.new(0.4, 1.3, 0.45), head.Position + Vector3.new(side * 1.1, -0.3, -head.Size.Z * 0.65), Color3.fromRGB(247, 232, 191), head)
		end
	end
	-- Layered facets use a restrained woodland palette and follow their parent joints.
	local dark = def[2]:Lerp(Color3.fromRGB(28, 35, 32), 0.35)
	local light = def[2]:Lerp(Color3.fromRGB(210, 201, 168), 0.3)
	local cream = Color3.fromRGB(227, 219, 188)
	local function facet(name, dimensions, offset, color, parentPart, angles)
		return body(name, dimensions, parentPart.Position + offset, color, parentPart, "WedgePart", angles or CFrame.identity)
	end
	if def[1] == "Bushling" then
		torso.Color = Color3.fromRGB(110, 83, 52)
		head.Color = Color3.fromRGB(91, 113, 53)
		for i = 1, 7 do
			local angle = i / 7 * math.pi * 2
			facet("LeafCrown", Vector3.new(1.8, 2.4, 2.6), Vector3.new(math.sin(angle) * 1.2, 1.8, math.cos(angle) * 1.1), i % 2 == 0 and Color3.fromRGB(132, 170, 77) or Color3.fromRGB(77, 133, 64), torso, CFrame.Angles(0, angle, math.rad(14)))
		end
		for _, side in {-1, 1} do
			facet("LeafCheek", Vector3.new(1.2, 1.6, 1.7), Vector3.new(side * 1.15, 0, 0), light, head, CFrame.Angles(0, side * 0.5, side * 0.3))
			body("Berry", Vector3.new(0.45, 0.45, 0.45), torso.Position + Vector3.new(side * 0.65, 2.8, -0.7), Color3.fromRGB(207, 120, 99), torso)
		end
	elseif def[1] == "Wolf" then
		facet("BackFur", Vector3.new(2.7, 1.1, 4.7), Vector3.new(0, 1.3, 0.3), dark, torso)
		facet("ChestRuff", Vector3.new(3.3, 3.5, 2.2), Vector3.new(0, -0.1, -1.6), light, torso, CFrame.Angles(0, math.pi, 0))
		body("Muzzle", Vector3.new(1.35, 0.9, 1.8), head.Position + Vector3.new(0, -0.35, -1.1), cream, head)
		body("Nose", Vector3.new(0.7, 0.45, 0.3), head.Position + Vector3.new(0, -0.12, -2.05), dark, head)
		facet("Tail", Vector3.new(1.2, 1.5, 3.4), Vector3.new(0, 0.2, 3.6), dark, torso, CFrame.Angles(-0.3, 0, 0))
		for _, side in {-1, 1} do
			facet("EarTip", Vector3.new(0.9, 1.7, 0.7), Vector3.new(side * 0.9, 1.65, 0), dark, head)
			facet("CheekFur", Vector3.new(1, 1.7, 1.7), Vector3.new(side * 1.1, -0.25, 0.2), light, head, CFrame.Angles(0, side * 0.5, 0))
		end
	elseif def[1] == "Boar" then
		facet("ShoulderMantle", Vector3.new(4.4, 2.6, 3), Vector3.new(0, 0.8, -0.7), dark, torso)
		body("Snout", Vector3.new(2, 1.3, 1.4), head.Position + Vector3.new(0, -0.45, -1.3), Color3.fromRGB(165, 124, 95), head)
		for _, side in {-1, 1} do
			body("Nostril", Vector3.new(0.25, 0.35, 0.15), head.Position + Vector3.new(side * 0.47, -0.35, -2.04), dark, head)
			facet("TuskTip", Vector3.new(0.65, 1.9, 0.65), Vector3.new(side * 1.3, -0.25, -1.8), cream, head, CFrame.Angles(-0.25, 0, -side * 0.25))
		end
		for i = 1, 5 do facet("Bristle", Vector3.new(0.7, 1.1, 0.8), Vector3.new(0, 1.7, -1.8 + i * 0.7), dark, torso) end
	else
		facet("ShoulderHump", Vector3.new(7.9, 4, 5.5), Vector3.new(0, 1.8, -1.5), dark, torso)
		facet("Chest", Vector3.new(5.6, 4.5, 2.1), Vector3.new(0, -0.5, -3.8), light, torso, CFrame.Angles(0, math.pi, 0))
		body("Muzzle", Vector3.new(3.4, 2, 2.2), head.Position + Vector3.new(0, -0.8, -2.3), Color3.fromRGB(152, 123, 90), head)
		body("Nose", Vector3.new(1.8, 0.85, 0.5), head.Position + Vector3.new(0, -0.35, -3.5), dark, head)
		for _, side in {-1, 1} do
			facet("Brow", Vector3.new(2.2, 0.6, 0.6), Vector3.new(side * 1.4, 0.8, -2.5), dark, head, CFrame.Angles(0, 0, side * 0.15))
			facet("ShoulderFur", Vector3.new(2.1, 3.8, 4.2), Vector3.new(side * 3.5, 0.4, -1.5), light, torso, CFrame.Angles(0, 0, side * 0.2))
		end
	end
	-- Distinct paws and claws articulate with the original leg joints.
	for _, limb in model:GetChildren() do
		if limb:IsA("BasePart") and string.find(limb.Name, "Leg") then
			local paw = body("Paw", Vector3.new(limb.Size.X * 1.2, 0.55, limb.Size.Z * 1.35), limb.Position + Vector3.new(0, -limb.Size.Y / 2 + 0.15, -0.15), dark, limb)
			if def[1] == "Dire Bear" then
				for toe = -1, 1 do facet("Claw", Vector3.new(0.35, 0.45, 1.15), Vector3.new(toe * 0.55, -0.02, -paw.Size.Z / 2), cream, paw, CFrame.Angles(math.pi, 0, 0)) end
			end
		end
	end

	local hum = Instance.new("Humanoid"); hum.RequiresNeck = false; hum.BreakJointsOnDeath = false
	hum.HipHeight = size.Y * 0.45; hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None; hum.Parent = model
	Instance.new("Animator").Parent = hum
	model.Parent = staging
end
local destination = folder(RS, "Mobs")
local backup = folder(folder(SS, "WorldGeneratorBackups"), "Mobs_" .. os.date("%Y%m%d_%H%M%S"))
-- Remove duplicate templates with these names from lookup, retaining them as backups.
for _, old in destination:GetDescendants() do
	if old:IsA("Model") and staging:FindFirstChild(old.Name) then old.Parent = backup end
end
local old = destination:FindFirstChild("Grasslands")
if old then old.Parent = backup end
staging.Parent = destination
game:GetService("Selection"):Set({staging})
print("Four editable low-poly mob rigs saved in ReplicatedStorage.Mobs.Grasslands.")
