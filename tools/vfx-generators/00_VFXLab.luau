-- STUDIO COMMAND BAR / EDIT MODE ONLY. Paste this entire file while Play is stopped.
-- Saves templates in ReplicatedStorage.Resources.CombatVFX and a preview lab in Workspace.
-- Runtime scripts clone these saved templates; run this generator once before Play.
-- Select a Part/Model to place the lab nearby. Otherwise uses the camera focus.
-- ParticleEmitters start disabled. EmitCount/EmitDelay are plugin hints only.
-- Beams start disabled: toggle Enabled to preview them (Beams have no Emit method).
local RunService = game:GetService("RunService")
assert(not RunService:IsRunning(), "Stop Play before generating the VFX lab.")
local Selection = game:GetService("Selection")
local History = game:GetService("ChangeHistoryService")
local ServerStorage = game:GetService("ServerStorage")

local LAB_NAME = "RPGVFXLab"
local SPACING = 15
local TEXTURES = {
	Smoke = "rbxasset://textures/particles/smoke_main.dds",
	Spark = "rbxasset://textures/particles/sparkles_main.dds",
	Streak = "rbxasset://textures/particles/fire_sparks_main.dds",
	Chip = "rbxasset://textures/particles/SquareParticle.png",
	-- White ring from the official ParticleEmitter documentation.
	Ring = "rbxassetid://1266170131",
}
local green = Color3.fromRGB(143, 225, 56)
local darkGreen = Color3.fromRGB(44, 97, 34)
local gold = Color3.fromRGB(255, 183, 59)
local mint = Color3.fromRGB(134, 255, 188)
local ivory = Color3.fromRGB(255, 239, 193)
local dirt = Color3.fromRGB(125, 96, 62)

local function seq(points)
	local keys = {}
	for _, point in points do
		table.insert(keys, NumberSequenceKeypoint.new(point[1], point[2]))
	end
	return NumberSequence.new(keys)
end
local fade = seq({{0, 1}, {0.08, 0.1}, {0.55, 0.35}, {1, 1}})
local origin = workspace.CurrentCamera and workspace.CurrentCamera.Focus.Position or Vector3.new(0, 3, 0)
for _, selected in Selection:Get() do
	if selected:IsA("BasePart") or selected:IsA("Model") then
		origin = selected:GetPivot().Position + Vector3.new(12, 0, 0)
		break
	end
end
local lab = Instance.new("Model")
lab.Name = LAB_NAME
lab:SetAttribute("Generator", "BootlegVFXLab")
lab:SetAttribute("Version", 1)
lab:SetAttribute("Help", "Expand a preset; emit its ParticleEmitters. Beam.Enabled previews beams. No scripts installed.")
local index = 0
local function preset(name, description)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("Description", description)
	model.Parent = lab
	local holder = Instance.new("Part")
	holder.Name = "VFXOrigin"
	holder.Size = Vector3.new(1, 1, 1)
	holder.Transparency = 1
	holder.Anchored = true
	holder.CanCollide = false
	holder.CanTouch = false
	holder.CanQuery = false
	holder.CastShadow = false
	holder.CFrame = CFrame.new(origin + Vector3.new((index % 3) * SPACING, 0, math.floor(index / 3) * SPACING))
	holder.Parent = model
	model.PrimaryPart = holder
	index += 1
	return holder
end
local function at(holder, name, position, tangent)
	local attachment = Instance.new("Attachment")
	attachment.Name = name
	attachment.CFrame = tangent and CFrame.fromMatrix(position, tangent, Vector3.yAxis) or CFrame.new(position)
	attachment.Parent = holder
	return attachment
