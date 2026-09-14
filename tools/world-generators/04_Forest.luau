-- Forest v2: an explorable woodland, authored once in Studio Edit mode.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating Forest")
local ORIGIN = Vector3.new(0, 0, 2400)
local rng = Random.new(92814)
local V = Vector3.new
local C = Color3.fromRGB
local colors = {
	grass = C(57, 89, 68),
	moss = C(85, 124, 73),
	bark = C(81, 61, 48),
	dark = C(47, 46, 40),
	rock = C(88, 106, 101),
	leaf = C(41, 103, 78),
	mint = C(109, 187, 147),
	gold = C(217, 186, 108),
	path = C(139, 128, 96),
	water = C(64, 139, 148),
}
local function group(parent, name, class)
	local f = Instance.new(class or "Folder")
	f.Name = name
	f.Parent = parent
	return f
end
local map = group(nil, "Forest", "Model")
local ground = group(map, "Ground")
local paths = group(map, "Paths")
local vegetation = group(map, "Vegetation")
local landmarks = group(map, "Landmarks")
local details = group(map, "TrailDetails")
local markers = group(map, "PlanningMarkers")
local function part(parent, name, size, pos, color, shape, rotation, solid)
	local p = Instance.new(shape or "Part")
	p.Name = name
	p.Size = size
	p.CFrame = CFrame.new(ORIGIN + pos) * (rotation or CFrame.identity)
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CanCollide = solid ~= false
	p.CanTouch = false
	p.CanQuery = solid ~= false
	p.Parent = parent
	return p
end
local function ellipsoid(parent, name, pos, size, color, rotation)
	local p = part(parent, name, size, pos, color, "Part", rotation, false)
	p.Shape = Enum.PartType.Ball
	return p
end
local function beam(parent, name, a, b, width, color, solid)
	return part(
		parent,
		name,
		V(width, width, (b - a).Magnitude),
		(a + b) / 2,
		color,
		"Part",
		CFrame.lookAt(Vector3.zero, b - a),
		solid
	)
end
local function disc(parent, name, pos, radius, thickness, color, solid)
	local p = part(
		parent,
		name,
		V(thickness, radius * 2, radius * 2),
		pos,
		color,
		"Part",
		CFrame.Angles(0, 0, math.pi / 2),
		solid
	)
	p.Shape = Enum.PartType.Cylinder
	return p
end
local function marker(name, pos)
	local p = part(markers, name, Vector3.one, pos, colors.gold, nil, nil, false)
	p.Transparency = 1
	p:SetAttribute("PlanningOnly", true)
end
-- A broad scalloped basin, rather than a corridor. Solid floor under every route.
local function boundaryRadius(angle)
	return 276 + 18 * math.sin(angle * 3) + 10 * math.cos(angle * 5)
end
for z = -300, 300, 8 do
	local left, right = nil, nil
	for x = -310, 310, 4 do
		local angle = math.atan2(z, x)
		if V(x, 0, z).Magnitude < boundaryRadius(angle) + 10 then
			left = left or x
			right = x
		end
	end
	if left and right then
		part(ground, "BasinFloor", V(right - left + 8, 14, 8.1), V((left + right) / 2, -7, z), colors.grass)
	end
end
for i = 0, 95 do
	local a = i * math.pi * 2 / 96
	local p = V(math.cos(a), 0, math.sin(a)) * boundaryRadius(a)
	local h = 34 + 9 * math.sin(a * 7)
	part(ground, "ScallopedCliff", V(28, h, 26), p + V(0, h / 2 - 2, 0), colors.rock, nil, CFrame.Angles(0, -a, 0))
	part(
		ground,
		"MossLedge",
		V(30, 3, 28),
		p + V(0, h - 2, 0),
		colors.moss,
		"WedgePart",
		CFrame.Angles(0, -a, 0),
		false
	)
