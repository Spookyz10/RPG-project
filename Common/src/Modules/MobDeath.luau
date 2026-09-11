-- Rig-independent death pose: intact body recoils, tips and dissolves into sparks.
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Death = {}
function Death:Play(mob: Model)
 local root = mob.PrimaryPart or mob:FindFirstChild("HumanoidRootPart")
 if not root or not root:IsA("BasePart") then return end
 local humanoid = mob:FindFirstChildOfClass("Humanoid")
 local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
 if animator then for _, track in animator:GetPlayingAnimationTracks() do track:Stop(0) end end
 local pivot = mob:GetPivot()
 local height = mob:GetExtentsSize().Y
 local parts = {}
 for _, object in mob:GetDescendants() do
  if object:IsA("BasePart") then
   object.Anchored = true
   object.CanCollide = false; object.CanTouch = false; object.CanQuery = false
   object.AssemblyLinearVelocity = Vector3.zero
   object.AssemblyAngularVelocity = Vector3.zero
   table.insert(parts, {Part = object, Local = pivot:ToObjectSpace(object.CFrame), Size = object.Size})
  elseif object:IsA("ParticleEmitter") or object:IsA("Beam") or object:IsA("Trail") then
   object.Enabled = false
  elseif object:IsA("BillboardGui") then object.Enabled = false end
 end
 local glow = Instance.new("Highlight")
 glow.Name = "DeathFlash"; glow.FillColor = Color3.fromRGB(255, 220, 150)
 glow.FillTransparency = 0.25; glow.OutlineTransparency = 1
 glow.DepthMode = Enum.HighlightDepthMode.Occluded; glow.Parent = mob
 TweenService:Create(glow, TweenInfo.new(0.4), {FillTransparency = 1}):Play()
 local recoil = pivot * CFrame.new(0, math.min(height * 0.07, 0.8), 0.35) * CFrame.Angles(math.rad(-12), 0, math.rad(8))
 for _, entry in parts do
  TweenService:Create(entry.Part, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = recoil * entry.Local}):Play()
 end
 task.delay(0.2, function()
  if not mob.Parent then return end
  local finish = pivot * CFrame.new(0, -height * 0.18, 0) * CFrame.Angles(0, math.rad(15), math.rad(65))
  for _, entry in parts do
   if entry.Part.Parent then
    local localCF = CFrame.new(entry.Local.Position * 0.3) * entry.Local.Rotation
    TweenService:Create(entry.Part, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
     CFrame = finish * localCF, Size = entry.Size * 0.3, Transparency = 1,
    }):Play()
   end
  end
  for _, object in mob:GetDescendants() do
   if object:IsA("Decal") or object:IsA("Texture") then
    TweenService:Create(object, TweenInfo.new(0.65), {Transparency = 1}):Play()
   end
  end
  local anchor = Instance.new("Part")
  anchor.Name = "MobDeathSparks"; anchor.Size = Vector3.one; anchor.Transparency = 1
  anchor.Anchored = true; anchor.CanCollide = false; anchor.CanTouch = false; anchor.CanQuery = false
  anchor.CFrame = pivot; anchor.Parent = workspace
  local sparks = Instance.new("ParticleEmitter")
  sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
  sparks.Color = ColorSequence.new(Color3.fromRGB(255, 222, 149), Color3.fromRGB(255, 150, 65))
  sparks.Enabled = false; sparks.Rate = 0; sparks.LightEmission = 0.8
  sparks.Lifetime = NumberRange.new(0.5, 0.85); sparks.Speed = NumberRange.new(2, 5)
  sparks.SpreadAngle = Vector2.new(180, 180); sparks.Acceleration = Vector3.new(0, 3, 0)
  sparks.Size = NumberSequence.new(0.25, 0)
  sparks.Transparency = NumberSequence.new(0, 1)
  sparks.Parent = anchor
  -- Enabled replicates reliably to every client; the short burst is then stopped.
  sparks.Rate = 100; sparks.Enabled = true
  task.delay(0.15, function() if sparks.Parent then sparks.Enabled = false end end)
  Debris:AddItem(anchor, 1.2)
 end)
end
return Death
