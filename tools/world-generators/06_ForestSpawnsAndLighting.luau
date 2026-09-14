-- Run after 04_Forest and 05_ForestMobModels, in Studio Edit mode.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating Forest spawns and lighting")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local maps = workspace:FindFirstChild("Maps")
local map = maps and maps:FindFirstChild("Forest")
assert(map and map:IsA("Model"), "Generate Forest v2 first")
local markers = map:FindFirstChild("PlanningMarkers")
local ground = map:FindFirstChild("Ground")
local rigs = RS:FindFirstChild("Mobs") and RS.Mobs:FindFirstChild("Forest")
assert(markers and ground and rigs, "Generate the Forest map and rigs first")
local function folder(parent, name)
	local f = parent and parent:FindFirstChild(name)
	if not f then
		f = Instance.new("Folder")
		f.Name = name
		f.Parent = parent
	end
	return f
end
local staging = folder(nil, "Forest")
local ray = RaycastParams.new()
ray.FilterType = Enum.RaycastFilterType.Include
ray.FilterDescendantsInstances = { ground }
-- Every hub gets life, while the entry keeps a 50+ stud buffer before the
-- first aggro radius. Offsets follow saved marker orientation, so moving or
-- rotating the map also moves the encounter ecology with it.
local definitions = {
	{
		"Mosscap",
		"Entry",
		{ Vector3.new(-34, 0, 48), Vector3.new(34, 0, 54) },
	},
	{
		"Mosscap",
		"Crossroads",
		{ Vector3.new(-31, 0, -14), Vector3.new(29, 0, -12), Vector3.new(-4, 0, 34) },
	},
	{
		"Mosscap",
		"Mosscap",
		{
			Vector3.new(-31, 0, -20),
			Vector3.new(29, 0, -19),
			Vector3.new(-27, 0, 24),
			Vector3.new(31, 0, 22),
		},
	},
	{
		"Mosscap",
		"Shrine",
		{ Vector3.new(-25, 0, -14), Vector3.new(27, 0, 18) },
	},
	{
		"Thornback Stag",
		"Moonwater",
		{
			Vector3.new(-46, 0, -18),
			Vector3.new(45, 0, -19),
			Vector3.new(-42, 0, 28),
			Vector3.new(43, 0, 27),
		},
	},
	{
		"Thornback Stag",
		"HeartTree",
		{ Vector3.new(-47, 0, -25), Vector3.new(47, 0, -25), Vector3.new(50, 0, 30) },
	},
	{
		"Thornback Stag",
		"Lookout",
		{ Vector3.new(-34, 0, -31), Vector3.new(-18, 0, 25) },
	},
	{
		"Hollow Sentinel",
		"Ruins",
		{
			Vector3.new(-42, 0, -23),
			Vector3.new(43, 0, -23),
			Vector3.new(-44, 0, 27),
			Vector3.new(43, 0, 28),
			Vector3.new(0, 0, 45),
		},
	},
	{
		"Hollow Sentinel",
		"Lookout",
		{ Vector3.new(-38, 0, 3), Vector3.new(-19, 0, 4) },
	},
	{ "Elderbark", "Elderbark", { Vector3.zero } },
}

-- A small local search prevents a single moved cliff edge from cancelling the
-- entire generator. It stays in the anchor's local space, so rotated maps work.
local groundSearchOffsets = {
	Vector3.zero,
	Vector3.new(12, 0, 0),
	Vector3.new(-12, 0, 0),
	Vector3.new(0, 0, 12),
	Vector3.new(0, 0, -12),
	Vector3.new(24, 0, 0),
	Vector3.new(-24, 0, 0),
	Vector3.new(0, 0, 24),
	Vector3.new(0, 0, -24),
}

local function findForestGround(anchor, offset)
	for _, adjustment in groundSearchOffsets do
		local position = anchor.CFrame:PointToWorldSpace(offset + adjustment)
		local hit = workspace:Raycast(position + Vector3.new(0, 150, 0), Vector3.new(0, -350, 0), ray)
		if hit then
			return hit
		end
	end
end

for _, definition in definitions do
	local name, anchorName, offsets = table.unpack(definition)
	local anchor = markers:FindFirstChild(anchorName)
	local rig = rigs:FindFirstChild(name)
	local hum = rig and rig:FindFirstChildOfClass("Humanoid")
	local root = rig and rig:FindFirstChild("HumanoidRootPart")
	assert(anchor and hum and root, "Missing marker or rig: " .. name)
	for _, offset in offsets do
		local hit = findForestGround(anchor, offset)
		assert(hit, "No Forest ground beneath " .. name)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = Vector3.one
		p.CFrame = CFrame.new(hit.Position + Vector3.new(0, hum.HipHeight + root.Size.Y / 2 + 0.3, 0))
			* anchor.CFrame.Rotation
		p.Anchored = true
		p.Transparency = 1
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.Parent = staging
	end