end
-- Route graph: two main loops, a cross-link and an optional hidden shrine loop.
local nodes = {
	Entry = V(0, 0, -220),
	Crossroads = V(-20, 0, -90),
	Mosscap = V(-155, 0, -105),
	Moonwater = V(140, 0, -85),
	HeartTree = V(0, 0, 20),
	Ruins = V(155, 0, 100),
	Elderbark = V(-85, 0, 175),
	Shrine = V(-205, 0, 65),
	Lookout = V(175, 0, 195),
}
local routes = {
	{ "Entry", "Crossroads", V(-26, 0, -163) },
	{ "Crossroads", "Mosscap", V(-90, 0, -143) },
	{ "Crossroads", "Moonwater", V(64, 0, -145) },
	{ "Mosscap", "HeartTree", V(-99, 0, -17) },
	{ "Moonwater", "HeartTree", V(85, 0, 3) },
	{ "HeartTree", "Ruins", V(82, 0, 67) },
	{ "HeartTree", "Elderbark", V(-22, 0, 116) },
	{ "Ruins", "Elderbark", V(59, 0, 196) },
	{ "Mosscap", "Shrine", V(-216, 0, -19) },
	{ "Shrine", "Elderbark", V(-179, 0, 150) },
	{ "Moonwater", "Ruins", V(212, 0, 8) },
	{ "Ruins", "Lookout", V(213, 0, 149) },
}
local segments = {}
for _, route in routes do
	local a, b, control = nodes[route[1]], nodes[route[2]], route[3]
	local model = group(paths, route[1] .. "_" .. route[2], "Model")
	local previous = a
	for step = 1, 20 do
		local t = step / 20
		local nextPoint = a * (1 - t) ^ 2 + control * (2 * (1 - t) * t) + b * t ^ 2
		table.insert(segments, { previous, nextPoint })
		part(
			model,
			"SoftTrail",
			V(13, 0.12, (nextPoint - previous).Magnitude + 1.5),
			(nextPoint + previous) / 2 + V(0, 0.03, 0),
			colors.path,
			nil,
			CFrame.lookAt(Vector3.zero, nextPoint - previous),
			false
		)
		previous = nextPoint
	end
end
local clearings = {
	{ nodes.Entry, 20 },
	{ nodes.Crossroads, 22 },
	{ nodes.Mosscap, 34 },
	{ nodes.Moonwater, 42 },
	{ nodes.HeartTree, 43 },
	{ nodes.Ruins, 39 },
	{ nodes.Elderbark, 56 },
	{ nodes.Shrine, 23 },
	{ nodes.Lookout, 24 },
}
for _, c in clearings do
	disc(paths, "Clearing", c[1] + V(0, 0.025, 0), c[2], 0.12, colors.moss, false)
end
local function distanceToRoute(p)
	local best = math.huge
	for _, s in segments do
		local d = s[2] - s[1]
		local t = math.clamp((p - s[1]):Dot(d) / d:Dot(d), 0, 1)
		best = math.min(best, (p - (s[1] + d * t)).Magnitude)
	end
	return best
end
local function inClearing(p, margin)
	for _, c in clearings do
		if (p - c[1]).Magnitude < c[2] + margin then
			return true
		end
	end
	return false
end
local function mushroom(parent, p, s, color)
	local m = group(parent, "ShelfMushroom", "Model")
	beam(m, "Stem", p, p + V(0.15, 2.3, 0) * s, 0.7 * s, colors.gold, false)
	ellipsoid(m, "Umbrella", p + V(0, 2.3, 0) * s, V(3.5, 1.3, 3.2) * s, color)
	disc(m, "PaleGills", p + V(0, 2.05, 0) * s, 1.45 * s, 0.12 * s, colors.mint, false)
	for i = 1, 3 do
		local a = i * 2.1
		ellipsoid(
			m,
			"CapPearl",
			p + V(math.cos(a) * 0.8, 2.9, math.sin(a) * 0.8) * s,
			V(0.3, 0.15, 0.3) * s,
			colors.gold
		)
	end
end
local function fern(parent, p, s)
	local m = group(parent, "Fern", "Model")
	for i = 0, 4 do
		local a = i * math.pi * 2 / 5
		part(
			m,
			"Frond",
			V(0.65, 2.4, 3.5) * s,
			p + V(math.sin(a), 0.8, math.cos(a)) * s,
			colors.moss,
			"WedgePart",
			CFrame.Angles(-0.35, a, 0.1),
			false
		)
	end