end
local function emit(parent, name, texture, color, count, properties)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = name
	emitter.Texture = texture
	emitter.Color = ColorSequence.new(color)
	emitter.Enabled = false
	emitter.Rate = 0
	emitter.Lifetime = NumberRange.new(0.4, 0.7)
	emitter.Speed = NumberRange.new(1, 3)
	emitter.SpreadAngle = Vector2.new(30, 30)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.Size = seq({{0, 0.15}, {0.2, 0.5}, {1, 0}})
	emitter.Transparency = fade
	emitter.LightInfluence = 0
	emitter.LightEmission = 0.35
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-35, 35)
	emitter.VelocityInheritance = 0
	for key, value in properties or {} do emitter[key] = value end
	emitter:SetAttribute("EmitCount", count)
	emitter:SetAttribute("EmitDelay", 0)
	emitter:SetAttribute("EmitDuration", 0)
	emitter.Parent = parent
	return emitter
end
local function ring(parent, name, color, diameter, lifetime)
	return emit(parent, name, TEXTURES.Ring, color, 1, {
		Lifetime = NumberRange.new(lifetime), Speed = NumberRange.new(0.01),
		SpreadAngle = Vector2.zero, Rotation = NumberRange.new(0), RotSpeed = NumberRange.new(0),
		Orientation = Enum.ParticleOrientation.VelocityPerpendicular,
		Size = seq({{0, 0.3}, {0.65, diameter * 0.85}, {1, diameter}}),
		Transparency = seq({{0, 0.1}, {0.25, 0.2}, {1, 1}}), LightEmission = 0.7,
	})
end
local function beam(holder, name, a, b, color, width, curve, duration)
	local effect = Instance.new("Beam")
	effect.Name = name
	effect.Attachment0, effect.Attachment1 = a, b
	effect.Enabled = false
	-- Untextured ribbons avoid seams at the four curved ring segments.
	effect.Color = ColorSequence.new(color)
	effect.Transparency = NumberSequence.new(0.2)
	effect.Width0, effect.Width1 = width, width
	effect.CurveSize0, effect.CurveSize1 = curve or 0, curve or 0
	effect.Segments = 16
	effect.FaceCamera = true
	effect.LightEmission = 0.8
	effect.LightInfluence = 0
	effect:SetAttribute("PreviewDuration", duration or 0.5)
	effect.Parent = holder
	return effect
end
local function beamRing(holder, name, radius, height, color, width)
	local attachments = {}
	for i = 0, 3 do
		local angle = i * math.pi / 2
		attachments[i + 1] = at(holder, name .. "_Point" .. (i + 1),
			Vector3.new(math.cos(angle) * radius, height, math.sin(angle) * radius),
			Vector3.new(-math.sin(angle), 0, math.cos(angle)))
	end
	for i = 1, 4 do
		beam(holder, name .. "_Arc" .. i, attachments[i], attachments[i % 4 + 1], color, width, radius * 0.55228475, 1.2)
	end
end

