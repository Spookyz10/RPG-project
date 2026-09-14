-- Forest combat VFX and craftable weapon models. Run in Edit after 06.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating combat assets")
local RS, SS = game:GetService("ReplicatedStorage"), game:GetService("ServerStorage")
local V, C = Vector3.new, Color3.fromRGB
local function folder(parent, name)
	local f = parent:FindFirstChild(name)
	if not f then
		f = Instance.new("Folder")
		f.Name = name
		f.Parent = parent
	end
	return f
end
local resources = folder(RS, "Resources")
local destination = folder(folder(resources, "CombatVFX"), "Attacks")
local backup = folder(folder(SS, "WorldGeneratorBackups"), "ForestCombat_" .. os.date("%Y%m%d_%H%M%S"))
local function install(model, parent)
	local old = parent:FindFirstChild(model.Name)
	if old then
		old:SetAttribute("OriginalParent", parent:GetFullName())
		old.Parent = backup
	end
	model.Parent = parent
end
local function part(model, name, size, cf, color, shape)
	local p = Instance.new(shape or "Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = model
	return p
end
local mint, gold, bark = C(137, 216, 166), C(230, 190, 110), C(106, 79, 50)
local function model(name)
	local m = Instance.new("Model")
	m.Name = name
	local anchor = part(m, "Anchor", V(0.2, 0.2, 0.2), CFrame.identity, mint)
	anchor.Transparency = 1
	m.PrimaryPart = anchor
	m:SetAttribute("Duration", 0.7)
	return m
end
local function ring(m, r, color)
	for i = 0, 23 do
		local a = i * math.pi / 12
		local p = part(
			m,
			"PulseArc",
			V(0.22, 0.16, r * 0.27),
			CFrame.new(math.cos(a) * r, 0.2, math.sin(a) * r) * CFrame.Angles(0, -a, 0),
			color
		)
		p.Material = Enum.Material.Neon
		p.Transparency = 0.3
	end
end
local function root(m, x, z, h)
	local p =
		part(m, "RootSpear", V(1.2, h, 1.6), CFrame.new(x, h / 2, z) * CFrame.Angles(-0.18, 0, 0.2), bark, "WedgePart")
	part(m, "RootTip", V(0.5, h * 0.45, 0.6), p.CFrame * CFrame.new(0, h * 0.35, 0), mint, "WedgePart")
end
for _, spec in
	{
		{ "SporeBloom", 7, mint },
		{ "SporeEcho", 10, mint },
		{ "HeartSlam", 18, gold },
		{ "ElderRoots", 6, mint },
	}
do
	local m = model(spec[1])
	ring(m, spec[2], spec[3])
	if spec[1] == "ElderRoots" then
		m:SetAttribute("RiseDistance", 4)
		for i = 0, 7 do
			local a = i * math.pi / 4
			root(m, math.cos(a) * 4, math.sin(a) * 4, 5 + (i % 2))
		end
	else
		m:SetAttribute("ExpandFrom", 0.65)
		for i = 0, 11 do
			local a = i * math.pi / 6
			local radius = spec[2] * 0.75
			local p = part(
				m,
				"SporeOrDebris",
				V(0.55, 0.8, 0.55),
				CFrame.new(math.cos(a) * radius, 1 + (i % 3) * 0.7, math.sin(a) * radius),
				spec[3],
				"WedgePart"
			)
			p.Transparency = 0.25
		end
	end
	install(m, destination)
end
local lanes = model("SentinelRoots")
lanes:SetAttribute("RiseDistance", 3)
for z = -11, 11, 5.5 do
	for _, x in { -3, 3 } do
		root(lanes, x, z, 3.5)
	end
end
install(lanes, destination)
local charge = model("AntlerRush")
for _, side in { -1, 1 } do
	for i = 1, 5 do
		local p = part(
			charge,
			"LeafWake",
			V(0.4, 0.25, 1.5),
			CFrame.new(side * (1 + i * 0.4), -1, 1 + i * 0.8) * CFrame.Angles(0, side * 0.4, 0),
			mint,
			"WedgePart"
		)
		p.Transparency = 0.35
	end
end
install(charge, destination)
for _, spec in
	{
		{ "MosscapMelee", 7, mint },
		{ "Thornback StagMelee", 8, gold },
		{ "Hollow SentinelMelee", 9, mint },
		{ "ElderbarkMelee", 20, gold },
		{ "RootSweep", 26, gold },
	}
do
	local m = model(spec[1])
	m:SetAttribute("Duration", 0.35)
	for i = 0, 10 do
		local t = i / 10
		local x = (t - 0.5) * spec[2]
		local p =
			part(m, "StrikeArc", V(spec[2] / 10, 0.25, 0.4), CFrame.new(x, 0.5, -math.sin(t * math.pi) * 2), spec[3])
		p.Material = Enum.Material.Neon
		p.Transparency = 0.2
	end
	install(m, destination)
end
-- WeaponLoader expects a Model with Handle and optional GripPoint; never anchored on equip.
local weapons = folder(resources, "Weapons")
for _, name in { "Thornwood Blade", "Heartwood Cleaver" } do
	local m = Instance.new("Model")
	m.Name = name
	local heavy = name == "Heartwood Cleaver"
	local handle = part(m, "Handle", V(0.4, 1.5, 0.4), CFrame.identity, bark)
	m.PrimaryPart = handle
	local grip = Instance.new("Attachment")
	grip.Name = "GripPoint"
	grip.Parent = handle
	m:SetAttribute("GripPosition", V(0, -0.4, 0))
	m:SetAttribute("GripOrientation", V(0, 0, 0))
	part(m, "RootGuard", V(heavy and 2.2 or 1.7, 0.4, 0.55), CFrame.new(0, 0.8, 0), gold)
	part(m, "HeartwoodBlade", V(heavy and 1.5 or 0.7, heavy and 3.5 or 3, 0.4), CFrame.new(0, 2.6, 0), bark)
	part(
		m,
		"PaleEdge",
		V(0.22, heavy and 3.6 or 3.1, 0.45),
		CFrame.new(heavy and 0.8 or 0.42, 2.6, 0),
		C(208, 216, 171),
		"WedgePart"
	)
	for i = 1, 3 do
		part(
			m,
			"Thorn",
			V(0.7, 0.65, 0.4),
			CFrame.new(-0.5, 1.4 + i * 0.8, 0) * CFrame.Angles(0, 0, -0.4),
			mint,
			"WedgePart"
		)
	end
	local seed = part(m, "HeartSeed", V(0.35, 0.6, 0.5), CFrame.new(0, 1.3, -0.05), heavy and gold or mint)
	seed.Material = Enum.Material.Neon
	for _, p in m:GetChildren() do
		if p:IsA("BasePart") then
			p.Anchored = false
			p.Massless = true
		end
	end
	install(m, weapons)
end
print(
	"Forest assets saved: 11 attack templates and 2 craftable weapons. Existing versions preserved in WorldGeneratorBackups."
)
