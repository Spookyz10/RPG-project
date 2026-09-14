-- Paste the entire file into Studio's Command Bar with Play stopped.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating the lobby.")
local SS = game:GetService("ServerStorage")
local History = game:GetService("ChangeHistoryService")
local ORIGIN = Vector3.new(0, 0, 0)
local rng = Random.new(82418)
local V = Vector3.new
local CF = CFrame.new
local ANG = CFrame.Angles
local C = {
	Grass = Color3.fromRGB(112, 157, 76), Leaf = Color3.fromRGB(77, 128, 61),
	LeafLight = Color3.fromRGB(136, 171, 83), Stone = Color3.fromRGB(105, 119, 106),
	Light = Color3.fromRGB(204, 202, 172), Dark = Color3.fromRGB(52, 67, 65),
	Path = Color3.fromRGB(188, 176, 139), Wood = Color3.fromRGB(91, 64, 44),
	Timber = Color3.fromRGB(153, 113, 71), Plaster = Color3.fromRGB(227, 216, 182),
	Teal = Color3.fromRGB(58, 109, 106), Slate = Color3.fromRGB(69, 80, 91),
	Gold = Color3.fromRGB(229, 179, 75), Blue = Color3.fromRGB(78, 183, 240),
	Red = Color3.fromRGB(219, 81, 76), Violet = Color3.fromRGB(167, 122, 214),
	Ice = Color3.fromRGB(149, 223, 230), Ember = Color3.fromRGB(255, 157, 66),
}
local function group(parent, name, class)
	local result = Instance.new(class or "Model")
	result.Name = name
	result.Parent = parent
	return result
end
local staging = Instance.new("Folder")
local map = group(staging, "Lobby", "Folder")
map:SetAttribute("GeneratorVersion", 2)
map:SetAttribute("GeneratedBy", "tools/world-generators/00_Lobby.luau")
local ground = group(map, "Ground")
local paths = group(map, "Paths")
local gardens = group(map, "Gardens")
local cliffs = group(map, "Cliffs")
local landmarks = group(map, "Landmarks", "Folder")
local boards = group(landmarks, "Leaderboards", "Folder")

local function part(parent, name, size, frame, color, class)
	local p = Instance.new(class or "Part")
	p.Name = name
	p.Size = size
	p.CFrame = CF(ORIGIN) * frame
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local function deco(p)
	p.CanCollide = false
	p.CanQuery = false
	return p
end
local function block(parent, base, name, size, pos, color, rotation, class)
	return part(parent, name, size, base * CF(pos) * (rotation or CFrame.identity), color, class)
end
local function cylinder(parent, name, height, diameter, frame, color)
	local p = part(parent, name, V(height, diameter, diameter), frame * ANG(0, 0, math.pi / 2), color)
	p.Shape = Enum.PartType.Cylinder
	return p
end
local function disc(parent, name, diameter, top, thickness, x, z, color)
	return cylinder(parent, name, thickness, diameter, CF(x, top - thickness / 2, z), color)
end
local function beam(parent, name, a, b, width, depth, color, base)
	local midpoint = (a + b) / 2
	local frame = CFrame.lookAt(midpoint, b)
	return part(parent, name, V(width, depth, (b - a).Magnitude), (base or CFrame.identity) * frame, color)
end
local function glow(p, range, brightness)
	p.Material = Enum.Material.Neon
	local light = Instance.new("PointLight")
	light.Color = p.Color
	light.Range = range
	light.Brightness = brightness
	light.Parent = p
	return p
end
local function face(x, z)
	return CFrame.lookAt(V(x, 0, z), V(0, 0, 0))
end

