local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VFX = {}
-- Warm the combat textures independently of UI loading. Short first-use bursts
-- can expire before an uncached flipbook finishes downloading.
if RunService:IsClient() then
 task.spawn(function()
  local resources = RS:WaitForChild("Resources", 10)
  local library = resources and resources:WaitForChild("CombatVFX", 10)
  if not library then return end
  local emitters = {}
  for _, object in library:GetDescendants() do
   if object:IsA("ParticleEmitter") then table.insert(emitters, object) end
  end
  local ok, err = pcall(function() game:GetService("ContentProvider"):PreloadAsync(emitters) end)
  if not ok then warn("[CombatVFX] Texture preload: " .. tostring(err)) end
 end)
end
local basicVariants = setmetatable({}, {__mode = "k"})
local active = {}
local statuses = {}
local warned = {}
local MAX_BURSTS = 80
local STATUS_NAMES = {Poison = "Poison", Venom = "Venom", LureJab = "Lure Jab", Safeguard = "Safeguard", Renewal = "Renewal"}
VFX.StatusNames = STATUS_NAMES

local function rootOf(entity)
 return entity and (entity:FindFirstChild("HumanoidRootPart") or entity.PrimaryPart)
end
local function living(entity)
 local hum = entity and entity:FindFirstChildOfClass("Humanoid")
 return entity and entity.Parent and hum and hum.Health > 0
end
local function closeEnough(cf)
 local camera = workspace.CurrentCamera
 return not camera or (camera.CFrame.Position - cf.Position).Magnitude <= 240
end
local function dispose(entry)
 if entry.Destroyed then return end
 entry.Destroyed = true
 entry.Model:Destroy()
 if entry.Status and statuses[entry.Entity] and statuses[entry.Entity][entry.Status] == entry then
  statuses[entry.Entity][entry.Status] = nil
  if next(statuses[entry.Entity]) == nil then statuses[entry.Entity] = nil end
 end
end
local function findTemplate(group, name)
 local resources = RS:FindFirstChild("Resources")
 local folder = resources and resources:FindFirstChild("CombatVFX")
 local category = folder and folder:FindFirstChild(group)
 local result = category and category:FindFirstChild(name)
 if result and result:IsA("Model") then return result end
 local key = group .. "/" .. name
 if not warned[key] then warned[key] = true; warn("Missing CombatVFX/" .. key .. ": run 00_VFXLab in Edit Mode and save the place.") end
end
function VFX:Play(group, name, cf, options)
 if not RunService:IsClient() then return end
 options = options or {}
 if not closeEnough(cf) then return end
 local template = findTemplate(group, name)
 if not template then return end
 local bursts = 0
 for _, e in active do if not e.Destroyed and not e.Status then bursts += 1 end end
 if not options.Status and bursts >= MAX_BURSTS then return end
 local model = template:Clone()
 local preserveParticles = options.PreserveParticles == true and (template:GetAttribute("Version") or 0) < 2
 local duration = options.Duration or template:GetAttribute("Duration") or 1
 local entry = {Model = model, Origin = cf, Entity = options.Entity, Follow = options.Follow,
  Status = options.Status, Started = os.clock(), Expires = os.clock() + duration,
  Duration = duration, Offset = options.Offset or CFrame.identity, Parts = {}, Beams = {}, Emitters = {}, Layers = {}, Lights = {}, Trails = {},
  Spin = preserveParticles and 0 or template:GetAttribute("SpinSpeed") or 0,
  Rise = preserveParticles and 0 or template:GetAttribute("RiseDistance") or 0,
  Expand = not preserveParticles and template:GetAttribute("ExpandFrom") or nil,
  Scale = model:GetScale(), Destroyed = false,
  Attack = options.Attack}
 for _, v in model:GetDescendants() do
  if v:IsA("BasePart") then
   v.Anchored = true; v.CanCollide = false; v.CanTouch = false; v.CanQuery = false; v.CastShadow = false
   table.insert(entry.Parts, {Part = v, Transparency = v.Transparency,
    Local = model:GetPivot():ToObjectSpace(v.CFrame), Size = v.Size,
    Motion = v:GetAttribute("VFXMotion"), Delay = v:GetAttribute("VFXDelay") or 0,
    Life = v:GetAttribute("VFXLife") or duration, Velocity = v:GetAttribute("VFXVelocity") or Vector3.zero,
    Angular = v:GetAttribute("VFXAngular") or Vector3.zero,
    Gravity = v:GetAttribute("VFXGravity") or 0, Grow = v:GetAttribute("VFXGrowFrom") or 1})
  elseif v:IsA("Beam") then
   v.Enabled = true
   table.insert(entry.Beams, {Beam = v, Until = entry.Started + (entry.Status and duration or v:GetAttribute("PreviewDuration") or duration),
    Delay = v:GetAttribute("EmitDelay") or 0, Width0 = v.Width0, Width1 = v.Width1})
  elseif v:IsA("Trail") then
   v.Enabled = true
   table.insert(entry.Trails, {Trail=v, Duration=v:GetAttribute("PreviewDuration") or duration})
  elseif v:IsA("PointLight") then
   v.Enabled = false
   table.insert(entry.Lights, {Light=v, Brightness=v.Brightness, Duration=v:GetAttribute("VFXLife") or 0.16})
  elseif v:IsA("ParticleEmitter") then
   if not preserveParticles then
    v.Enabled = false
    if options.Follow and v:GetAttribute("WorldSpace") ~= true then v.LockedToPart = true end
    table.insert(entry.Emitters, v)
   end
  end
 end
 if entry.Expand then model:ScaleTo(entry.Scale * entry.Expand) end
 model:PivotTo(cf * CFrame.new(0, -entry.Rise, 0))
 model.Parent = workspace
	for _, emitter in entry.Emitters do
		local delay = emitter:GetAttribute("EmitDelay") or 0
		local emitDuration = emitter:GetAttribute("EmitDuration") or 0
		local layer = { Emitter = emitter, At = entry.Started + delay, Done = false,
			Until = entry.Started + delay + emitDuration,
			Continuous = entry.Status ~= nil or (name == "Rush" and (template:GetAttribute("Version") or 0) < 2) }
		table.insert(entry.Layers, layer)
		if delay <= 0 then
			layer.Done = true
			emitter.Enabled = (layer.Continuous or emitDuration > 0) and emitter.Rate > 0
			emitter:Emit(emitter:GetAttribute("EmitCount") or math.max(1, math.floor(emitter.Rate * 0.25)))
		end
	end
 table.insert(active, entry)
 return entry
