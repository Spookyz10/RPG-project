-- Read-only Edit mode audit. Run after 04, 05, 06 (and 07 for combat assets).
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before auditing Forest")
local RS = game:GetService("ReplicatedStorage")
local map = assert(workspace:FindFirstChild("Maps") and workspace.Maps:FindFirstChild("Forest"), "Forest missing")
local rigs = assert(RS:FindFirstChild("Mobs") and RS.Mobs:FindFirstChild("Forest"), "Forest rigs missing")
local spawns = assert(workspace:FindFirstChild("MobSpawns") and workspace.MobSpawns:FindFirstChild("Forest"), "Forest spawns missing")
local failures = {}
local function check(ok, message)
	if not ok then table.insert(failures, message) end
end
check(map:GetAttribute("DesignVersion") == 4, "Map is not v4")
local overlap = OverlapParams.new()
overlap.FilterType = Enum.RaycastFilterType.Include
overlap.FilterDescendantsInstances = {map}
local ray = RaycastParams.new()
ray.FilterType = Enum.RaycastFilterType.Include
ray.FilterDescendantsInstances = {map.Ground}
local counts, parts, collisions = {}, 0, 0
-- Verify the issue that motivated this revision: roots must enter a supporting
-- surface, including trees planted on top of the boundary cliffs.
for _, model in map.Vegetation:GetChildren() do
	local trunk = model:FindFirstChild("RootTrunk")
	if trunk then
		local foot = trunk.CFrame:PointToWorldSpace(Vector3.new(0,0,trunk.Size.Z/2))
		local hit = workspace:Raycast(foot+Vector3.new(0,3,0),Vector3.new(0,-5,0),ray)
		check(hit and hit.Position.Y-foot.Y >= 0.4, "Floating trunk: " .. model.Name)
		for _, root in model:GetChildren() do
			if root:IsA("BasePart") and root:GetAttribute("BuriedBase") then
				local bottom = root.CFrame:PointToWorldSpace(Vector3.new(0,-root.Size.Y/2,0))
				local support = workspace:Raycast(bottom+Vector3.new(0,2,0),Vector3.new(0,-4,0),ray)
				check(support and support.Position.Y-bottom.Y >= 0.15, "Exposed root base: " .. model.Name)
				local join = root.CFrame:PointToWorldSpace(Vector3.new(0,root.Size.Y/2,root.Size.Z/2))
				local localJoin = trunk.CFrame:PointToObjectSpace(join)
				check(math.abs(localJoin.X)<trunk.Size.X/2 and math.abs(localJoin.Y)<trunk.Size.Y/2,
					"Root detached from trunk: " .. model.Name)
			end
		end
	end
end
for _, object in map:GetDescendants() do
	if object:IsA("BasePart") then
		parts += 1
		if object.CanCollide then collisions += 1 end
		check(object.Anchored, "Unanchored map part: " .. object:GetFullName())
		check(not object.CanTouch, "Map decoration should not generate touch events: " .. object.Name)
	end
end
local spawnById = {}
for _, spawn in spawns:GetChildren() do
	counts[spawn.Name] = (counts[spawn.Name] or 0) + 1
	spawnById[spawn:GetAttribute("EncounterId") or "missing"] = spawn
	check(spawn.Transparency == 1 and not spawn.CanCollide and not spawn.CanQuery, "Spawn marker is physical: " .. spawn.Name)
	local rig = rigs:FindFirstChild(spawn.Name)
	check(rig ~= nil, "Missing rig: " .. spawn.Name)
	if not rig then continue end
	local hum = rig:FindFirstChildOfClass("Humanoid")
	local root = rig:FindFirstChild("HumanoidRootPart")
	local hit = workspace:Raycast(spawn.Position + Vector3.new(0,100,0), Vector3.new(0,-200,0), ray)
	check(hit ~= nil and hum ~= nil and root ~= nil, "Spawn has no floor / humanoid / root: " .. spawn.Name)
	if hit and hum and root then
		check(math.abs(spawn.Position.Y-hit.Position.Y-hum.HipHeight-root.Size.Y/2-0.15) < 0.1,
			"Rig changed or spawn is floating: " .. spawn.Name)
		local cf, size = rig:GetBoundingBox()
		for _, obstacle in workspace:GetPartBoundsInBox(spawn.CFrame * rig:GetPivot():ToObjectSpace(cf), size, overlap) do
			check(not obstacle.CanCollide or obstacle:IsDescendantOf(map.Ground),
				"Spawn overlaps " .. obstacle:GetFullName() .. ": " .. spawn.Name)
		end
	end
	for _, water in map.Water:GetChildren() do
		if water.Name == "WaterSurface" then
			local p = water.CFrame:PointToObjectSpace(spawn.Position)
			check(math.sqrt(p.Y*p.Y+p.Z*p.Z) > water.Size.Y/2+4, "Spawn in water: " .. spawn.Name)
		end
	end