local function build()
	local poison = preset("01_Poison", "Slow green fumes, rising toxic bubbles and short tick sparks. Rate is configured for optional continuous preview.")
	local waist = at(poison, "Waist", Vector3.new(0, 1.4, 0))
	emit(waist, "ToxicFumes", TEXTURES.Smoke, green, 9, {
		Rate = 6, Lifetime = NumberRange.new(1.3, 2), Speed = NumberRange.new(0.4, 1),
		Acceleration = Vector3.new(0, 1, 0), SpreadAngle = Vector2.new(65, 65),
		Color = ColorSequence.new(green, darkGreen), LightEmission = 0.08,
		Size = seq({{0, 0.4}, {0.45, 1.4}, {1, 2.1}}),
		Transparency = seq({{0, 1}, {0.2, 0.6}, {0.6, 0.8}, {1, 1}}),
	})
	emit(waist, "ToxicBubbles", TEXTURES.Ring, green, 12, {
		Rate = 8, Lifetime = NumberRange.new(0.8, 1.6), Speed = NumberRange.new(1, 2.5),
		SpreadAngle = Vector2.new(70, 70), Acceleration = Vector3.new(0, 1.3, 0),
		Size = seq({{0, 0.08}, {0.35, 0.24}, {0.8, 0.3}, {1, 0}}),
	})
	emit(waist, "DamageTick", TEXTURES.Spark, green, 5, {LightEmission = 0.8})

	local venom = preset("02_VenomMark", "Green orbit and suspended motes; distinct from poison smoke. Enable the four Beams together.")
	beamRing(venom, "VenomOrbit", 1.5, 1.4, green, 0.075)
	local mark = at(venom, "Mark", Vector3.new(0, 2, 0))
	emit(mark, "MarkMotes", TEXTURES.Spark, green, 10, {
		Rate = 5, Lifetime = NumberRange.new(1, 1.5), Speed = NumberRange.new(0.3, 0.8),
		SpreadAngle = Vector2.new(180, 180), LightEmission = 0.7,
	})
	ring(at(venom, "Ground", Vector3.new(0, 0.08, 0)), "MarkPulse", green, 3.5, 0.6)

	local warning = preset("03_SpikeWarning", "Six-stud green telegraph, matching the existing spike footprint. Beam ring is static until disabled.")
	beamRing(warning, "WarningRing", 3, 0.08, green, 0.1)
	local ground = at(warning, "Ground", Vector3.new(0, 0.1, 0))
	ring(ground, "WarningPulse", green, 6, 2)
	emit(ground, "GatheringMotes", TEXTURES.Spark, green, 18, {
		Lifetime = NumberRange.new(0.5, 1), Speed = NumberRange.new(0.5, 2), SpreadAngle = Vector2.new(85, 85),
	})

	local spike = preset("04_SpikeEruption", "Ground burst only: dust, sprite chips, upward streaks and a shock ring. No spike geometry.")
	local eruption = at(spike, "Ground", Vector3.new(0, 0.12, 0))
	emit(eruption, "EarthDust", TEXTURES.Smoke, dirt, 16, {
		Lifetime = NumberRange.new(0.45, 0.9), Speed = NumberRange.new(5, 9), Drag = 7,
		SpreadAngle = Vector2.new(85, 85), LightEmission = 0,
		Size = seq({{0, 0.5}, {0.25, 1.3}, {1, 2.4}}),
		Transparency = seq({{0, 0.25}, {0.4, 0.65}, {1, 1}}),
	})
	emit(eruption, "DirtChips", TEXTURES.Chip, dirt, 20, {
		Lifetime = NumberRange.new(0.35, 0.7), Speed = NumberRange.new(6, 12),
		SpreadAngle = Vector2.new(65, 65), Acceleration = Vector3.new(0, -32, 0),
		Size = seq({{0, 0.12}, {0.5, 0.1}, {1, 0}}), RotSpeed = NumberRange.new(-180, 180), LightEmission = 0,
	})
	emit(eruption, "ThornStreaks", TEXTURES.Streak, green, 14, {
		Lifetime = NumberRange.new(0.2, 0.4), Speed = NumberRange.new(14, 22),
		SpreadAngle = Vector2.new(12, 12), Orientation = Enum.ParticleOrientation.VelocityParallel,
		Size = seq({{0, 0.7}, {0.3, 1.1}, {1, 0}}), Rotation = NumberRange.new(0), RotSpeed = NumberRange.new(0),
	})
	ring(eruption, "EarthShockRing", ivory, 6, 0.35)
	for i = 1, 3 do
		local x = (i - 2) * 0.7
		local a = at(spike, "RiseStart" .. i, Vector3.new(x, 0.15, 0))
		local b = at(spike, "RiseEnd" .. i, Vector3.new(x * 1.4, 5, 0))
		local rise = beam(spike, "RiseFlash" .. i, a, b, green, 0.13, 0, 0.16)
		rise.Width1 = 0
		rise.Transparency = seq({{0, 0.7}, {0.35, 0.1}, {1, 1}})
	end

	local heal = preset("05_Regrowth", "Mint recovery: rising sparks, soft glow and a ground pulse.")
	local healGround = at(heal, "Ground", Vector3.new(0, 0.1, 0))
	emit(healGround, "HealingSparks", TEXTURES.Spark, mint, 22, {
		Lifetime = NumberRange.new(0.7, 1.2), Speed = NumberRange.new(2, 4),
		SpreadAngle = Vector2.new(35, 35), LightEmission = 0.85,
	})
	emit(healGround, "SoftGlow", TEXTURES.Smoke, mint, 5, {
		Lifetime = NumberRange.new(0.6, 1), Speed = NumberRange.new(1, 2),
		Size = seq({{0, 0.8}, {0.5, 1.7}, {1, 2.2}}),
		Transparency = seq({{0, 1}, {0.2, 0.8}, {1, 1}}),
	})
	ring(healGround, "HealPulse", mint, 4.5, 0.65)

	local fury = preset("06_FuryCharge", "Amber charged-weapon sparks and two curved energy ribbons. Emit sparks; toggle Beams for the charged state.")
	local charge = at(fury, "Charge", Vector3.new(0, 1.5, 0))
	emit(charge, "ChargedSparks", TEXTURES.Spark, gold, 16, {
		Rate = 7, Lifetime = NumberRange.new(0.3, 0.7), Speed = NumberRange.new(2, 4),
		SpreadAngle = Vector2.new(180, 180), LightEmission = 1,
	})
	emit(charge, "HotStreaks", TEXTURES.Streak, ivory, 8, {
		Lifetime = NumberRange.new(0.2, 0.35), Speed = NumberRange.new(5, 9),
		Orientation = Enum.ParticleOrientation.VelocityParallel, LightEmission = 1,
	})
	for i = -1, 1, 2 do
		local a = at(fury, "ChargeStart" .. i, Vector3.new(-0.6, 0, i * 0.15), Vector3.new(i, 0, 0))
		local b = at(fury, "ChargeEnd" .. i, Vector3.new(0.6, 3, i * 0.15), Vector3.new(-i, 0, 0))
		beam(fury, "EnergyRibbon" .. i, a, b, gold, 0.09, 1.5, 1)
	end

	local maul = preset("07_DireMaul", "Heavy ivory/amber impact: flash, outward sparks, dust and shock ring.")
	local impact = at(maul, "Impact", Vector3.new(0, 1.5, 0))
	emit(impact, "ImpactFlash", TEXTURES.Spark, ivory, 2, {
		Lifetime = NumberRange.new(0.12), Speed = NumberRange.new(0), LightEmission = 1,
		Size = seq({{0, 2.8}, {1, 0}}), Transparency = seq({{0, 0}, {1, 1}}),
	})
	emit(impact, "ImpactSparks", TEXTURES.Streak, gold, 20, {
		Lifetime = NumberRange.new(0.18, 0.4), Speed = NumberRange.new(8, 15), Drag = 4,
		SpreadAngle = Vector2.new(180, 180), Orientation = Enum.ParticleOrientation.VelocityParallel,
		Size = seq({{0, 0.6}, {1, 0}}), LightEmission = 0.9,
	})
	emit(impact, "ImpactDust", TEXTURES.Smoke, dirt, 7, {
		Lifetime = NumberRange.new(0.3, 0.6), Speed = NumberRange.new(2, 5),
		SpreadAngle = Vector2.new(180, 180), LightEmission = 0,
		Size = seq({{0, 0.3}, {1, 1.6}}), Transparency = seq({{0, 0.65}, {1, 1}}),
	})
	ring(at(maul, "Ground", Vector3.new(0, 0.08, 0)), "HeavyShockRing", gold, 5.5, 0.28)
