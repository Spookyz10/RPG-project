-- Paste into Studio Command Bar in Edit mode. Coordinates are relative to ORIGIN.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating Grasslands")
local ORIGIN = Vector3.new(0, 0, 1000)
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local random = Random.new(7419)
local function folder(parent, name)
	local f = parent:FindFirstChild(name)
	if not f then f = Instance.new("Folder"); f.Name = name; f.Parent = parent end
	return f
end
local staging = Instance.new("Folder")
local map = folder(staging, "Grasslands")
local terrain = folder(map, "Ground")
local decor = folder(map, "Vegetation")
local cave = folder(map, "DireBearCave")
local spawns = folder(staging, "Spawns")
local portals = folder(staging, "Portals")
local destinations = folder(staging, "Destinations")
local regions = folder(staging, "Regions")
local bosses = folder(staging, "Bosses")
local function part(parent, name, size, position, color, shape)
	local p = Instance.new(shape or "Part")
	p.Name = name; p.Size = size; p.Position = ORIGIN + position
	p.Color = color or Color3.fromRGB(80, 130, 60)
	p.Material = Enum.Material.SmoothPlastic
	p.Anchored = true; p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local function marker(parent, name, pos)
	local p = part(parent, name, Vector3.one, pos)
	p.Transparency = 1; p.CanCollide = false; p.CanTouch = false; p.CanQuery = false
	return p
end
-- Broad, asymmetric valley with continuous walls following the terrain outline.
local green = Color3.fromRGB(112, 157, 76)
local rock = Color3.fromRGB(91, 103, 92)
local cliffs = folder(map, "Cliffs")
local details = folder(map, "Details")
local trail = folder(map, "Paths")
local entrance = folder(map, "Entrance")
local flowers = folder(decor, "Flowers")
local trees = folder(decor, "Trees")
local shrubs = folder(decor, "Shrubs")
local function cosmetic(p)
	p.CanCollide = false; p.CanTouch = false; p.CanQuery = false
	return p
end
local function stone(parent, name, pos, size, color)
	local p = part(parent, name, size, pos, color or rock)
	p.Orientation = Vector3.new(random:NextNumber(-12, 12), random:NextNumber(0, 180), random:NextNumber(-12, 12))
	return p
