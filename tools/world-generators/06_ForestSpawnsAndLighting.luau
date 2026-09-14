-- Run after 04_Forest and 05_ForestMobModels, in Studio Edit mode.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating Forest spawns and lighting")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local maps = workspace:FindFirstChild("Maps")
local map = maps and maps:FindFirstChild("Forest")
assert(map and map:IsA("Model"), "Generate Forest v4 first")
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
-- The map owns encounter positions. Never silently move a spawn away from its
-- authored pocket: a blocked marker is an actionable authoring error.
assert(map:GetAttribute("DesignVersion") == 4, "Regenerate Forest with 04 before running 06")
local encounters = assert(map:FindFirstChild("EncounterMarkers"), "Forest encounter markers missing")
local overlap = OverlapParams.new()
overlap.FilterType = Enum.RaycastFilterType.Include
overlap.FilterDescendantsInstances = { map }
local installed = {}
for _, anchor in encounters:GetChildren() do
	local name = anchor:GetAttribute("Species")
	local rig = rigs:FindFirstChild(name)
	local hum = rig and rig:FindFirstChildOfClass("Humanoid")
	local root = rig and rig:FindFirstChild("HumanoidRootPart")
	assert(hum and root, "Missing Forest rig: " .. tostring(name))
	assert(rig:GetAttribute("DesignVersion") == 4, "Regenerate Forest rigs with 05 first")
	local hit = workspace:Raycast(anchor.Position + Vector3.new(0, 100, 0), Vector3.new(0, -200, 0), ray)
	assert(hit and hit.Normal.Y > 0.95 and math.abs(hit.Position.Y - anchor.Position.Y + 3) < 1,
		"Encounter must be on the glade floor: " .. anchor.Name)
	local clearance = hum.HipHeight + root.Size.Y / 2
	local boxCF, boxSize = rig:GetBoundingBox()
	local position = hit.Position + Vector3.new(0, clearance + 0.15, 0)
	local spawnCF = CFrame.new(position) * anchor.CFrame.Rotation
	for _, water in map.Water:GetChildren() do
		if water.Name == "WaterSurface" then
			local point = water.CFrame:PointToObjectSpace(position)
			assert(math.sqrt(point.Y*point.Y + point.Z*point.Z) > water.Size.Y/2 + 4,
				"Encounter intersects water: " .. anchor.Name)
		end
	end
	local localBounds = rig:GetPivot():ToObjectSpace(boxCF)
	-- Full visible silhouette, not just a small HumanoidRootPart.
	local checkCF = spawnCF * localBounds + Vector3.new(0, 0.1, 0)
	for _, obstacle in workspace:GetPartBoundsInBox(checkCF, boxSize, overlap) do
		assert(not obstacle.CanCollide or obstacle:IsDescendantOf(ground),
			"Blocked encounter " .. anchor.Name .. " by " .. obstacle:GetFullName())
	end
	for _, previous in installed do
		assert((previous.Position-position).Magnitude > 18, "Encounters too close: " .. anchor.Name)
	end
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, Vector3.one, spawnCF
	p.Anchored, p.Transparency = true, 1
	p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
	p:SetAttribute("EncounterId", anchor.Name)
	p.Parent = staging
	table.insert(installed, p)
end
assert(#installed == map:GetAttribute("EncounterCount"), "Incomplete Forest encounters")
local template = folder(nil, "Forest")
local properties = {
	ClockTime = 15.7,
	Brightness = 2.6,
	ExposureCompensation = 0.08,
	Ambient = Color3.fromRGB(84, 105, 103),
	OutdoorAmbient = Color3.fromRGB(132, 145, 123),
	ColorShift_Top = Color3.fromRGB(245, 218, 166),
	ColorShift_Bottom = Color3.fromRGB(40, 66, 57),
	EnvironmentDiffuseScale = 0.8,
	EnvironmentSpecularScale = 0.35,
	GlobalShadows = true,
	ShadowSoftness = 0.3,
	FogColor = Color3.fromRGB(145, 177, 161),
	FogStart = 160,
	FogEnd = 750,
}
for name, value in properties do
	template:SetAttribute(name, value)
end
local atmosphere = Instance.new("Atmosphere")
atmosphere.Name = "ForestHaze"
atmosphere.Density = 0.24
atmosphere.Offset = 0.15
atmosphere.Color = Color3.fromRGB(181, 208, 184)
atmosphere.Decay = Color3.fromRGB(99, 125, 117)
atmosphere.Glare = 0.18
atmosphere.Haze = 1.1
atmosphere.Parent = template
local grade = Instance.new("ColorCorrectionEffect")
grade.Name = "ForestGrade"
grade.Brightness = 0.015
grade.Contrast = 0.09
grade.Saturation = 0.025
grade.TintColor = Color3.fromRGB(255, 250, 238)
grade.Parent = template
local bloom = Instance.new("BloomEffect")
bloom.Name = "SoftLanternBloom"
bloom.Intensity = 0.12
bloom.Size = 24
bloom.Threshold = 1.35
bloom.Parent = template
local rays = Instance.new("SunRaysEffect")
rays.Name = "CanopySunlight"
rays.Intensity = 0.045
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
	"Forest v4: 20 checked encounters and Amberwood regional lighting saved. Run 08 to audit; sync Common before Play."
)