end
local function tree(p, h, hero)
	local m = group(vegetation, hero and "CathedralTree" or "OldGrowthTree", "Model")
	local width = h * (hero and 0.18 or 0.115)
	local bend = V(h * 0.07, h * 0.58, -h * 0.025)
	beam(m, "LowerTrunk", p, p + bend, width, colors.bark, true)
	beam(m, "UpperTrunk", p + bend, p + V(-h * 0.035, h, 0), width * 0.7, colors.bark, true)
	-- Bark ribs, flared buttress roots and radial boughs break up the trunk silhouette.
	for i = 0, 5 do
		local a = i * math.pi / 3
		local direction = V(math.cos(a), 0, math.sin(a))
		beam(
			m,
			"ButtressRoot",
			p + direction * (width * 0.25) + V(0, width, 0),
			p + direction * (width * 1.8),
			width * 0.28,
			colors.bark,
			false
		)
		beam(
			m,
			"BarkRidge",
			p + direction * (width * 0.5) + V(0, 3, 0),
			p + bend + direction * (width * 0.4),
			width * 0.12,
			colors.dark,
			false
		)
		local endPoint = p + direction * (h * 0.29) + V(0, h * (0.73 + (i % 2) * 0.12), 0)
		beam(m, "CrownBough", p + bend, endPoint, width * 0.35, colors.bark, false)
		local leafColor = colors.leaf:Lerp(colors.moss, (i % 3) * 0.16)
		ellipsoid(
			m,
			"CanopyMass",
			endPoint + V(0, 4, 0),
			V(h * 0.48, h * 0.19, h * 0.4),
			leafColor,
			CFrame.Angles(0, a, 0)
		)
		part(
			m,
			"CanopyFacet",
			V(h * 0.35, h * 0.1, h * 0.33),
			endPoint + V(0, h * 0.08, 0),
			leafColor,
			"WedgePart",
			CFrame.Angles(0, a, 0),
			false
		)
		if i % 2 == 0 then
			beam(m, "HangingVine", endPoint, endPoint - V(2, h * 0.24, 0), 0.35, colors.moss, false)
			for j = 1, 3 do
				ellipsoid(m, "VineLeaf", endPoint - V(2 * j / 3, h * 0.08 * j, 0), V(1.5, 2.3, 0.5), colors.mint)
			end
		end
	end
	for i = 1, 3 do
		mushroom(m, p + V(width * 0.52, i * 2.4, 0), hero and 1.5 or 0.8, colors.mint)
	end
	return m
end
-- The central tree sits off the junction, so its roots don't obstruct the loops.
tree(V(8, 0, 48), 105, true)
local treePositions = { V(8, 0, 48) }
for i = 1, 180 do
	local a = rng:NextNumber(0, math.pi * 2)
	local radius = math.sqrt(rng:NextNumber()) * 245
	local p = V(math.cos(a) * radius, 0, math.sin(a) * radius)
	local free = distanceToRoute(p) > 24 and not inClearing(p, 12)
	for _, old in treePositions do
		if (p - old).Magnitude < 34 then
			free = false
			break
		end
	end
	if free then
		tree(p, rng:NextNumber(43, 70), false)
		table.insert(treePositions, p)
	end
end
-- Deliberate pockets of detail along the route interiors, not just on the boundary.
for i = 1, 260 do
	local p = V(rng:NextNumber(-245, 245), 0, rng:NextNumber(-245, 245))
	local d = distanceToRoute(p)
	if p.Magnitude < 245 and d > 10 and d < 36 and not inClearing(p, 3) then
		if i % 3 == 0 then
			mushroom(details, p, rng:NextNumber(0.65, 1.3), i % 2 == 0 and colors.mint or C(184, 136, 111))
		elseif i % 3 == 1 then
			fern(details, p, rng:NextNumber(0.8, 1.5))
		else
			part(
				details,
				"MossyTrailStone",
				V(4, 2, 3),
				p + V(0, 0.7, 0),
				colors.rock,
				"WedgePart",
				CFrame.Angles(0, i, 0),
				false
			)
			for j = 1, 3 do
				ellipsoid(details, "Wildflower", p + V(j * 0.5, 1.5, -j * 0.25), V(0.6, 0.6, 0.6), colors.gold)
			end
		end
	end