end
local template = folder(nil, "Forest")
local properties = {
	ClockTime = 16.2,
	Brightness = 2.2,
	ExposureCompensation = 0.05,
	Ambient = Color3.fromRGB(79, 99, 91),
	OutdoorAmbient = Color3.fromRGB(115, 135, 116),
	ColorShift_Top = Color3.fromRGB(231, 205, 150),
	ColorShift_Bottom = Color3.fromRGB(40, 66, 57),
	EnvironmentDiffuseScale = 0.65,
	EnvironmentSpecularScale = 0.35,
	GlobalShadows = true,
	ShadowSoftness = 0.4,
	FogColor = Color3.fromRGB(145, 177, 161),
	FogStart = 160,
	FogEnd = 750,
}
for name, value in properties do
	template:SetAttribute(name, value)
end
local atmosphere = Instance.new("Atmosphere")
atmosphere.Name = "ForestHaze"
atmosphere.Density = 0.28
atmosphere.Offset = 0.15
atmosphere.Color = Color3.fromRGB(181, 208, 184)
atmosphere.Decay = Color3.fromRGB(99, 125, 117)
atmosphere.Glare = 0.18
atmosphere.Haze = 1.25
atmosphere.Parent = template
local grade = Instance.new("ColorCorrectionEffect")
grade.Name = "ForestGrade"
grade.Brightness = 0.015
grade.Contrast = 0.12
grade.Saturation = -0.06
grade.TintColor = Color3.fromRGB(241, 249, 229)
grade.Parent = template
local bloom = Instance.new("BloomEffect")
bloom.Name = "SoftLanternBloom"
bloom.Intensity = 0.18
bloom.Size = 24
bloom.Threshold = 1.35
bloom.Parent = template
local rays = Instance.new("SunRaysEffect")
rays.Name = "CanopySunlight"
rays.Intensity = 0.065
rays.Spread = 0.8
rays.Parent = template
-- Keep the authored sky, if one exists, instead of replacing it with an unrelated skybox.
local sky = game:GetService("Lighting"):FindFirstChildOfClass("Sky")
if sky then
	sky:Clone().Parent = template
end
local region = Instance.new("Part")
region.Name = "Forest"
region.Anchored = true
region.Transparency = 1
region.CanCollide = false
region.CanTouch = false
region.CanQuery = false
local cf, size = map:GetBoundingBox()
region.CFrame = cf
region.Size = size + Vector3.new(12, 100, 12)
local backup = folder(folder(SS, "WorldGeneratorBackups"), "ForestSetup_" .. os.date("%Y%m%d_%H%M%S"))
local function install(object, parent)
	local old = parent:FindFirstChild(object.Name)
	if old then
		old:SetAttribute("OriginalParent", parent:GetFullName())
		old.Parent = backup
	end
	object.Parent = parent
end
install(staging, folder(workspace, "MobSpawns"))
install(template, folder(folder(RS, "Resources"), "LightingTemplates"))
install(region, folder(workspace, "ZoneRegions"))
local destination = markers.Entry:Clone()
destination.Name = map.Name
destination.Size = Vector3.one
destination.Transparency = 1
destination.CanCollide = false
destination.CanTouch = false
destination.CanQuery = false
destination:SetAttribute("PlanningOnly", nil)
install(destination, folder(workspace, "ZoneTeleporters"))
local arena = region:Clone()
arena.Name = "Elderbark Heartgrove"
arena.CFrame = markers.Elderbark.CFrame * CFrame.new(0, 15, 0)
arena.Size = Vector3.new(112, 70, 112)
install(arena, folder(workspace, "ZoneRegions"))
local bosses = folder(nil, "Forest")
local bossMarker = staging:FindFirstChild("Elderbark"):Clone()
bossMarker.CFrame += Vector3.new(0, 14, 0)
bossMarker.Parent = bosses
install(bosses, folder(workspace, "BossRespawns"))

-- Real, restrained local illumination on the existing lanterns and shrine offerings.
for _, p in map:GetDescendants() do
	if p:IsA("BasePart") and (p.Name == "AmberGlass" or p.Name == "OfferingPearl") then
		local light = p:FindFirstChild("ForestAccent") or Instance.new("PointLight")
		light.Name = "ForestAccent"
		light.Color = p.Color
		light.Brightness = p.Name == "AmberGlass" and 1.2 or 0.35
		light.Range = p.Name == "AmberGlass" and 16 or 7
		light.Shadows = false
		light.Parent = p
	end
end
game:GetService("Selection"):Set({ staging, region })
print(
	"Forest: 28 distributed MobSpawns and regional lighting saved. Sync Common and run 07_ForestCombatAssets before Play."
)
