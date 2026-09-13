assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating assets.")
local RS = game:GetService("ReplicatedStorage")
local resources = RS:WaitForChild("Resources")
local vfx = resources:FindFirstChild("CombatVFX") or Instance.new("Folder")
vfx.Name = "CombatVFX"; vfx.Parent = resources
local attacks = vfx:FindFirstChild("Attacks") or Instance.new("Folder")
attacks.Name = "Attacks"; attacks.Parent = vfx

local function replace(name, color, texture, lifetime, rate)
	local old = attacks:FindFirstChild(name)
	if old then old:Destroy() end
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("Lifetime", lifetime)
	local anchor = Instance.new("Part")
	anchor.Name = "Anchor"; anchor.Size = Vector3.one; anchor.Transparency = 1
	anchor.Anchored = true; anchor.CanCollide = false; anchor.CanTouch = false; anchor.CanQuery = false
	anchor.Parent = model; model.PrimaryPart = anchor
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = texture
	emitter.Color = ColorSequence.new(color, Color3.fromRGB(75, 48, 35))
	emitter.LightEmission = 0.7; emitter.Rate = rate; emitter.Lifetime = NumberRange.new(0.35, lifetime)
	emitter.Speed = NumberRange.new(3, 10); emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Acceleration = Vector3.new(0, -22, 0); emitter.Size = NumberSequence.new(1.2, 0)
	emitter.Transparency = NumberSequence.new(0.05, 1); emitter.Parent = anchor
	model.Parent = attacks
end

replace("DireBearJumpImpact", Color3.fromRGB(255, 210, 120), "rbxasset://textures/particles/smoke_main.dds", 1, 75)
replace("CavefallImpact", Color3.fromRGB(126, 104, 84), "rbxasset://textures/particles/smoke_main.dds", 0.8, 95)
for _, name in { "DireBearJumpWarning", "CavefallWarning" } do
	local warning = attacks:FindFirstChild(name)
	if warning then warning:Destroy() end
end
print("Dire Bear skill VFX saved to ReplicatedStorage.Resources.CombatVFX.Attacks.")