end
local function lantern(parent, p)
	beam(parent, "LanternStem", p, p + V(0, 5, 0), 0.5, colors.bark, true)
	part(parent, "LanternFrame", V(1.7, 2, 1.7), p + V(0, 5.4, 0), colors.dark, nil, nil, false)
	local glass = part(parent, "AmberGlass", V(1.4, 1.3, 1.8), p + V(0, 5.4, 0), colors.gold, nil, nil, false)
	glass.Material = Enum.Material.Neon
	part(parent, "LanternRoof", V(2.3, 0.7, 2.3), p + V(0, 6.7, 0), colors.moss, "WedgePart", nil, false)
end
for _, route in routes do
	local p = (nodes[route[1]] + route[3]) / 2
	local d = (route[3] - nodes[route[1]]).Unit
	lantern(details, p + V(-d.Z, 0, d.X) * 12)
end
local function arch(parent, p, width, height)
	for _, side in { -1, 1 } do
		part(parent, "ArchPier", V(4, height - 3, 5), p + V(side * (width / 2 + 2), (height - 3) / 2, 0), colors.rock)
		part(parent, "CarvedFoot", V(6, 1.5, 7), p + V(side * (width / 2 + 2), 0.75, 0), colors.dark)
		for j = 1, 3 do
			part(
				parent,
				"IvyLeaf",
				V(2, 3, 0.5),
				p + V(side * (width / 2 + 2), j * 3, -2.8),
				colors.moss,
				"WedgePart",
				CFrame.Angles(0, 0, side * 0.3),
				false
			)
		end
	end
	for i = 0, 6 do
		local a = i * math.pi / 6
		part(
			parent,
			"ArchVoussoir",
			V(5, 4, 5),
			p + V(math.cos(a) * (width / 2 + 2), height - 3 + math.sin(a) * width * 0.28, 0),
			colors.rock,
			nil,
			CFrame.Angles(0, 0, a + math.pi / 2)
		)
	end
end
local entry = group(landmarks, "PilgrimGate", "Model")
arch(entry, nodes.Entry + V(0, 0, -8), 23, 19)
for _, side in { -1, 1 } do
	lantern(entry, nodes.Entry + V(side * 19, 0, 3))
end
local camp = group(landmarks, "LostBotanistCamp", "Model")
local cp = V(-64, 0, -179)
for _, side in { -1, 1 } do
	local a = cp + V(side * 5, 0, 0)
	local b = cp + V(0, 7, 0)
	beam(camp, "TentPole", a, b, 0.5, colors.bark, true)
	part(
		camp,
		"Canvas",
		V(8.6, 0.25, 11),
		cp + V(side * 2.5, 3.5, 0),
		C(159, 146, 104),
		nil,
		CFrame.Angles(0, 0, -side * 0.95),
		false
	)
end
for i = 1, 3 do
	part(camp, "SupplyCrate", V(3, 3, 3), cp + V(9 + (i % 2) * 3, 1.5, i * 3), colors.bark)
end
lantern(camp, cp + V(-8, 0, 4))
local fungi = group(landmarks, "SporeGarden", "Model")
for i = 0, 8 do
	local a = i * math.pi * 2 / 9
	mushroom(
		fungi,
		nodes.Mosscap + V(math.cos(a) * 28, 0, math.sin(a) * 28),
		2 + (i % 3) * 0.7,
		i % 2 == 0 and colors.mint or C(162, 121, 146)
	)
end
-- Fallen trunk arch over a footpath: the opening has 15 studs of headroom.
local fallen = group(landmarks, "FallenGiant", "Model")
local fp = nodes.Mosscap * 0.25 + V(-99, 0, -17) * 0.5 + nodes.HeartTree * 0.25
for _, side in { -1, 1 } do
	part(fallen, "BrokenStump", V(9, 18, 13), fp + V(side * 19, 9, 0), colors.bark)