end

local resourcesVFX = Instance.new("Folder")
resourcesVFX.Name = "CombatVFX"
resourcesVFX:SetAttribute("Generator", "BootlegVFXLab")
resourcesVFX:SetAttribute("Version", 2)
local groups = {}
for _, name in {"Statuses", "Attacks", "Skills", "Impacts"} do
 local folder = Instance.new("Folder"); folder.Name = name; folder.Parent = resourcesVFX; groups[name] = folder
end
local function template(source, group, name, duration)
 local model = lab:FindFirstChild(source):Clone()
 model.Name = name
 model:PivotTo(CFrame.identity)
 model:SetAttribute("Duration", duration or 0.8)
 model.Parent = groups[group]
 return model, model.PrimaryPart
end
local function solid(holder, class, name, size, cf, color, material, transparency)
 local part = Instance.new(class)
 part.Name = name; part.Size = size; part.CFrame = holder.CFrame * cf
 part.Color = color; part.Material = material or Enum.Material.Slate
 part.Transparency = transparency or 0
 part.Anchored = true; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false; part.CastShadow = false
 part.Parent = holder.Parent
 return part
end
local function rocks(holder, radius, count)
 for i = 1, count do
  local angle = i * math.pi * 2 / count
  solid(holder, "Part", "BrokenEarth" .. i, Vector3.new(1.2, 0.8 + (i % 3) * 0.3, 1.5),
   CFrame.new(math.cos(angle) * radius, 0.3, math.sin(angle) * radius) * CFrame.Angles(0.2, angle, 0.25), dirt)
 end
