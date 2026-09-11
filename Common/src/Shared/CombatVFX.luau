-- Client presentation only. Templates are saved by tools/vfx-generators/00_VFXLab.luau.
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VFX = {}
local active = {}
local statuses = {}
local warned = {}
local MAX_BURSTS = 80
local STATUS_NAMES = {Poison = "Poison", Venom = "Venom", Fury = "Fury", LureJab = "Lure Jab", Safeguard = "Safeguard"}
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
 local duration = options.Duration or template:GetAttribute("Duration") or 1
 local entry = {Model = model, Origin = cf, Entity = options.Entity, Follow = options.Follow,
  Status = options.Status, Started = os.clock(), Expires = os.clock() + duration,
  Duration = duration, Offset = options.Offset or CFrame.identity, Parts = {}, Beams = {}, Emitters = {},
  Spin = template:GetAttribute("SpinSpeed") or 0, Rise = template:GetAttribute("RiseDistance") or 0,
  Expand = template:GetAttribute("ExpandFrom"), Scale = model:GetScale(), Destroyed = false,
  Attack = options.Attack}
 for _, v in model:GetDescendants() do
  if v:IsA("BasePart") then
   v.Anchored = true; v.CanCollide = false; v.CanTouch = false; v.CanQuery = false
   table.insert(entry.Parts, {Part = v, Transparency = v.Transparency})
  elseif v:IsA("Beam") then
   v.Enabled = true
   table.insert(entry.Beams, {Beam = v, Until = os.clock() + (entry.Status and duration or v:GetAttribute("PreviewDuration") or duration)})
  elseif v:IsA("ParticleEmitter") then
   v.Enabled = false
   if options.Follow then v.LockedToPart = true end
   table.insert(entry.Emitters, v)
  end
 end
 if entry.Expand then model:ScaleTo(entry.Scale * entry.Expand) end
 model:PivotTo(cf * CFrame.new(0, -entry.Rise, 0))
 model.Parent = workspace
 for _, emitter in entry.Emitters do
  emitter.Enabled = (entry.Status ~= nil or name == "Rush") and emitter.Rate > 0
  emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
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
 local excluded = {}
 if entity then table.insert(excluded, entity) end
 local mobs = workspace:FindFirstChild("Mobs"); if mobs then table.insert(excluded, mobs) end
 for _, p in game:GetService("Players"):GetPlayers() do if p.Character then table.insert(excluded, p.Character) end end
 params.FilterDescendantsInstances = excluded
 local result = workspace:Raycast(cf.Position + Vector3.new(0, 3, 0), Vector3.new(0, -60, 0), params)
 return CFrame.new(result and result.Position + Vector3.new(0, 0.08, 0) or cf.Position) * cf.Rotation
end
function VFX:Skill(name, entity)
 local root = rootOf(entity)
 if not root or not living(entity) then return end
 local cf, offset = root.CFrame, CFrame.identity
 local follow = name == "Cyclone" or name == "Basic" or name == "Lure Jab"
 if name == "Ground Break" then cf = self:Ground(cf * CFrame.new(0, 0, -3), entity)
 elseif name == "Blessing" then cf = self:Ground(cf, entity)
 elseif name == "Basic" then offset = CFrame.new(0, 0, -1); cf *= offset end
 self:Play("Skills", name, cf, {Entity = entity, Follow = follow, Offset = offset})
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
   local rise = entry.Rise * (1 - math.min(1, elapsed / 0.16)) ^ 2
   entry.Model:PivotTo(base * CFrame.new(0, -rise, 0) * CFrame.Angles(0, elapsed * entry.Spin, 0))
   if entry.Expand then
    entry.Model:ScaleTo(entry.Scale * (entry.Expand + (1 - entry.Expand) * math.min(1, elapsed / (entry.Duration * 0.7))))
   end
   local fade = math.clamp(1 - (entry.Expires - now) / 0.25, 0, 1)
   for _, p in entry.Parts do p.Part.Transparency = p.Transparency + (1 - p.Transparency) * fade end
   for _, b in entry.Beams do b.Beam.Enabled = entry.Status ~= nil or now < b.Until end
  end
 end)
end
return VFX
