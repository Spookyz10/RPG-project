-- Forest v2 rigs. Static ornaments are welded; anatomical joints use Motor6D.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating Forest mobs")
local V = Vector3.new
local C = Color3.fromRGB
local bark = C(91, 65, 46)
local dark = C(43, 43, 37)
local moss = C(75, 119, 75)
local mint = C(128, 203, 167)
local ivory = C(219, 206, 159)
local gold = C(202, 160, 82)
local stone = C(99, 117, 112)
local function folder(parent, name)
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end
local staging = folder(nil, "Forest")
for _, species in { "Mosscap", "Thornback Stag", "Hollow Sentinel", "Elderbark" } do
	local model = Instance.new("Model")
	model.Name = species
	local serial = 0
	local function shape(name, size, pos, color, class, rotation)
		local p = Instance.new(class or "Part")
		p.Name = name
		p.Size = size
		p.CFrame = CFrame.new(pos) * (rotation or CFrame.identity)
		p.Color = color
		p.Material = Enum.Material.SmoothPlastic
		p.Anchored = false
		p.Massless = true
		p.CanCollide = false
		p.CanTouch = false
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Parent = model
		return p
	end
	local function joint(p, parent, pivot)
		local motor = Instance.new("Motor6D")
		motor.Name = p.Name .. "Joint"
		motor.Part0 = parent
		motor.Part1 = p
		local cf = CFrame.new(pivot or p.Position)
		motor.C0 = parent.CFrame:ToObjectSpace(cf)
		motor.C1 = p.CFrame:ToObjectSpace(cf)
		motor.Parent = parent
		return p
	end
	local function limb(name, size, pos, color, parent, pivot, rotation)
		return joint(shape(name, size, pos, color, nil, rotation), parent, pivot)
	end
	local function ornament(name, size, pos, color, parent, class, rotation)
		serial += 1
		local p = shape(name .. "_" .. serial, size, pos, color, class, rotation)
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = parent
		weld.Part1 = p
		weld.Parent = p
		return p
	end
	local function oval(name, size, pos, color, parent, rotation)
		local p = ornament(name, size, pos, color, parent, nil, rotation)
		p.Shape = Enum.PartType.Ball
		return p
	end
	local function branch(name, a, b, width, color, parent)
		return ornament(
			name,
			V(width, width, (b - a).Magnitude),
			(a + b) / 2,
			color,
			parent,
			nil,
			CFrame.lookAt(Vector3.zero, b - a)
		)
	end
	local function leaf(name, pos, size, color, parent, angle)
		return ornament(name, size, pos, color, parent, "WedgePart", CFrame.Angles(0.15, angle or 0, 0.22))
	end
	local function mushroom(pos, s, parent, color)
		branch("FungusStem", pos, pos + V(0, s * 1.2, 0), s * 0.3, ivory, parent)
		oval("FungusCap", V(1.9, 0.7, 1.6) * s, pos + V(0, s * 1.3, 0), color, parent)
	end
	local root = shape("HumanoidRootPart", V(2.4, 3, 2.2), Vector3.zero, bark)
	root.Transparency = 1
	root.CanCollide = true
	root.Massless = false
	model.PrimaryPart = root
	local torso, head
	if species == "Mosscap" then
		-- A hunched woodland forager: broad layered umbrella, gills and root fingers.
		torso = limb("Torso", V(2.8, 3.2, 2.5), V(0, 0, 0.25), ivory, root, V(0, 0, 0))
		oval("PearBody", V(3.4, 3.8, 2.9), V(0, -0.15, 0.35), ivory, torso)
		head = limb("Head", V(2.4, 2, 1.7), V(0, 1.25, -0.8), C(169, 178, 139), torso, V(0, 0.8, -0.3))
		oval("CapUnderside", V(6.8, 0.7, 5.5), V(-0.25, 2.6, -0.25), C(173, 193, 153), head)
		oval("VelvetCap", V(7.1, 2.1, 5.8), V(-0.25, 3.15, -0.15), C(62, 123, 111), head, CFrame.Angles(0, 0, -0.09))
		oval("CapCrown", V(4.6, 1.8, 4), V(-0.65, 3.95, 0.1), C(73, 143, 124), head)
		for i = 0, 11 do
			local a = i * math.pi / 6
			branch(
				"RadialGill",
				V(0, 2.3, -0.2),
				V(math.cos(a) * 2.9, 2.35, math.sin(a) * 2.25 - 0.2),
				0.12,
				ivory,
				head
			)
			if i % 2 == 0 then
				oval("CapFreckle", V(0.55, 0.18, 0.75), V(math.cos(a) * 2.1, 4, math.sin(a) * 1.6), mint, head)
			end
		end
		for _, side in { -1, 1 } do
			local arm = limb(
				side == 1 and "RightArm" or "LeftArm",
				V(0.75, 2.3, 0.85),
				V(side * 1.85, -0.55, -0.1),
				ivory,
				torso,
				V(side * 1.45, 0.7, 0),
				CFrame.Angles(0, 0, side * 0.2)
			)
			for finger = 1, 3 do
				branch(
					"RootFinger",
					V(side * 1.9 + (finger - 2) * 0.2, -1.55, -0.2),
					V(side * 2.1 + (finger - 2) * 0.25, -2.25, -0.6),
					0.18,
					bark,
					arm
				)
			end
			local leg = limb(
				side == 1 and "RightLeg" or "LeftLeg",
				V(0.9, 1.4, 1),
				V(side * 0.85, -2.15, 0.2),
				bark,
				torso,
				V(side * 0.8, -1.3, 0.2)
			)
			oval("RootSlipper", V(1.4, 0.65, 1.9), V(side * 0.85, -2.8, -0.2), moss, leg)
			leaf("LeafCollar", V(side * 1.1, 0.8, -1), V(1.3, 1.6, 1.3), moss, torso, side * 0.7)
		end
		-- Moss backpack with a miniature mushroom garden makes the rear readable too.
		oval("SporeSatchel", V(2.5, 2.5, 1.5), V(0.3, -0.1, 1.85), moss, torso)
		for i = 1, 3 do
			mushroom(V(-0.7 + i * 0.5, 0.8, 1.8), 0.5 + i * 0.1, torso, C(174, 129, 137))
		end
		ornament("FaceShadow", V(1.65, 0.55, 0.15), V(0, 1.35, -1.7), dark, head)
		for _, side in { -1, 1 } do
			oval("Eye", V(0.34, 0.45, 0.18), V(side * 0.53, 1.4, -1.8), gold, head)
		end
	elseif species == "Thornback Stag" then
		-- High shoulders, angled hocks and an antler crown with living leaves.
		torso = limb("Torso", V(3, 3.1, 5.6), V(0, 0, 0), bark, root, Vector3.zero)
		oval("Ribcage", V(3.5, 3.7, 5.5), V(0, 0.15, 0), C(112, 85, 58), torso)
		oval("Haunch", V(3, 3.2, 2.7), V(0, -0.1, 1.75), bark, torso)
		local neck =
			limb("Neck", V(1.7, 3.9, 1.8), V(0, 2, -2.1), bark, torso, V(0, 0.8, -1.8), CFrame.Angles(-0.24, 0, 0))
		leaf("ChestRuff", V(0, 1, -3), V(2.3, 3.7, 1.7), ivory, neck, math.pi)
		head = limb("Head", V(1.7, 1.65, 2.5), V(0, 4, -3.2), C(119, 92, 66), neck, V(0, 3.35, -2.5))
		oval("Cheeks", V(1.9, 1.8, 2.6), V(0, 4, -3.2), C(119, 92, 66), head)
		oval("Muzzle", V(1.2, 0.95, 2), V(0, 3.6, -4.5), ivory, head)
		oval("Nose", V(0.9, 0.5, 0.4), V(0, 3.7, -5.45), dark, head)
		for _, side in { -1, 1 } do
			leaf("Ear", V(side * 1.3, 4.5, -2.8), V(1.65, 0.6, 1), bark, head, side * 0.4)
			oval("Eye", V(0.18, 0.32, 0.4), V(side * 0.88, 4.2, -3.9), gold, head)
			for _, rear in { -1, 1 } do
				local prefix = (rear == 1 and "Back" or "Front") .. (side == 1 and "Right" or "Left")
				local hip = V(side * 1.1, -0.8, rear * 1.9)
				local knee = V(side * 1.2, -2.6, rear * 1.9 + (rear == 1 and 0.55 or -0.25))
				local foot = V(side * 1.2, -4.4, rear * 1.9 - 0.15)
				local upper = limb(
					prefix .. "Leg",
					V(0.8, (knee - hip).Magnitude, 0.9),
					(hip + knee) / 2,
					bark,
					torso,
					hip,
					CFrame.lookAt(Vector3.zero, knee - hip) * CFrame.Angles(math.pi / 2, 0, 0)
				)
				local lower = limb(
					prefix .. "Shin",
					V(0.5, (foot - knee).Magnitude, 0.55),
					(knee + foot) / 2,
					ivory,
					upper,
					knee,
					CFrame.lookAt(Vector3.zero, foot - knee) * CFrame.Angles(math.pi / 2, 0, 0)
				)
				oval("Knee", V(0.9, 0.8, 0.9), knee, bark, upper)
				ornament("ClovenHoof", V(0.85, 0.65, 1.15), foot, dark, lower)
				ornament("HoofSplit", V(0.08, 0.5, 0.1), foot + V(0, 0, -0.58), ivory, lower)
			end
			local antlerPoints = {
				V(side * 0.6, 4.65, -2.8),
				V(side * 1.2, 6, -2.45),
				V(side * 2.4, 7.4, -1.9),
				V(side * 3.5, 8.3, -1.5),
			}
			for i = 1, 3 do
				branch("AntlerBeam", antlerPoints[i], antlerPoints[i + 1], 0.48 - i * 0.08, ivory, head)
				local tip = antlerPoints[i + 1] + V(side * 0.3, 1.3, -1.2)
				branch("AntlerTine", antlerPoints[i + 1], tip, 0.22, ivory, head)
				if i ~= 2 then
					leaf("AntlerLeaf", tip, V(1.1, 0.6, 1.5), moss, head, side)
				end
			end
			for i = 1, 5 do
				leaf(
					"BarkFlank",
					V(side * 1.55, 0.9, -2 + i * 0.75),
					V(0.5, 1.5, 1.4),
					i % 2 == 0 and moss or C(134, 112, 70),
					torso,
					side * 0.2
				)
				oval("FawnMark", V(0.12, 0.2, 0.32), V(side * 1.73, 0.2, -1.6 + i * 0.65), ivory, torso)
			end
		end
		local tail =
			limb("Tail", V(0.65, 0.8, 1.8), V(0, 0.2, 3.5), ivory, torso, V(0, 0.4, 2.5), CFrame.Angles(0.4, 0, 0))
		leaf("TailLeaf", V(0, 0.25, 4), V(1, 0.7, 1.7), moss, tail)
	elseif species == "Hollow Sentinel" then
		-- A walking ruined shrine: open rib cage, inset relic and unequal shoulders.
		root.Size = V(3, 4, 2.5)
		torso = limb("Torso", V(1, 4.2, 1), Vector3.zero, dark, root, Vector3.zero)
		torso.Transparency = 1
		ornament("BackSlab", V(3.8, 4.2, 0.8), V(0, 0, 1), stone, torso)
		for _, side in { -1, 1 } do
			ornament("ChestPillar", V(0.8, 4.2, 1.8), V(side * 1.6, 0, 0), stone, torso)
			for i = 1, 3 do
				leaf("RibStone", V(side * 1.1, 1.4 - i * 0.85, -0.45), V(1.3, 0.48, 1.8), stone, torso, side * 0.2)
			end
			local arm = limb(
				side == 1 and "RightArm" or "LeftArm",
				V(1.3, 3.8, 1.5),
				V(side * 2.8, -0.5, 0),
				stone,
				torso,
				V(side * 2, 1.55, 0),
				CFrame.Angles(0, 0, side * 0.08)
			)
			ornament("ShoulderCapital", V(side == 1 and 2.6 or 2, 1.5, 2.5), V(side * 2.6, 1.75, 0), stone, arm)
			leaf("ShoulderGarden", V(side * 2.6, 2.6, 0), V(2.5, 0.7, 2.5), moss, arm)
			local hand = limb(
				side == 1 and "RightHand" or "LeftHand",
				V(1.7, 1.5, 1.8),
				V(side * 3, -3, 0),
				stone,
				arm,
				V(side * 3, -2.2, 0)
			)
			for i = 1, 3 do
				ornament("StoneDigit", V(0.4, 0.9, 0.7), V(side * 3 + (i - 2) * 0.5, -3.7, -0.5), dark, hand)
			end
			local leg = limb(
				side == 1 and "RightLeg" or "LeftLeg",
				V(1.25, 2.6, 1.5),
				V(side * 1.15, -3.1, 0.1),
				stone,
				torso,
				V(side * 1.15, -1.8, 0.1)
			)
			ornament("PedestalFoot", V(2.1, 0.8, 2.7), V(side * 1.15, -4.55, -0.3), stone, leg)
			ornament("KneeBand", V(1.45, 0.5, 1.7), V(side * 1.15, -3.1, 0.1), gold, leg)
		end
		ornament("ChestLintel", V(4.2, 0.7, 2.1), V(0, 2, 0), stone, torso)
		ornament("WaistPlinth", V(3.8, 0.75, 2.3), V(0, -1.9, 0), stone, torso)
		local core = oval("SuspendedRelic", V(0.85, 1.9, 0.85), V(0, 0.2, -0.1), mint, torso, CFrame.Angles(0, 0, 0.3))
		core.Material = Enum.Material.Neon
		branch("RelicTether", V(0, 1.7, 0), V(0, 1, -0.1), 0.12, gold, torso)
		head = limb("Head", V(2, 2.1, 1.8), V(0, 3.4, 0), stone, torso, V(0, 2.35, 0))
		leaf("BrokenHood", V(-0.2, 4.1, 0.3), V(2.7, 2.1, 2.5), stone, head, math.pi)
		ornament("FaceRecess", V(1.55, 1.3, 0.2), V(0, 3.35, -0.94), dark, head)
		ornament("SingleVisor", V(1.25, 0.2, 0.15), V(0, 3.55, -1.08), mint, head).Material = Enum.Material.Neon
		ornament("NoseKeystone", V(0.35, 0.8, 0.4), V(0, 3.2, -1.1), stone, head)
		for i = 1, 3 do
			mushroom(V(-2.7 + (i - 2) * 0.45, 2.8, 0), 0.45 + i * 0.1, model:FindFirstChild("LeftArm"), mint)
		end
		for i = 1, 4 do
			leaf("TrailingIvy", V(1.9, 2 - i * 0.65, 1.1), V(0.8, 1.1, 0.4), moss, torso, i * 0.6)
		end
	else
		-- Elderbark is a broad, crooked ancient tree, not an enlarged Sentinel.
		root.Size = V(5, 7, 4)
		torso = limb("Torso", V(5.5, 7, 4), V(0, 0.3, 0.3), bark, root, Vector3.zero)
		oval("AncientTrunk", V(6.5, 8, 4.8), V(0, 0.3, 0.5), bark, torso)
		for i = 0, 7 do
			local a = i * math.pi / 4
			branch(
				"TwistedBark",
				V(math.cos(a) * 2.4, -3, math.sin(a) * 1.7 + 0.5),
				V(math.cos(a + 0.3) * 2.8, 4.2, math.sin(a + 0.3) * 2 + 0.5),
				0.7,
				i % 2 == 0 and dark or C(120, 87, 55),
				torso
			)
		end
		oval("HeartHollow", V(2.7, 3.6, 0.5), V(0, 0.5, -2), dark, torso)
		local heart = oval("HeartSeed", V(1.2, 2, 0.6), V(0, 0.4, -2.35), gold, torso)
		heart.Material = Enum.Material.Neon
		for _, side in { -1, 1 } do
			branch("HeartRoot", V(side * 1.4, -1.4, -2.1), V(side * 0.6, 2.2, -2), 0.35, moss, torso)
			local shoulder = V(side * 3, 2.8, 0.2)
			local elbow = V(side * (side == 1 and 5.2 or 4.6), -0.2, 0.1)
			local handPos = V(side * (side == 1 and 6.2 or 5.2), -3.3, -0.5)
			local arm = limb(
				side == 1 and "RightArm" or "LeftArm",
				V(2.1, 4, 2.3),
				(shoulder + elbow) / 2,
				bark,
				torso,
				shoulder,
				CFrame.Angles(0, 0, side * 0.4)
			)
			local forearm = limb(
				side == 1 and "RightForearm" or "LeftForearm",
				V(1.65, 3.3, 1.8),
				(elbow + handPos) / 2,
				bark,
				arm,
				elbow,
				CFrame.Angles(0, 0, side * 0.2)
			)
			oval("KnottedElbow", V(2.3, 2.1, 2.2), elbow, dark, arm)
			oval("RootPalm", V(2.3, 1.6, 1.7), handPos, bark, forearm)
			for finger = 1, 4 do
				local a = handPos + V((finger - 2.5) * 0.45, -0.5, -0.2)
				local b = a + V(side * 0.3, -1.4, -0.5)
				branch("RootDigit", a, b, 0.32, bark, forearm)
				branch("RootClaw", b, b + V(-side * 0.15, -0.3, -0.7), 0.22, ivory, forearm)
			end
			local leg = limb(
				side == 1 and "RightLeg" or "LeftLeg",
				V(2, 3.5, 2.4),
				V(side * 1.65, -4.6, 0.5),
				bark,
				torso,
				V(side * 1.7, -2.8, 0.5)
			)
			for toe = 1, 3 do
				branch(
					"ButtressToe",
					V(side * 1.65, -5.2, 0.5),
					V(side * 1.65 + (toe - 2) * 1.1, -6.5, -1.7),
					0.8,
					bark,
					leg
				)
			end
			for i = 1, 3 do
				leaf(
					"ShoulderFoliage",
					shoulder + V(side * i * 0.4, 1 + i * 0.25, 0.2),
					V(3.2, 1.6, 3.2),
					i % 2 == 0 and moss or C(98, 137, 77),
					arm,
					i * 0.8
				)
			end
		end
		head =
			limb("Head", V(3, 3.2, 2.5), V(-0.35, 5.1, -0.6), bark, torso, V(-0.2, 3.7, 0), CFrame.Angles(0, 0, -0.08))
		ornament("FaceHollow", V(2.3, 1.8, 0.25), V(-0.35, 5, -1.94), dark, head)
		for _, side in { -1, 1 } do
			leaf("HeavyBrow", V(-0.35 + side * 0.7, 5.6, -2.1), V(1.3, 0.5, 0.5), C(130, 97, 61), head, side * 0.15)
			ornament("AmberEye", V(0.5, 0.26, 0.2), V(-0.35 + side * 0.65, 5.25, -2.15), gold, head).Material =
				Enum.Material.Neon
			local points =
				{ V(side, 6.2, 0), V(side * 2.3, 8, 0.3), V(side * 3.1, 10.1, 0.7), V(side * 4.6, 11.5, 0.2) }
			for i = 1, 3 do
				branch("CrownBough", points[i], points[i + 1], 0.9 - i * 0.16, bark, head)
				local tip = points[i + 1] + V(-side * 0.6, 1.5, -0.9)
				branch("CrownFork", points[i + 1], tip, 0.32, bark, head)
				if i > 1 then
					leaf("CrownLeafFan", tip, V(3.5, 1.1, 3.2), moss, head, side * i)
				end
			end
		end
		for i = 1, 5 do
			branch(
				"RootBeard",
				V(-1.6 + i * 0.45, 4.5, -1.95),
				V(-1.8 + i * 0.5, 2.9 - (i % 2) * 0.5, -2.2),
				0.23,
				C(128, 131, 82),
				head
			)
		end
		for i = 1, 4 do
			mushroom(V(2.65, -1 + i * 1.1, 0.5), 0.65 + i * 0.12, torso, C(185, 143, 91))
		end
		oval("BackMoss", V(4.5, 4.3, 1), V(0, 1.3, 2.8), moss, torso)
	end
	-- Feet are authored relative to the root; calculate clearance from the actual rig.
	local lowest = math.huge
	for _, p in model:GetChildren() do
		if p:IsA("BasePart") and p ~= root then
			local cf = p.CFrame
			local halfY = (
				math.abs(cf.RightVector.Y) * p.Size.X
				+ math.abs(cf.UpVector.Y) * p.Size.Y
				+ math.abs(cf.LookVector.Y) * p.Size.Z
			) / 2
			lowest = math.min(lowest, p.Position.Y - halfY)
		end
	end
	local hum = Instance.new("Humanoid")
	hum.RequiresNeck = false
	hum.BreakJointsOnDeath = false
	hum.HipHeight = math.max(0, -lowest - root.Size.Y / 2)
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	hum.Parent = model
	Instance.new("Animator").Parent = hum
	model:SetAttribute("AssetStage", "ModelsOnly")
	model:SetAttribute("DesignVersion", 2)
	model.Parent = staging
end
local rs, ss = game:GetService("ReplicatedStorage"), game:GetService("ServerStorage")
local destination = rs:FindFirstChild("Mobs") or folder(rs, "Mobs")
local old = destination:FindFirstChild("Forest")
if old then
	local backups = ss:FindFirstChild("WorldGeneratorBackups") or folder(ss, "WorldGeneratorBackups")
	old.Parent = folder(backups, "ForestMobs_" .. os.date("%Y%m%d_%H%M%S"))
end
staging.Parent = destination
game:GetService("Selection"):Set({ staging })
print("Forest v2 rigs: Mosscap forager, Thornback Stag, shrine Sentinel and ancient Elderbark. Models only.")