end
local function cleanTemplate(source, group, name, duration)
 local model, holder = template(source, group, name, duration)
 for _, child in holder:GetChildren() do child:Destroy() end
 return model, holder
end
local windColor = Color3.fromRGB(211, 242, 249)
local function slash(holder, radius, color)
 -- A tapered crescent rather than individual glowing wedges.
 local previous
 for i = 0, 16 do
  local t = i / 16
  local angle = math.rad(-75 + t * 150)
  local point = at(holder, "SlashPoint" .. i, Vector3.new(math.sin(angle) * radius, (t - 0.5) * 0.7, -math.cos(angle) * radius))
  if previous then
   local ribbon = beam(holder, "Crescent" .. i, previous, point, color, math.sin(t * math.pi) * 0.55 + 0.015, 0, 0.26)
   ribbon.Width0 = math.sin((i - 1) / 16 * math.pi) * 0.55 + 0.015
   ribbon.Width1 = math.sin(t * math.pi) * 0.55 + 0.015
  end
  previous = point
 end
end
local function funnel(holder, bottom, top, height, duration)
 -- Two open helices: narrow at the floor, broad at the shoulders/top.
 for strand = 1, 2 do
  local previous
  for i = 0, 36 do
   local t = i / 36
   local radius = bottom + (top - bottom) * t
   local angle = t * math.pi * 4 + strand * math.pi
   local point = at(holder, "WindPoint" .. strand .. "_" .. i, Vector3.new(math.cos(angle) * radius, -2.5 + t * height, math.sin(angle) * radius))
   if previous then
    local ribbon = beam(holder, "WindRibbon" .. strand .. "_" .. i, previous, point, windColor, 0.08 + t * 0.25, 0, duration)
    ribbon.Transparency = NumberSequence.new(0.3)
   end
   previous = point
  end
 end