-- Shared roof geometry: inward slopes meet at a single computed ridge.
-- The gables use the same run/rise, so there are no floating caps or open triangles.
local function roof(parent, base, width, depth, eave, rise, color)
	local run = width / 2
	local slope = math.sqrt(run * run + rise * rise)
	local pitch = math.atan2(rise, run)
	local roofModel = group(parent, "Roof")
	for _, side in {-1, 1} do
		local rotation = ANG(0, 0, -side * pitch)
		block(roofModel, base, "RoofSlope", V(slope, 0.8, depth), V(side * run / 2, eave + rise / 2, 0), color, rotation)
		-- Raised seams follow the roof plane instead of being positioned independently.
		for z = -depth / 2 + 1, depth / 2 - 0.5, 4 do
			local plane = base * CF(side * run / 2, eave + rise / 2, z) * rotation
			part(roofModel, "StandingSeam", V(slope, 0.14, 0.18), plane * CF(0, 0.46, 0), C.Dark)
		end
		block(roofModel, base, "EaveTrim", V(1, 1.2, depth + 0.8), V(side * run, eave, 0), C.Wood)
		for _, endSide in {-1, 1} do
			local z = endSide * (depth / 2 - 1.5)
			block(roofModel, base, "Gable", V(0.65, rise, run), V(side * run / 2, eave + rise / 2, z), C.Plaster, ANG(0, -side * math.pi / 2, 0), "WedgePart")
			beam(roofModel, "GableRafter", V(0, eave + rise, endSide * depth / 2),
				V(side * run, eave, endSide * depth / 2), 0.9, 0.9, C.Timber, base)
		end
	end
	block(roofModel, base, "RidgeCap", V(1.3, 0.9, depth + 1), V(0, eave + rise + 0.35, 0), C.Wood)
end
local function lantern(parent, base, x, z)
	local m = group(parent, "Lantern")
	block(m, base, "Foot", V(2.2, 0.5, 2.2), V(x, 0.25, z), C.Stone)
	block(m, base, "Post", V(0.55, 6.5, 0.55), V(x, 3.5, z), C.Wood)
	local lamp = deco(block(m, base, "WarmGlass", V(1.3, 1.6, 1.3), V(x, 6.9, z), C.Ember))
	glow(lamp, 15, 0.55)
	block(m, base, "Cap", V(2, 0.35, 2), V(x, 7.9, z), C.Dark)
end

-- A landscaped circular courtyard: all platforms really are cylinders.
disc(ground, "IslandFoundation", 342, -0.4, 13, 0, 0, C.Stone)
disc(ground, "Lawn", 338, 0, 2, 0, 0, C.Grass)
disc(paths, "PlazaBorder", 79, 0.16, 0.2, 0, 0, C.Dark)
disc(paths, "PlazaPaving", 75, 0.22, 0.22, 0, 0, C.Light)
disc(paths, "InnerBorder", 60, 0.27, 0.12, 0, 0, C.Path)
disc(paths, "InnerPaving", 57, 0.31, 0.1, 0, 0, C.Light)
for i = 0, 15 do
	local a = i * math.pi / 8
	deco(part(paths, "RadialInlay", V(0.2, 0.06, 7), CF(math.sin(a) * 33, 0.35, math.cos(a) * 33) * ANG(0, a, 0), C.Dark))
end
local destinations = {
	V(-72, 0, -5), V(72, 0, -5), V(-40, 0, -88), V(40, 0, -88),
	V(0, 0, 80), V(-101, 0, 64), V(-48, 0, 119), V(48, 0, 119), V(101, 0, 64),
}
for _, destination in destinations do
	local direction = destination.Unit
	local start = direction * 29
	beam(paths, "PathBorder", start + V(0, 0.08, 0), destination + V(0, 0.08, 0), 13, 0.16, C.Stone)
	beam(paths, "Path", start + V(0, 0.18, 0), destination + V(0, 0.18, 0), 11.6, 0.1, C.Path)
end
local spawn = part(map, "LobbySpawn", V(10, 0.2, 10), CF(0, 0.42, -6), C.Light, "SpawnLocation")
spawn.Transparency = 1
spawn.Neutral = true
spawn.Enabled = true
spawn.Duration = 0
spawn.AllowTeamChangeOnTouch = false