end
-- Each cross-section defines a different left/right bank, forming connected bays.
local banks = {
	{Z = -22, Left = -76, Right = 82},
	{Z = 28, Left = -105, Right = 108},
	{Z = 76, Left = -142, Right = 108},
	{Z = 120, Left = -130, Right = 94},
	{Z = 165, Left = -98, Right = 147},
	{Z = 210, Left = -112, Right = 138},
	{Z = 252, Left = -128, Right = 108},
	{Z = 288, Left = -83, Right = 81},
	{Z = 319, Left = -62, Right = 62},
}
local function bankAt(z)
	for i = 1, #banks - 1 do
		local a, b = banks[i], banks[i + 1]
		if z <= b.Z then
			local t = math.clamp((z - a.Z) / (b.Z - a.Z), 0, 1)
			return a.Left + (b.Left - a.Left) * t, a.Right + (b.Right - a.Right) * t
		end
	end
	return banks[#banks].Left, banks[#banks].Right
end
-- Overlapping foundation strips end beneath the enclosing cliff segments.
for z = -22, 318, 4 do
	local left, right = bankAt(z + 2)
	part(terrain, "ValleyFloor", Vector3.new(right - left + 16, 12, 4.2), Vector3.new((left + right) / 2, -6, z + 2), green)
end
local function cliff(pos, width)
	local h = random:NextNumber(35, 52)
	stone(cliffs, "RockFace", pos + Vector3.new(0, h / 2 - 3, 0), Vector3.new(width, h, 24))
	stone(cliffs, "UpperFace", pos + Vector3.new(0, h + 1, 0), Vector3.new(width + 3, 15, 25), Color3.fromRGB(119, 130, 105))
	cosmetic(stone(cliffs, "MossCap", pos + Vector3.new(0, h + 9, 0), Vector3.new(width + 4, 3, 27), Color3.fromRGB(91, 128, 65)))
end
local function boundary(a, b)
	local length = (b - a).Magnitude
	local midpoint = (a + b) / 2 + Vector3.new(0, 27, 0)
	local wall = part(cliffs, "SolidBoundary", Vector3.new(20, 66, length + 20), midpoint, rock)
	wall.CFrame = CFrame.lookAt(ORIGIN + midpoint, ORIGIN + b + Vector3.new(0, 27, 0))
	local count = math.ceil(length / 22)
	for i = 0, count do cliff(a:Lerp(b, i / count), 27) end
end
for i = 1, #banks - 1 do
	local a, b = banks[i], banks[i + 1]
	boundary(Vector3.new(a.Left, 0, a.Z), Vector3.new(b.Left, 0, b.Z))
	boundary(Vector3.new(a.Right, 0, a.Z), Vector3.new(b.Right, 0, b.Z))
end
for _, bank in {banks[1], banks[#banks]} do
	boundary(Vector3.new(bank.Left, 0, bank.Z), Vector3.new(bank.Right, 0, bank.Z))
end
-- Low grassy shelves in the wider bays, reached by gentle slopes.
local shelves = folder(terrain, "GrassyShelves")
for _, shelf in {
	{X = -97, Z = 74, Width = 30, Depth = 29, Height = 4},
	{X = 102, Z = 174, Width = 32, Depth = 33, Height = 6},
	{X = -88, Z = 241, Width = 26, Depth = 24, Height = 3},
} do
	local color = Color3.fromRGB(120, 163, 81)
	part(shelves, "GrassTerrace", Vector3.new(shelf.Width, shelf.Height, shelf.Depth), Vector3.new(shelf.X, shelf.Height / 2, shelf.Z), color)
	local slopeLength = 23
	part(shelves, "GentleSlope", Vector3.new(shelf.Width, shelf.Height, slopeLength), Vector3.new(shelf.X, shelf.Height / 2, shelf.Z - shelf.Depth / 2 - slopeLength / 2), color, "WedgePart")
	for _, side in {-1, 1} do
		cosmetic(stone(shelves, "MossyEdge", Vector3.new(shelf.X + side * (shelf.Width / 2 - 2), shelf.Height - 0.7, shelf.Z + 5), Vector3.new(5, 2, 9), Color3.fromRGB(107, 141, 74)))
	end
end
-- Continuous winding path, with widened clearings at each encounter.
local nodes = {Vector3.new(0, 0, 0), Vector3.new(-12, 0, 38), Vector3.new(-34, 0, 82), Vector3.new(-6, 0, 125), Vector3.new(32, 0, 170), Vector3.new(19, 0, 218), Vector3.new(0, 0, 255), Vector3.new(0, 0, 294)}
for i = 1, #nodes - 1 do
	local a, b = nodes[i], nodes[i + 1]
	local p = part(trail, "Trail", Vector3.new(16, 0.18, (b-a).Magnitude + 3), (a+b)/2 + Vector3.new(0, 0.04, 0), Color3.fromRGB(191, 171, 118))
	p.CFrame = CFrame.lookAt(ORIGIN + (a+b)/2 + Vector3.new(0, 0.04, 0), ORIGIN + b + Vector3.new(0, 0.04, 0))
	cosmetic(p)
end
for _, clearing in {Vector3.new(-12, 0.04, 51), Vector3.new(19, 0.04, 145), Vector3.new(10, 0.04, 235)} do
	local patch = cosmetic(part(trail, "Clearing", Vector3.new(0.14, 62, 78), clearing, Color3.fromRGB(133, 160, 82)))
	patch.Shape = Enum.PartType.Cylinder
	patch.Orientation = Vector3.new(0, 0, 90)
end
local function tree(x, z, scale)
	local model = folder(trees, "Tree_" .. #trees:GetChildren())
	local h = random:NextNumber(9, 13)
	local trunk = part(model, "Trunk", Vector3.new(2.3, h, 2.3) * scale, Vector3.new(x, h * scale / 2, z), Color3.fromRGB(105, 77, 51))
	trunk.Orientation = Vector3.new(0, random:NextNumber(0, 90), 3)
	for tier = 1, 3 do
		local crown = stone(model, "Canopy", Vector3.new(x + (tier % 2) * 2, h * scale + tier * 2.5, z), Vector3.new(13 - tier, 7, 12 - tier) * scale, Color3.fromRGB(65 + tier * 10, 112 + tier * 13, 55 + tier * 4))
		cosmetic(crown)
	end
end
for _, side in {-1, 1} do
	for i = 0, 10 do
		local z = 7 + i * 27
		local left, right = bankAt(z)
		local x = side == -1 and left + 28 or right - 28
		if not ((math.abs(x + 97) < 19 and z > 33 and z < 93)
			or (math.abs(x - 102) < 20 and z > 131 and z < 195)
			or (math.abs(x + 88) < 17 and z > 203 and z < 257)) then
			tree(x, z, random:NextNumber(0.8, 1.15))
		end
	end
end
-- Keep the center and all spawn pockets unobstructed.
for i = 1, 125 do
	local z = random:NextNumber(5, 281)
	local left, right = bankAt(z)
	local x = i % 2 == 0 and random:NextNumber(59, math.max(60, right - 26)) or random:NextNumber(math.min(-60, left + 26), -59)
	-- Keep terrace surfaces and their approach ramps clean.
	if (math.abs(x + 97) < 19 and z > 33 and z < 93)
		or (math.abs(x - 102) < 20 and z > 131 and z < 195)
		or (math.abs(x + 88) < 17 and z > 203 and z < 257) then continue end
	if x < -36 and x > -63 and math.abs(z - 100) < 13 then continue end
	if i % 4 == 0 then
		stone(details, "Boulder", Vector3.new(x, 1.3, z), Vector3.new(4, 3.5, 5), Color3.fromRGB(124, 133, 111))
	else
		cosmetic(stone(shrubs, "Bush", Vector3.new(x, 1.2, z), Vector3.new(4.5, 3, 4), Color3.fromRGB(83, 137, 66)))
		for j = 1, 3 do
			local pos = Vector3.new(x + random:NextNumber(-3, 3), 0.5, z + random:NextNumber(-3, 3))
			cosmetic(part(flowers, "Stem", Vector3.new(0.15, 1, 0.15), pos, Color3.fromRGB(66, 112, 53)))
			cosmetic(part(flowers, "Bloom", Vector3.new(0.7, 0.35, 0.7), pos + Vector3.new(0, 0.6, 0), i % 3 == 0 and Color3.fromRGB(220, 177, 234) or Color3.fromRGB(255, 226, 145)))
		end
	end
end
local function lantern(parent, pos)
	part(parent, "LanternPost", Vector3.new(0.8, 6, 0.8), pos + Vector3.new(0, 3, 0), Color3.fromRGB(88, 64, 43))
	local lamp = cosmetic(part(parent, "Lantern", Vector3.new(1.5, 1.8, 1.5), pos + Vector3.new(0, 6, 0), Color3.fromRGB(255, 201, 117)))
	lamp.Material = Enum.Material.Neon
	local light = Instance.new("PointLight"); light.Color = lamp.Color; light.Range = 19; light.Brightness = 0.8; light.Parent = lamp
	part(parent, "LanternRoof", Vector3.new(2.2, 0.4, 2.2), pos + Vector3.new(0, 7.1, 0), rock)
end
for _, z in {12, 94, 188, 279} do
	local pathX = 0
	for i = 1, #nodes - 1 do
		local a, b = nodes[i], nodes[i + 1]
		if z >= a.Z and z <= b.Z then pathX = a.X + (b.X - a.X) * (z - a.Z) / (b.Z - a.Z); break end
	end
	for _, x in {-13, 13} do lantern(details, Vector3.new(pathX + x, 0, z)) end
end
-- Small arrival plaza and sign, framed by a low wooden fence.
for i = -2, 2 do
	cosmetic(part(entrance, "Paving", Vector3.new(5.5, 0.2, 9), Vector3.new(i * 5.8, 0.12, 3), Color3.fromRGB(168, 168, 137)))
end
for _, side in {-1, 1} do
	for i = 0, 3 do part(entrance, "FencePost", Vector3.new(1, 4, 1), Vector3.new(side * (18 + i * 8), 2, 13), Color3.fromRGB(121, 88, 56)) end
	for _, y in {1.3, 3} do part(entrance, "FenceRail", Vector3.new(25, 0.6, 0.6), Vector3.new(side * 30, y, 13), Color3.fromRGB(149, 112, 70)) end
end
local sign = part(entrance, "GrasslandsSign", Vector3.new(13, 4, 0.8), Vector3.new(30, 6, 14), Color3.fromRGB(91, 69, 47))
local surface = Instance.new("SurfaceGui"); surface.Face = Enum.NormalId.Front; surface.CanvasSize = Vector2.new(520, 160); surface.Parent = sign
local title = Instance.new("TextLabel"); title.Size = UDim2.fromScale(1, 1); title.BackgroundTransparency = 1; title.Text = "GRASSLANDS"; title.TextColor3 = Color3.fromRGB(255, 235, 174); title.Font = Enum.Font.GothamBold; title.TextScaled = true; title.Parent = surface
-- Shallow ornamental pond tucked into the side, away from the route.
cosmetic(part(details, "PondBank", Vector3.new(21, 0.22, 16), Vector3.new(-49, 0.14, 100), Color3.fromRGB(151, 145, 106)))
local water = cosmetic(part(details, "Pond", Vector3.new(17, 0.24, 12), Vector3.new(-49, 0.27, 100), Color3.fromRGB(85, 165, 171)))
water.Material = Enum.Material.Glass; water.Transparency = 0.18
for i = 1, 7 do
	local a = i / 7 * math.pi * 2
	stone(details, "PondStone", Vector3.new(-49 + math.cos(a) * 10, 0.8, 100 + math.sin(a) * 8), Vector3.new(3, 2, 3))
end
-- Four spawns per encounter, with shorter travel between groups.
for _, group in {{"Bushling", 40, 3, -12}, {"Wolf", 130, 4, 19}, {"Boar", 220, 4, 10}} do
	for i = 1, 4 do
		marker(spawns, group[1], Vector3.new(group[4] + (i % 2 == 0 and 24 or -24), group[3], group[2] + math.floor((i - 1) / 2) * 26))
	end
end
-- Dark, layered cave mouth nestled into the rear cliff.
for _, x in {-24, 24} do
	stone(entrance, "CavePillar", Vector3.new(x, 15, 294), Vector3.new(19, 34, 23))
end
stone(entrance, "CaveArch", Vector3.new(0, 34, 297), Vector3.new(62, 15, 25), Color3.fromRGB(77, 89, 83)).Orientation = Vector3.new(0, 0, -4)
part(entrance, "CaveDarkness", Vector3.new(28, 28, 1), Vector3.new(0, 14, 301), Color3.fromRGB(19, 29, 28))
for _, x in {-19, 19} do lantern(entrance, Vector3.new(x, 0, 277)) end
local function portal(name, pos, destination)
	local p = part(portals, name, Vector3.new(25, 26, 2), pos, Color3.fromRGB(39, 66, 69))
	p.Transparency = 0.35; p.CanCollide = false; p.CanQuery = false
	p:SetAttribute("Destination", destination)
	return p
end
portal("EnterDireBearCave", Vector3.new(0, 13, 290), "DireBearCave")
marker(destinations, "Grasslands", Vector3.new(0, 1, 0))
marker(destinations, "GrasslandsCaveExit", Vector3.new(0, 1, 269)).CFrame *= CFrame.Angles(0, math.pi, 0)
-- Separate enclosed arena: 230 x 260 studs, 70 studs of headroom.
local center = Vector3.new(650, 0, 400)
part(cave, "Floor", Vector3.new(250, 12, 280), center + Vector3.new(0, -6, 0), rock)
part(cave, "Ceiling", Vector3.new(250, 16, 280), center + Vector3.new(0, 78, 0), rock)
for _, x in {-120, 120} do part(cave, "Wall", Vector3.new(15, 80, 280), center + Vector3.new(x, 35, 0), rock) end
for _, z in {-132, 132} do part(cave, "Wall", Vector3.new(250, 80, 16), center + Vector3.new(0, 35, z), rock) end
for i = 1, 22 do
	local angle = i / 22 * math.pi * 2
	local p = part(cave, "Crystal", Vector3.new(6, random:NextNumber(9, 20), 6), center + Vector3.new(math.cos(angle) * 99, 7, math.sin(angle) * 111), Color3.fromRGB(85, 169, 172), "WedgePart")
	p.Material = Enum.Material.Neon
	p.Orientation = Vector3.new(0, -math.deg(angle), 12)
	local light = Instance.new("PointLight"); light.Color = p.Color; light.Brightness = 1.5; light.Range = 38; light.Parent = p
end
-- Faceted cave walls and ceiling teeth leave the boss arena clear.
for i = 1, 24 do
	local angle = i / 24 * math.pi * 2
	local edge = center + Vector3.new(math.cos(angle) * 110, 0, math.sin(angle) * 123)
	if math.abs(edge.X - center.X) < 26 and edge.Z < center.Z then continue end
	stone(cave, "CaveButtress", edge + Vector3.new(0, 23, 0), Vector3.new(14, 49, 15), Color3.fromRGB(61, 72, 72))
	local tooth = part(cave, "Stalactite", Vector3.new(8, random:NextNumber(10, 21), 9), edge + Vector3.new(0, 65, 0), rock, "WedgePart")
	tooth.Orientation = Vector3.new(180, math.deg(angle), 0)
end
for i = 1, 9 do
	cosmetic(part(cave, "EntryFlagstone", Vector3.new(11, 0.2, 6), center + Vector3.new(math.sin(i) * 2, 0.15, -112 + i * 9), Color3.fromRGB(103, 116, 108)))
end
marker(destinations, "DireBearCave", center + Vector3.new(0, 1, -95)).CFrame *= CFrame.Angles(0, math.pi, 0)
portal("LeaveDireBearCave", center + Vector3.new(0, 13, -122), "GrasslandsCaveExit")
marker(spawns, "Dire Bear", center + Vector3.new(0, 9, 30))
marker(bosses, "Dire Bear", center + Vector3.new(0, 22, 30))
local region = marker(regions, "DireBearCave", center + Vector3.new(0, 35, 0)); region.Size = Vector3.new(250, 100, 280)
-- Replace only generated roots, retaining prior objects in a dated backup.
local backup = folder(folder(SS, "WorldGeneratorBackups"), "Grasslands_" .. os.date("%Y%m%d_%H%M%S"))
local function install(object, parent, name)
	local old = parent:FindFirstChild(name)
	if old then old:SetAttribute("OriginalParent", parent:GetFullName()); old.Parent = backup end
	object.Name = name; object.Parent = parent
end
install(map, folder(workspace, "Maps"), "Grasslands")
install(spawns, folder(workspace, "MobSpawns"), "Grasslands")
install(portals, folder(workspace, "ZonePortals"), "Grasslands")
install(bosses, folder(workspace, "BossRespawns"), "Grasslands")
for _, p in destinations:GetChildren() do install(p, folder(workspace, "ZoneTeleportes"), p.Name) end
for _, p in regions:GetChildren() do install(p, folder(workspace, "ZoneRegions"), p.Name) end
folder(workspace, "Mobs")
folder(folder(RS, "Resources"), "LightingTemplates")
staging:Destroy()
game:GetService("Selection"):Set({map})
print("Grasslands generated. Run mob and BossBar generators, save the place, then Play.")