end
beam(fallen, "FallenTrunk", fp + V(-23, 20, 0), fp + V(23, 18, 0), 8, colors.bark, true)
for i = 1, 7 do
	mushroom(fallen, fp + V(-20 + i * 5, 23, 0), 0.9, colors.mint)
end
local lake = group(landmarks, "MoonwaterGarden", "Model")
local lp = nodes.Moonwater
local water = disc(lake, "MoonPool", lp + V(0, 0.18, 0), 34, 0.15, colors.water, false)
water.Transparency = 0.2
for i = 0, 14 do
	local a = i * math.pi * 2 / 15
	local p = lp + V(math.cos(a) * 34, 0.7, math.sin(a) * 34)
	part(lake, "PoolBank", V(7, 1.4, 5), p, colors.rock, "WedgePart", CFrame.Angles(0, -a, 0), false)
	if i % 3 == 0 then
		disc(lake, "LilyPad", lp + V(math.cos(a) * 23, 0.35, math.sin(a) * 23), 2.5, 0.15, colors.moss, false)
		ellipsoid(lake, "Lotus", lp + V(math.cos(a) * 23, 0.8, math.sin(a) * 23), V(1.8, 1, 1.8), C(216, 165, 176))
	end
end
local falls = group(landmarks, "SilverthreadFalls", "Model")
local wp = V(244, 0, -86)
for _, side in { -1, 1 } do
	part(
		falls,
		"WaterfallButtress",
		V(12, 37, 17),
		wp + V(side * 10, 17, 0),
		colors.rock,
		"WedgePart",
		CFrame.Angles(0, side * 0.3, 0)
	)
	fern(falls, wp + V(side * 11, 35, 0), 2)
end
local veil = part(falls, "WaterVeil", V(12, 32, 0.35), wp + V(0, 17, -8.7), colors.water, nil, nil, false)
veil.Transparency = 0.28
for i = 1, 4 do
	local ribbon =
		part(falls, "SilverThread", V(0.5, 28, 0.2), wp + V(-5 + i * 2, 18, -9), colors.mint, nil, nil, false)
	ribbon.Transparency = 0.35
end
for i = 0, 7 do
	local p = wp + V(-i * 11, 0.2, math.sin(i * 0.5) * 7 - 9)
	disc(falls, "SpringRun", p, 9, 0.12, colors.water, false).Transparency = 0.22
	if i < 3 then
		ellipsoid(falls, "Foam", p + V(0, 0.15, 0), V(8, 0.2, 3), colors.mint)
	end
end
-- Curved low bridge with shallow ramps at both ends, accessible without jumping.
for i = 0, 23 do
	local t = i / 23
	local x = -35 + t * 70
	local y = 0.3 + math.sin(t * math.pi) * 2
	part(lake, "BridgePlank", V(3.1, 0.45, 11), lp + V(x, y, 0), colors.bark)
	if i % 4 == 0 then
		for _, side in { -1, 1 } do
			beam(lake, "BridgePost", lp + V(x, y, side * 6), lp + V(x, y + 3, side * 6), 0.65, colors.bark, true)
		end
	end
end
local ruins = group(landmarks, "SunkenObservatory", "Model")
local rp = nodes.Ruins
for i = 0, 9 do
	local a = i * math.pi / 5
	local p = rp + V(math.cos(a) * 29, 0, math.sin(a) * 29)
	-- Colonnade gaps leave all three approaches open.
	if i ~= 2 and i ~= 5 and i ~= 7 then
		part(ruins, "ColumnPlinth", V(8, 1, 8), p + V(0, 0.5, 0), colors.rock)
		local h = 10 + (i % 3) * 4
		part(ruins, "FlutedColumn", V(4, h, 4), p + V(0, h / 2, 0), colors.rock)
		part(ruins, "Capital", V(7, 2, 7), p + V(0, h, 0), colors.moss)
	end