-- Low fountain sits behind the spawn and leaves the center/front approach clear.
local fountain = group(landmarks, "Fountain")
disc(fountain, "Foot", 14, 0.55, 0.4, 0, 15, C.Stone)
disc(fountain, "Basin", 12, 1.3, 0.8, 0, 15, C.Light)
deco(disc(fountain, "Water", 10.7, 1.34, 0.12, 0, 15, C.Teal))
cylinder(fountain, "Stem", 3, 2.8, CF(0, 2.8, 15), C.Stone)
disc(fountain, "UpperBowl", 6, 4.5, 0.55, 0, 15, C.Light)
deco(disc(fountain, "UpperWater", 5.2, 4.54, 0.1, 0, 15, C.Ice))
for i = 0, 7 do
	local a = i * math.pi / 4
	local p = deco(beam(fountain, "WaterStream", V(math.sin(a) * 2.6, 4.4, 15 + math.cos(a) * 2.6),
		V(math.sin(a) * 4.1, 1.5, 15 + math.cos(a) * 4.1), 0.13, 0.13, C.Ice))
	p.Transparency = 0.35
end

local function building(name, x, z, forge)
	local m = group(landmarks, name)
	local base = face(x, z)
	block(m, base, "Foundation", V(39, 0.6, 31), V(0, 0.3, 0), C.Stone)
	block(m, base, "Floor", V(35, 0.15, 28), V(0, 0.67, 0), C.Path)
	block(m, base, "FrontStep", V(22, 0.3, 3), V(0, 0.15, -16.5), C.Light)
	block(m, base, "BackWall", V(34, 13, 1.2), V(0, 7, 12), forge and C.Stone or C.Plaster)
	for _, side in {-1, 1} do
		block(m, base, "SideWall", V(1.2, 13, 25), V(side * 16.5, 7, 0), forge and C.Stone or C.Plaster)
		for _, zz in {-12, 0, 12} do
			block(m, base, "TimberPost", V(1.2, 13.4, 1.2), V(side * 16.5, 7, zz), C.Wood)
		end
		block(m, base, "WallSill", V(1.6, 0.8, 26), V(side * 16.5, 3.5, 0), C.Timber)
		lantern(m, base, side * 16, -16)
	end
	block(m, base, "FrontLintel", V(34, 1.1, 1.4), V(0, 13.1, -12), C.Wood)
	roof(m, base, 38, 30, 13.5, 7, forge and C.Slate or C.Teal)
	if forge then
		-- Open hearth: the glowing coal bed is visible between two piers.
		block(m, base, "Hearth", V(12, 2, 8), V(-8, 1.7, 7), C.Dark)
		for _, side in {-1, 1} do
			block(m, base, "HearthPier", V(2.4, 7, 8), V(-8 + side * 5, 5.3, 7), C.Stone)
		end
		glow(deco(block(m, base, "Coals", V(7, 0.5, 5), V(-8, 2.9, 6), C.Ember)), 17, 0.9)
		block(m, base, "HearthHood", V(13, 2, 9), V(-8, 9.6, 7), C.Dark)
		block(m, base, "Chimney", V(5.5, 18, 6), V(-8, 19.5, 8), C.Stone)
		for yy = 13, 28, 3 do
			block(m, base, "ChimneyCourse", V(5.8, 0.25, 6.3), V(-8, yy, 8), C.Dark)
		end
		block(m, base, "ChimneyLip", V(7, 0.7, 7.5), V(-8, 28.7, 8), C.Light)
		block(m, base, "ChimneyOpening", V(4.7, 0.1, 5.2), V(-8, 29.1, 8), C.Dark)
		block(m, base, "AnvilStump", V(4, 3, 4), V(4, 2.2, -4), C.Wood)
		block(m, base, "AnvilFoot", V(5, 0.7, 3), V(4, 4, -4), C.Dark)
		block(m, base, "AnvilWaist", V(2.5, 1.4, 2.2), V(4, 4.9, -4), C.Slate)
		block(m, base, "AnvilTop", V(6, 0.65, 3), V(4, 5.9, -4), C.Light)
		block(m, base, "AnvilHorn", V(3, 0.8, 3), V(8, 5.7, -4), C.Light, ANG(0, math.pi / 2, 0), "WedgePart")
		block(m, base, "ToolRack", V(8, 0.5, 1), V(10, 9, 10.8), C.Timber)
		for xx = 7, 13, 3 do
			block(m, base, "HammerHandle", V(0.35, 3.5, 0.35), V(xx, 7.5, 10), C.Wood)
			block(m, base, "HammerHead", V(1.9, 1, 1), V(xx, 9, 10), C.Dark)
		end
	else
		-- Walk-in shop with a side counter and an unobstructed central aisle.
		block(m, base, "Counter", V(10, 3.8, 5), V(-9, 2.7, -6), C.Timber)
		block(m, base, "CounterTop", V(11, 0.55, 6), V(-9, 4.85, -6), C.Wood)
		for yy = 3, 9, 3 do
			block(m, base, "Shelf", V(25, 0.4, 3), V(0, yy, 10.5), C.Wood)
			for xx = -9, 9, 4.5 do
				local bottle = block(m, base, "Potion", V(1.3, 1.5, 1.3), V(xx, yy + 1, 10.5), xx < 0 and C.Blue or C.Red)
				bottle.Shape = Enum.PartType.Ball
				block(m, base, "BottleNeck", V(0.5, 0.6, 0.5), V(xx, yy + 2, 10.5), C.Gold)
			end
		end
		for i = 0, 5 do
			local awning = block(m, base, "StripedAwning", V(5.5, 0.35, 6), V(-13.75 + i * 5.5, 11.4, -15), i % 2 == 0 and C.Teal or C.Plaster, ANG(math.rad(-12), 0, 0))
			deco(awning)
		end
		for _, xx in {9, 13} do
			block(m, base, "Crate", V(3.2, 3.2, 3.2), V(xx, 2.3, 2), C.Timber)
			for _, offset in {-1.1, 1.1} do
				block(m, base, "CrateBand", V(0.3, 3.3, 3.3), V(xx + offset, 2.3, 2), C.Wood)
			end
		end
	end
	return m