end
local function buildResources()
 build()
 template("01_Poison", "Statuses", "Poison", 10)
 template("02_VenomMark", "Statuses", "Venom", 6)
 local fury, fh = cleanTemplate("06_FuryCharge", "Statuses", "Fury", 3600)
 for _, side in {-1, 1} do
  local a = at(fh, "ChargeLow" .. side, Vector3.new(side * 1.25, 0.5, 0))
  local b = at(fh, "ChargeHigh" .. side, Vector3.new(side * 1.1, 2.4, 0))
  local ribbon = beam(fh, "Charge" .. side, a, b, ivory, 0.1, 0.12, 3600)
  ribbon.Width1 = 0
 end
 local lure = template("02_VenomMark", "Statuses", "Lure Jab", 5)
 for _, v in lure:GetDescendants() do
  if v:IsA("Beam") or v:IsA("ParticleEmitter") then v.Color = ColorSequence.new(Color3.fromRGB(188, 112, 255)) end
 end
 template("05_Regrowth", "Impacts", "Regrowth", 1.3)
 template("07_DireMaul", "Impacts", "Maul", 0.7)
 template("03_SpikeWarning", "Attacks", "SpikeWarning", 2)
 local spikes, sh = template("04_SpikeEruption", "Attacks", "Spikes", 1.3)
 spikes:SetAttribute("RiseDistance", 5)
 for i = 1, 7 do
  local angle = i * math.pi * 2 / 6
  local radius = i == 7 and 0 or 1.7
  local height = i == 7 and 6 or 3 + (i % 3) * 0.6
  local cf = CFrame.new(math.cos(angle) * radius, height / 2, math.sin(angle) * radius) * CFrame.Angles(0, angle, 0)
  solid(sh, "WedgePart", "Thorn" .. i, Vector3.new(0.9, height, 1.1), cf, darkGreen)
  solid(sh, "WedgePart", "ThornEdge" .. i, Vector3.new(0.08, height * 0.93, 1.12), cf, green, Enum.Material.Neon, 0.15)
 end
 rocks(sh, 2.5, 9)
 local melee, mh = cleanTemplate("07_DireMaul", "Attacks", "Melee", 0.3)
 slash(mh, 3.3, windColor)
 melee:SetAttribute("SpinSpeed", 4)
 local swipe = melee:Clone(); swipe.Name = "DoubleSwipe"; swipe.Parent = groups.Attacks; swipe:ScaleTo(2)
 local basic = melee:Clone(); basic.Name = "Basic"; basic.Parent = groups.Skills
 for i = 1, 3 do
  local variant = basic:Clone(); variant.Name = "Basic" .. i
  for _, attachment in variant:GetDescendants() do
   if attachment:IsA("Attachment") then attachment.CFrame = CFrame.Angles(0, 0, math.rad((i - 2) * 30)) * attachment.CFrame end
  end
  variant:SetAttribute("SpinSpeed", i % 2 == 0 and -6 or 6)
  variant.Parent = groups.Skills
 end
 for i, name in {"Bushling", "Wolf", "Boar", "Dire Bear"} do
  local variant = melee:Clone(); variant.Name = name .. "Melee"
  local palette = {green, windColor, Color3.fromRGB(216, 190, 155), ivory}
  for _, effect in variant:GetDescendants() do
   if effect:IsA("Beam") then effect.Color = ColorSequence.new(palette[i]); effect.Width0 *= 0.65 + i * 0.22; effect.Width1 *= 0.65 + i * 0.22 end
   if effect:IsA("Attachment") then effect.CFrame = CFrame.Angles(0, 0, math.rad(i * 15 - 30)) * effect.CFrame end
  end
  variant:ScaleTo(0.7 + i * 0.25); variant.Parent = groups.Attacks
 end
 local slam, gh = template("07_DireMaul", "Attacks", "GroundSlam", 1)
 rocks(gh, 12, 22)
 beamRing(gh, "SlamWave", 16, 0.15, gold, 0.18)
 slam:SetAttribute("ExpandFrom", 0.15)
 local roar, rh = template("07_DireMaul", "Attacks", "Roar", 1.1)
 for i = 1, 3 do beamRing(rh, "SoundWave" .. i, 8 * i, i * 0.6, ivory, 0.12) end
 roar:SetAttribute("ExpandFrom", 0.1)
 local spin, th = cleanTemplate("06_FuryCharge", "Attacks", "TailSpin", 2)
 funnel(th, 2, 8, 6, 2)
 spin:SetAttribute("SpinSpeed", math.pi * 3)
 local rush, bh = template("04_SpikeEruption", "Attacks", "Rush", 0.95)
 for i = -1, 1, 2 do
  local a = at(bh, "SpeedStart" .. i, Vector3.new(i * 3, 0, -2))
  local b = at(bh, "SpeedEnd" .. i, Vector3.new(i * 3, 0, 6))
  beam(bh, "RushRibbon" .. i, a, b, ivory, 0.18, 0, 0.9)
 end
 for _, v in rush:GetDescendants() do if v:IsA("ParticleEmitter") then v.Rate = 12 end end
 local cyclone, ch = cleanTemplate("06_FuryCharge", "Skills", "Cyclone", 1.2)
 funnel(ch, 0.9, 4.5, 6, 1.2)
 cyclone:SetAttribute("SpinSpeed", 10)
 local jab, jh = template("07_DireMaul", "Skills", "Lure Jab", 0.4)
 slash(jh, 3, Color3.fromRGB(188, 112, 255)); jab:SetAttribute("SpinSpeed", -7)
 local ground, gr = template("04_SpikeEruption", "Skills", "Ground Break", 1.2)
 rocks(gr, 5, 16)
 for i = 1, 8 do
  local angle = i * math.pi / 4
  solid(gr, "Part", "Fissure" .. i, Vector3.new(0.1, 0.05, 4),
   CFrame.new(math.sin(angle) * 2.6, 0.08, math.cos(angle) * 2.6) * CFrame.Angles(0, angle, 0), gold, Enum.Material.Neon)
 end
 ground:SetAttribute("RiseDistance", 1)
 local blessing, bl = template("05_Regrowth", "Skills", "Blessing", 1.2)
 beamRing(bl, "BlessingHalo", 4, 0.1, mint, 0.18)
 local shield, hh = template("05_Regrowth", "Statuses", "Safeguard", 5)
 local shell = solid(hh, "Part", "ShieldShell", Vector3.new(7, 7, 7), CFrame.new(0, 1.4, 0), mint, Enum.Material.ForceField, 0.65)
 shell.Shape = Enum.PartType.Ball
 beamRing(hh, "ShieldSeal", 3.5, 1.4, mint, 0.12)