end
for species, expected in {Mosscap=8, ["Thornback Stag"]=6, ["Hollow Sentinel"]=5, Elderbark=1} do
	check(counts[species] == expected, "Incorrect spawn count for " .. species)
end
for _, anchor in map.EncounterMarkers:GetChildren() do
	local spawn = spawnById[anchor.Name]
	check(spawn ~= nil, "Missing encounter: " .. anchor.Name)
	if spawn then
		local delta = anchor.Position-spawn.Position
		check(Vector3.new(delta.X,0,delta.Z).Magnitude < 0.05, "Encounter moved independently: " .. anchor.Name)
	end
end
-- Check a continuous player-sized corridor through every authored trail segment.
-- Ignore intentional underlying floor; bridge/ramp geometry is audited separately in Play.
for _, trail in map.Paths:GetDescendants() do
	if trail:IsA("BasePart") and trail.Name == "PackedEarth" then
		local cf = trail.CFrame + Vector3.new(0,3,0)
		for _, obstacle in workspace:GetPartBoundsInBox(cf, Vector3.new(5,5,trail.Size.Z), overlap) do
			check(not obstacle.CanCollide or obstacle:GetAttribute("WalkableRamp"), "Trail obstructed by " .. obstacle:GetFullName())
		end
		for _, water in map.Water:GetChildren() do
			if water.Name == "WaterSurface" then
				local p = water.CFrame:PointToObjectSpace(trail.Position)
				check(math.sqrt(p.Y*p.Y+p.Z*p.Z) > water.Size.Y/2+2.5, "Trail enters water: " .. trail.Parent.Name)
			end
		end
	end
end
for _, rig in rigs:GetChildren() do
	local root = rig:FindFirstChild("HumanoidRootPart")
	check(root ~= nil and rig.PrimaryPart == root, "Invalid rig pivot: " .. rig.Name)
	check(rig:GetAttribute("DesignVersion") == 4, "Old rig: " .. rig.Name)
	local connected = {[root]=true}
	local joints = {}
	for _, object in rig:GetDescendants() do
		if object:IsA("Motor6D") or object:IsA("WeldConstraint") then
			check(object.Part0 ~= nil and object.Part1 ~= nil, "Broken joint: " .. rig.Name .. "/" .. object.Name)
			table.insert(joints,object)
		end
	end
	for _=1,#joints do
		local changed = false
		for _, joint in joints do
			if connected[joint.Part0] and not connected[joint.Part1] then connected[joint.Part1]=true; changed=true end
		end
		if not changed then break end
	end
	for _, object in rig:GetDescendants() do
		if object:IsA("BasePart") then
			check(connected[object], "Detached rig detail: " .. rig.Name .. "/" .. object.Name)
			check(not object.Anchored, "Anchored rig detail: " .. rig.Name .. "/" .. object.Name)
			check(object == root or (object.Massless and not object.CanCollide), "Physical ornament: " .. object.Name)
		end
	end
end
local resources = RS:FindFirstChild("Resources")
local templates = resources and resources:FindFirstChild("LightingTemplates")
check(templates and templates:FindFirstChild("Forest") ~= nil, "Lighting template missing")
check(workspace.ZoneRegions:FindFirstChild("Forest") ~= nil, "Forest lighting region missing")
check(workspace.ZoneRegions:FindFirstChild("Elderbark Heartgrove") ~= nil, "Boss arena missing")
check(workspace.ZoneTeleporters:FindFirstChild("Forest") ~= nil, "Teleport destination missing")
print(string.format("Forest audit: %d map parts, %d colliders, %d failures", parts, collisions, #failures))
for _, message in failures do warn(message) end
assert(#failures == 0, "Forest audit failed. Fix the reported geometry before Play.")
print("Static Forest audit passed. Still playtest traversal, pursuit, skills, lighting transitions and respawn.")
