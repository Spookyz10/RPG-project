local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Effect = {}
local ActiveEffects: { [Model]: { Instance } } = setmetatable({}, { __mode = "k" })

local function scaleEmitter(emitter: ParticleEmitter, scale: number)
	local keypoints = {}
	for _, keypoint in emitter.Size.Keypoints do
		table.insert(keypoints, NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * scale,
			keypoint.Envelope * scale
		))
	end
	emitter.Size = NumberSequence.new(keypoints)
end

local function scaleParticles(effect: Instance, scale: number)
	if effect:IsA("ParticleEmitter") then
		scaleEmitter(effect, scale)
	end
	for _, descendant in effect:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			scaleEmitter(descendant, scale)
		end
	end
end

function Effect.Apply(character: Model)
	if ActiveEffects[character] then
		return
	end

	local primaryPart = character.PrimaryPart
	local resources = ReplicatedStorage:FindFirstChild("Resources")
	local buffEffects = resources and resources:FindFirstChild("BuffEffects")
	local template = buffEffects and buffEffects:FindFirstChild("Lure Jab")
	if not primaryPart or not template then
		return
	end

	local scale = character:GetScale()
	local clones = {}
	for _, child in template:GetChildren() do
		local clone = child:Clone()
		scaleParticles(clone, scale)
		clone.Parent = primaryPart
		table.insert(clones, clone)
	end
	ActiveEffects[character] = clones
end

function Effect.Stop(character: Model)
	local effects = ActiveEffects[character]
	if not effects then
		return
	end
	for _, effect in effects do
		effect:Destroy()
	end
	ActiveEffects[character] = nil
end

return Effect