end
building("Shop", -92, -8, false)
building("Blacksmith", 92, -8, true)

-- Portal silhouettes are deliberately different; the openings have no collision.
local function portal(name, x, color, raid)
	local m = group(landmarks, name)
	local base = face(x, -94)
	disc(m, "Landing", 31, 0.3, 0.3, x, -94, C.Stone)
	local radius = 10
	local centerY = 13
	local segments = raid and 6 or 12
	for i = 0, segments - 1 do
		local a, b = i * 2 * math.pi / segments, (i + 1) * 2 * math.pi / segments
		local first = V(math.sin(a) * radius, centerY + math.cos(a) * radius, 0)
		local second = V(math.sin(b) * radius, centerY + math.cos(b) * radius, 0)
		beam(m, "ArchSegment", first, second, 2.8, 3.2, raid and C.Dark or C.Light, base)
		local inset = deco(beam(m, "LuminousInlay", first + V(0, 0, -1.7), second + V(0, 0, -1.7), 0.35, 0.4, color, base))
		inset.Material = Enum.Material.Neon
	end
	-- Thin circular field behind the stone rim; no overlapping translucent surfaces.
	local field = cylinder(m, "PortalSurface", 0.25, 18.4, base * CF(0, centerY, 0) * ANG(math.pi / 2, 0, 0), color)
	deco(field)
	glow(field, 25, 0.85)
	field.Transparency = 0.12
	for _, side in {-1, 1} do
		block(m, base, "ArchFoot", V(5, 6, 5), V(side * 9, 3, 0), raid and C.Dark or C.Stone)
		if raid then
			block(m, base, "ObsidianSpike", V(4, 11, 5), V(side * 14, 5.5, 0), C.Dark, ANG(0, 0, -side * 0.2), "WedgePart")
			deco(block(m, base, "RedCrystal", V(1.8, 5, 2), V(side * 14, 7, -2.5), C.Red, ANG(0, 0, -side * 0.2), "WedgePart")).Material = Enum.Material.Neon
		else
			block(m, base, "CarvedPillar", V(2.8, 10, 3), V(side * 14, 5, 0), C.Stone)
			local crystal = deco(block(m, base, "BlueCrystal", V(2, 4, 2), V(side * 14, 11, 0), C.Ice, ANG(0, math.pi / 4, 0), "WedgePart"))
			crystal.Material = Enum.Material.Neon
		end
	end