end
for i = 0, 15 do
	local a = i * math.pi / 8
	part(
		ruins,
		"CompassInlay",
		V(1, 0.15, 5),
		rp + V(math.cos(a) * 15, 0.18, math.sin(a) * 15),
		colors.gold,
		nil,
		CFrame.Angles(0, -a + math.pi / 2, 0),
		false
	)
end
disc(ruins, "AstrolabeBase", rp + V(0, 0.4, 0), 5, 0.8, colors.rock, true)
for i = 0, 11 do
	local a = i * math.pi / 6
	beam(
		ruins,
		"AstrolabeRing",
		rp + V(math.cos(a) * 4, 5 + math.sin(a) * 4, 0),
		rp + V(math.cos(a + math.pi / 6) * 4, 5 + math.sin(a + math.pi / 6) * 4, 0),
		0.35,
		colors.gold,
		false
	)
end
local shrine = group(landmarks, "ForgottenOffering", "Model")
local sp = nodes.Shrine
arch(shrine, sp + V(0, 0, 7), 12, 13)
disc(shrine, "OfferingBowl", sp + V(0, 1, 0), 4, 2, colors.rock, true)
for i = 1, 5 do
	ellipsoid(shrine, "OfferingPearl", sp + V(math.sin(i) * 2, 2.3, math.cos(i) * 2), V(0.8, 0.8, 0.8), colors.mint)
end
for _, side in { -1, 1 } do
	mushroom(shrine, sp + V(side * 12, 0, 3), 3, colors.mint)
end
-- Optional raised overlook, reachable by a broad ramp; main routes remain on level ground.
local overlook = group(landmarks, "CanopyOverlook", "Model")
local op = nodes.Lookout + V(0, 0, 9)
part(overlook, "Terrace", V(32, 10, 24), op + V(0, 5, 0), colors.rock)
part(overlook, "MossTerrace", V(33, 0.3, 25), op + V(0, 10.1, 0), colors.moss)
part(overlook, "AccessRamp", V(18, 10, 38), op + V(0, 5, -31), colors.rock, "WedgePart")
for _, side in { -1, 1 } do
	lantern(overlook, op + V(side * 12, 10, 0))
end
local arena = group(landmarks, "ElderbarkHeartgrove", "Model")
local bp = nodes.Elderbark
for i = 0, 15 do
	local a = i * math.pi / 8
	local p = bp + V(math.cos(a) * 51, 0, math.sin(a) * 51)
	if distanceToRoute(p) > 11 then
		part(
			arena,
			"RootThroneStone",
			V(6, 13 + (i % 3) * 2, 7),
			p + V(0, 6, 0),
			colors.rock,
			"WedgePart",
			CFrame.Angles(0, -a, 0)
		)
		local rune = part(arena, "HeartRune", V(0.6, 4, 0.4), p + V(0, 7, -3.6), colors.mint, nil, nil, false)
		rune.Material = Enum.Material.Neon
	end
end
for i = 0, 23 do
	local a = i * math.pi / 12
	part(
		arena,
		"AncientCircle",
		V(3, 0.15, 1),
		bp + V(math.cos(a) * 32, 0.17, math.sin(a) * 32),
		colors.gold,
		nil,
		CFrame.Angles(0, -a, 0),
		false
	)
end
for name, p in nodes do
	marker(name, p + V(0, 3, 0))
end
marker("Thornback Stag", nodes.Moonwater + V(0, 3, -44))
marker("Hollow Sentinel", nodes.Ruins + V(-12, 3, 0))
map:SetAttribute("AssetStage", "ModelsOnly")
map:SetAttribute("DesignVersion", 2)
local maps = workspace:FindFirstChild("Maps") or group(workspace, "Maps")
local old = maps:FindFirstChild("Forest")
if old then
	local ss = game:GetService("ServerStorage")
	local backups = ss:FindFirstChild("WorldGeneratorBackups") or group(ss, "WorldGeneratorBackups")
	old.Parent = group(backups, "Forest_" .. os.date("%Y%m%d_%H%M%S"))
end
map.Parent = maps
game:GetService("Selection"):Set({ map })
print("Forest v2: looping woodland, cathedral tree, gardens, observatory, shrine and heartgrove. Models only.")