end
function VFX:StopStatus(entity, id)
 local entry = statuses[entity] and statuses[entity][id]
 if entry then dispose(entry) end
end
function VFX:Status(entity, id, duration)
 local root = rootOf(entity)
 if not root or not living(entity) then self:StopStatus(entity, id); return end
 local entry = statuses[entity] and statuses[entity][id]
 if entry then entry.Expires = os.clock() + (duration or 3600); return end
 entry = self:Play("Statuses", id, root.CFrame * CFrame.new(0, -1.4, 0), {
  Entity = entity, Follow = true, Offset = CFrame.new(0, -1.4, 0), Status = id, Duration = duration or 3600,
 })
 if entry then
  statuses[entity] = statuses[entity] or {}; statuses[entity][id] = entry
 end
end
function VFX:Ground(cf, entity)
 local params = RaycastParams.new()
 params.FilterType = Enum.RaycastFilterType.Exclude
 params.RespectCanCollide = true
 local excluded = {}
 if entity then table.insert(excluded, entity) end
 local mobs = workspace:FindFirstChild("Mobs"); if mobs then table.insert(excluded, mobs) end
 for _, p in game:GetService("Players"):GetPlayers() do if p.Character then table.insert(excluded, p.Character) end end
 params.FilterDescendantsInstances = excluded
 local result = workspace:Raycast(cf.Position, Vector3.new(0, -256, 0), params)
 if not result or result.Normal.Y < 0.25 then return nil end
 local up = result.Normal
 local forward = cf.LookVector - up * cf.LookVector:Dot(up)
 if forward.Magnitude < 0.01 then forward = up:Cross(Vector3.xAxis) end
 return CFrame.lookAt(result.Position + up * 0.08, result.Position + up * 0.08 + forward.Unit, up)
end
function VFX:Skill(name, entity, comboIndex)
 local root = rootOf(entity)
 if not root or not living(entity) then return end
 local cf, offset = root.CFrame, CFrame.identity
 local follow = name == "Cyclone" or name == "Blessing" or name == "Basic" or name == "Lure Jab" or name == "Renewal"
 if name == "Ground Break" then
  cf = self:Ground(cf, entity)
  if not cf then return end
 elseif name == "Basic" then offset = CFrame.new(0, 0, -1); cf *= offset
 elseif name == "Arc Breaker" then cf *= CFrame.new(0, 0, -7) end
 local effectName = name
 if name == "Basic" then
  local index = comboIndex or (basicVariants[entity] or 0) % 3 + 1
  basicVariants[entity] = index
  effectName = "Basic" .. index
 end
 return self:Play("Skills", effectName, cf, {
  Entity = entity,
  Follow = follow,
  Offset = offset,
  PreserveParticles = name == "Cyclone",
 })