end
portal("ZonePortal", -42, C.Blue, false)
portal("RaidPortal", 42, C.Red, true)

-- Daily chest under a compact, properly joined roof.
local daily = group(landmarks, "DailyReward")
local dailyBase = face(0, 88)
disc(daily, "RewardCourt", 31, 0.4, 0.4, 0, 88, C.Light)
for _, x in {-10, 10} do
	for _, z in {-8, 8} do
		block(daily, dailyBase, "Pillar", V(1.3, 11, 1.3), V(x, 5.8, z), C.Wood)
		block(daily, dailyBase, "PillarBase", V(2, 1, 2), V(x, 0.9, z), C.Gold)
	end
end
roof(daily, dailyBase, 25, 22, 11.4, 5, C.Teal)
block(daily, dailyBase, "Chest", V(10, 4.5, 6), V(0, 2.7, 1), C.Wood)
block(daily, dailyBase, "Lid", V(10.5, 1.8, 6.5), V(0, 5.8, 1), C.Timber)
for _, x in {-3.7, 3.7} do
	block(daily, dailyBase, "FrontBand", V(0.7, 6.2, 0.2), V(x, 3.6, -2.3), C.Gold)
	block(daily, dailyBase, "LidBand", V(0.7, 0.2, 6.6), V(x, 6.8, 1), C.Gold)
end
glow(deco(block(daily, dailyBase, "LockGem", V(1.4, 1.4, 0.4), V(0, 4.4, -2.5), C.Gold, ANG(0, 0, math.pi / 4))), 14, 0.6)
-- Gift emblem above the chest, entirely made from geometry.
block(daily, dailyBase, "GiftEmblem", V(3, 2.5, 0.7), V(0, 10, -8.5), C.Gold)
block(daily, dailyBase, "GiftRibbon", V(0.5, 3.2, 0.9), V(0, 10.1, -8.6), C.Plaster)
for _, side in {-1, 1} do
	block(daily, dailyBase, "GiftBow", V(1.4, 0.6, 0.8), V(side * 0.7, 11.7, -8.5), C.Gold, ANG(0, 0, side * 0.45))
end