end
local ok, err = pcall(buildResources)
if not ok then lab:Destroy(); resourcesVFX:Destroy(); error(err) end
-- Show exact copies of the saved templates in the editable preview gallery.
lab:ClearAllChildren()
local displayIndex = 0
for _, groupName in {"Statuses", "Attacks", "Skills", "Impacts"} do
 for _, model in groups[groupName]:GetChildren() do
  local preview = model:Clone(); preview.Name = groupName .. "_" .. model.Name
  preview:PivotTo(CFrame.new(origin + Vector3.new((displayIndex % 4) * 55, 0, math.floor(displayIndex / 4) * 55)))
  preview.Parent = lab; displayIndex += 1
 end
end
local RS = game:GetService("ReplicatedStorage")
local resources = RS:FindFirstChild("Resources")
local old = resources and resources:FindFirstChild("CombatVFX")
local oldLab = workspace:FindFirstChild(LAB_NAME)
for _, existing in {old, oldLab} do
 if existing and existing:GetAttribute("Generator") ~= "BootlegVFXLab" then
  lab:Destroy(); resourcesVFX:Destroy(); error("An unrelated object already uses the generated asset name: " .. existing:GetFullName())
 end
end
-- Command Bar is not a plugin recording context. Undo is best-effort;
-- explicit backups below preserve previous assets independently of history.
local backups = ServerStorage:FindFirstChild("RPGVFXBackups")
if not backups then backups = Instance.new("Folder"); backups.Name = "RPGVFXBackups"; backups.Parent = ServerStorage end
local batch = Instance.new("Folder"); batch.Name = os.date("%Y-%m-%d_%H-%M-%S"); batch.Parent = backups
if old then old.Parent = batch end
if oldLab then oldLab.Parent = batch end
if not resources then resources = Instance.new("Folder"); resources.Name = "Resources"; resources.Parent = RS end
resourcesVFX.Parent = resources
lab.Parent = workspace
local historyOK = pcall(function() History:SetWaypoint("Generate combat models and VFX") end)
if not historyOK then
 warn("VFX generated. Studio could not create an Undo waypoint; previous assets are in ServerStorage.RPGVFXBackups.")
end
Selection:Set({resourcesVFX})
print("CombatVFX saved under ReplicatedStorage.Resources: " .. displayIndex .. " templates. Save the place before Play.")
print("Workspace.RPGVFXLab contains preview copies. Runtime uses Resources, so edit the saved templates there.")