end
if RunService:IsClient() then
 RunService.Heartbeat:Connect(function()
  local now = os.clock()
  for i = #active, 1, -1 do
   local entry = active[i]
   if entry.Destroyed or not entry.Model.Parent or now >= entry.Expires
    or (entry.Entity and not living(entry.Entity))
    or (entry.AttackSeen and entry.Entity:GetAttribute("Attack") ~= entry.Attack) then
    dispose(entry); table.remove(active, i); continue
   end
   if entry.Attack and entry.Entity:GetAttribute("Attack") == entry.Attack then entry.AttackSeen = true end
   local base = entry.Origin
   if entry.Follow then
    local root = rootOf(entry.Entity)
    if not root then dispose(entry); table.remove(active, i); continue end
    base = root.CFrame * entry.Offset
   end
   if not closeEnough(base) then dispose(entry); table.remove(active, i); continue end
   local elapsed = now - entry.Started
   for _, layer in entry.Layers do
    local emitter = layer.Emitter
    if not layer.Done and now >= layer.At then
     layer.Done = true
     emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
     emitter.Enabled = (layer.Continuous or now < layer.Until) and emitter.Rate > 0
    end
    if layer.Done and not layer.Continuous and now >= layer.Until then emitter.Enabled = false end
   end
   local rise = entry.Rise * (1 - math.min(1, elapsed / 0.16)) ^ 2
   entry.Model:PivotTo(base * CFrame.new(0, -rise, 0) * CFrame.Angles(0, elapsed * entry.Spin, 0))
   if entry.Expand then
    entry.Model:ScaleTo(entry.Scale * (entry.Expand + (1 - entry.Expand) * math.min(1, elapsed / (entry.Duration * 0.7))))
   end
   local fade = math.clamp(1 - (entry.Expires - now) / 0.25, 0, 1)
   local pivot = entry.Model:GetPivot()
   for _, p in entry.Parts do
    if p.Motion then
     local time = elapsed - p.Delay
     local progress = math.clamp(time / p.Life, 0, 1)
     local ease = 1 - (1 - progress)^3
     local scale = p.Grow + (1 - p.Grow) * ease
     local localCF = p.Local
     if p.Motion == "Radial" then
      local position = localCF.Position
      localCF = CFrame.new(position.X * scale, position.Y, position.Z * scale) * localCF.Rotation
      p.Part.Size = Vector3.new(p.Size.X * scale, p.Size.Y, p.Size.Z * scale)
     elseif p.Motion == "Shard" then
      localCF = CFrame.new(localCF.Position + p.Velocity * time + Vector3.new(0, -p.Gravity * time * time * 0.5, 0))
       * localCF.Rotation * CFrame.Angles(p.Angular.X * time, p.Angular.Y * time, p.Angular.Z * time)
      p.Part.Size = p.Size * math.max(0.05, 1 - math.max(0, progress - 0.55) / 0.45)
     elseif p.Motion == "Orbit" then
      localCF = CFrame.Angles(p.Angular.X * time, p.Angular.Y * time, p.Angular.Z * time) * localCF
      p.Part.Size = p.Size * scale
     elseif p.Motion == "Rise" then
      localCF += p.Velocity * (1 - ease)
      p.Part.Size = p.Size * scale
     else
      p.Part.Size = p.Size * scale
     end
     p.Part.CFrame = pivot * localCF
     local dissolve = math.clamp((progress - 0.45) / 0.55, 0, 1)
     p.Part.Transparency = time < 0 and 1 or p.Transparency + (1 - p.Transparency) * math.max(fade, dissolve)
    else
     p.Part.Transparency = p.Transparency + (1 - p.Transparency) * fade
    end
   end
   for _, b in entry.Beams do
    b.Beam.Enabled = elapsed >= b.Delay and (entry.Status ~= nil or now < b.Until)
    local beamFade = entry.Status and 1 or math.clamp((b.Until - now) / 0.14, 0, 1)
    b.Beam.Width0 = b.Width0 * beamFade; b.Beam.Width1 = b.Width1 * beamFade
   end
   for _, trail in entry.Trails do trail.Trail.Enabled = elapsed < trail.Duration end
   for _, light in entry.Lights do
    light.Light.Enabled = elapsed < light.Duration
    light.Light.Brightness = light.Brightness * math.max(0, 1 - elapsed / light.Duration)^2
   end
  end
 end)
end
return VFX