-- Geometry only. Kept inside Maps.Lobby to leave existing board UI bindings alone.
-- Attach your own SurfaceGui to DisplaySurface (Front / local -Z).
local boardDefs = {
	{"Gold", -104, 76, C.Gold},
	{"Kills", -52, 126, C.Red},
	{"Donations", 52, 126, C.Violet},
	{"PlayTime", 104, 76, C.Ice},
}
for _, def in boardDefs do
	local id, x, z, accent = def[1], def[2], def[3], def[4]
	local m = group(boards, id)
	local base = face(x, z)
	disc(m, "Court", 34, 0.25, 0.25, x, z, C.Path)
	block(m, base, "Plinth", V(27, 1.1, 7), V(0, 0.8, 0), C.Stone)
	block(m, base, "Backing", V(23, 24, 2.2), V(0, 14, 0), C.Dark)
	local display = block(m, base, "DisplaySurface", V(20, 21, 0.25), V(0, 14, -1.25), Color3.fromRGB(32, 45, 45))
	display:SetAttribute("SuggestedFace", "Front")
	for _, side in {-1, 1} do
		block(m, base, "Frame", V(1, 24, 1), V(side * 11.1, 14, -1.4), accent)
	end
	for _, y in {2.5, 25.5} do
		block(m, base, "FrameRail", V(23.2, 0.8, 1), V(0, y, -1.4), accent)
	end
	if id == "Gold" then
		for _, side in {-1, 1} do
			block(m, base, "TreasuryColumn", V(2.3, 24, 3.3), V(side * 13, 13.5, 0), C.Light)
			for _, yy in {2, 25} do
				block(m, base, "Capital", V(3.5, 1, 4.2), V(side * 13, yy, 0), C.Gold)
			end
		end
		block(m, base, "CrownBand", V(10, 1.8, 2), V(0, 28, 0), C.Gold)
		for i = -2, 2 do
			block(m, base, "CrownPoint", V(2, 3 + (2 - math.abs(i)) * 0.7, 2), V(i * 2, 30, 0), C.Gold, nil, "WedgePart")
		end
		for i = 1, 3 do
			cylinder(m, "CoinStack", 0.7, 3.6, base * CF(-10, 0.8 + i * 0.7, -4), C.Gold)
		end
	elseif id == "Kills" then
		for _, side in {-1, 1} do
			block(m, base, "HuntPost", V(2.3, 25, 3), V(side * 13, 13, 0), C.Wood)
			block(m, base, "Tusk", V(2.2, 7, 2), V(side * 10, 28.5, 0), C.Plaster, ANG(0, 0, -side * 0.4), "WedgePart")
			local swordBase = base * CF(0, 30, 0) * ANG(0, 0, side * 0.65)
			block(m, swordBase, "Blade", V(0.9, 9, 0.6), V(0, 1, 0), C.Light)
			block(m, swordBase, "Guard", V(3, 0.5, 1), V(0, -3, 0), C.Gold)
			block(m, swordBase, "Grip", V(0.7, 2, 0.7), V(0, -4, 0), C.Wood)
		end
		block(m, base, "Shield", V(4, 5, 1.3), V(0, 29.5, -1), C.Red, ANG(0, 0, math.pi / 4))
	elseif id == "Donations" then
		for _, side in {-1, 1} do
			for i = 0, 2 do
				block(m, base, "AmethystCluster", V(2.5, 5 + i * 2.5, 3), V(side * (12.8 + i * 1.3), 3 + i, 0), i % 2 == 0 and C.Violet or C.Teal, ANG(0, 0, -side * 0.17), "WedgePart")
			end
		end
		local jewel = block(m, base, "PatronGem", V(5, 5, 2.5), V(0, 30, 0), C.Violet, ANG(0, 0, math.pi / 4))
		glow(deco(jewel), 14, 0.4)
		for _, side in {-1, 1} do
			for i = 0, 3 do
				block(m, base, "LaurelLeaf", V(2, 0.8, 1), V(side * (3 + i * 1.3), 27.5 + i * 0.6, 0), C.Gold, ANG(0, 0, side * 0.5))
			end
		end
	else
		for _, side in {-1, 1} do
			block(m, base, "ClockTowerPier", V(2.4, 25, 3.4), V(side * 13, 13, 0), C.Teal)
		end
		cylinder(m, "ClockRim", 1.3, 10, base * CF(0, 30, 0) * ANG(math.pi / 2, 0, 0), C.Gold)
		cylinder(m, "ClockFace", 0.2, 8.7, base * CF(0, 30, -0.8) * ANG(math.pi / 2, 0, 0), C.Dark)
		for i = 0, 11 do
			local a = i * math.pi / 6
			block(m, base, "HourMark", V(0.25, 0.75, 0.2), V(math.sin(a) * 3.5, 30 + math.cos(a) * 3.5, -1), C.Ice, ANG(0, 0, -a))
		end
		beam(m, "MinuteHand", V(0, 30, -1.2), V(0, 33, -1.2), 0.22, 0.22, C.Light, base)
		beam(m, "HourHand", V(0, 30, -1.3), V(2, 29, -1.3), 0.3, 0.3, C.Gold, base)
	end
end

-- Garden islands are placed between paths; randomized detail stays inside them.
local gardenSites = {V(-63, 0, 14), V(63, 0, 14), V(-81, 0, -65), V(81, 0, -65)}
for _, site in gardenSites do
	local m = group(gardens, "GardenIsland")
	disc(m, "Edging", 19, 0.5, 0.5, site.X, site.Z, C.Stone)
	disc(m, "Soil", 17.4, 0.54, 0.15, site.X, site.Z, C.Grass)
	block(m, CF(site), "Trunk", V(2, 10, 2), V(0, 5.5, 0), C.Wood)
	for tier = 1, 3 do
		deco(block(m, CF(site), "Canopy", V(13 - tier * 1.6, 5, 12 - tier), V((tier % 2) * 0.8, 10 + tier * 2, 0), tier == 3 and C.LeafLight or C.Leaf, ANG(0, tier * 0.45, 0)))
	end
	for i = 1, 9 do
		local a = i * 2 * math.pi / 9
		local pos = site + V(math.sin(a) * 6.5, 1, math.cos(a) * 6.5)
		deco(part(m, "Flower", V(0.9, 0.6, 0.9), CF(pos) * ANG(0, a, 0), i % 2 == 0 and C.Plaster or C.Violet))
	end
end
for i = 0, 47 do
	local a = i * math.pi / 24
	local pos = V(math.sin(a) * 164, 0, math.cos(a) * 164)
	local h = rng:NextNumber(14, 23)
	part(cliffs, "RockFace", V(23, h, 18), CF(pos + V(0, h / 2 - 2, 0)) * ANG(0, a, 0), C.Stone)
	deco(part(cliffs, "MossCap", V(23.5, 2, 18.5), CF(pos + V(0, h - 2, 0)) * ANG(0, a, 0), C.Leaf))
	if i % 3 == 0 then
		part(cliffs, "HighRock", V(15, h + 7, 12), CF(pos + V(math.sin(a) * 5, (h + 7) / 2 - 2, math.cos(a) * 5)) * ANG(0, a + 0.1, 0), C.Dark)
	end
end
for _, x in {-23, 23} do
	for _, z in {-38, 38} do lantern(gardens, CFrame.identity, x, z) end
end
for _, x in {-39, 39} do
	local bench = group(gardens, "Bench")
	local base = face(x, 12)
	block(bench, base, "Seat", V(9, 0.5, 3), V(0, 2, 0), C.Timber)
	block(bench, base, "Back", V(9, 2.2, 0.5), V(0, 3.4, 1.4), C.Wood)
	for _, side in {-1, 1} do
		block(bench, base, "Leg", V(0.6, 2, 2.5), V(side * 3.5, 1, 0), C.Dark)
	end
end

-- Validate before replacing anything. No UI, Adornee, runtime scripts or triggers.
for _, object in map:GetDescendants() do
	assert(not object:IsA("LayerCollector") and not object:IsA("LuaSourceContainer"), "Geometry-only generator.")
	if object:IsA("BasePart") then
		assert(object.Anchored and not object.CanTouch, "All generated geometry must be anchored and touch-free.")
	end
end
for _, def in boardDefs do
	assert(boards[def[1]]:FindFirstChild("DisplaySurface"), "Missing leaderboard display.")
end
local maps = workspace:FindFirstChild("Maps")
assert(not maps or maps:IsA("Folder"), "Workspace.Maps must be a Folder.")
local backups = SS:FindFirstChild("WorldGeneratorBackups")
assert(not backups or backups:IsA("Folder"), "WorldGeneratorBackups must be a Folder.")
local recording
pcall(function() recording = History:TryBeginRecording("GenerateLobbyV2", "Rebuild landscaped lobby") end)
if not maps then maps = group(workspace, "Maps", "Folder") end
local old = maps:FindFirstChild("Lobby")
if old then
	if not backups then backups = group(SS, "WorldGeneratorBackups", "Folder") end
	local name = "Lobby_" .. os.date("%Y%m%d_%H%M%S")
	local suffix = 1
	while backups:FindFirstChild(name .. "_" .. suffix) do suffix += 1 end
	local backup = group(backups, name .. "_" .. suffix, "Folder")
	old:SetAttribute("OriginalParent", maps:GetFullName())
	old.Parent = backup
end
map.Parent = maps
staging:Destroy()
game:GetService("Selection"):Set({map})
if recording then History:FinishRecording(recording, Enum.FinishRecordingOperation.Commit) end
print("Lobby v2 generated: spawn, shop, forge, portals, daily chest and four distinct leaderboard structures.")
print("Leaderboard surfaces: Workspace.Maps.Lobby.Landmarks.Leaderboards.<name>.DisplaySurface. Bind UI manually.")
