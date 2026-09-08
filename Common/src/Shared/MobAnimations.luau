local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnimationHandler = require(ReplicatedStorage.Shared.AnimationHandler)

local AnimationsFolder = ReplicatedStorage.Resources.Animations

local LoopedCategories = {
	Idle = true,
	Walk = true,
}

local MobAnimations = {}

local function getRandomAnimation(categoryName: string): Animation?
	local MobsFolder = AnimationsFolder:FindFirstChild("Mobs")
	if not MobsFolder then
		warn("[MobAnimations] Resources.Animations.Mobs não existe")
		return nil
	end

	local Options = {}
	for _, child in MobsFolder:GetChildren() do
		if child:IsA("Animation") and child.Name == categoryName then
			table.insert(Options, child)
		end
	end

	if #Options == 0 then
		warn("[MobAnimations] Nenhuma Animation chamada '" .. categoryName .. "' dentro de Resources.Animations.Mobs")
		return nil
	end

	return Options[math.random(1, #Options)]
end

function MobAnimations:Play(mobModel: Model, categoryName: string, fadeTime: number?, speed: number?): AnimationTrack?
	local AnimInstance = getRandomAnimation(categoryName)
	if not AnimInstance then
		return nil
	end

	local Handler = AnimationHandler.GetOrCreate(mobModel)
	local Track = Handler:PlayInstance(AnimInstance, fadeTime, speed)

	if Track then
		Track.Looped = LoopedCategories[categoryName] == true
	end

	return Track
end

function MobAnimations:PlayHit(mobModel: Model, fadeTime: number?, speed: number?): AnimationTrack?
	local HitCategory = (math.random(1, 2) == 1) and "Hit1" or "Hit2"
	return self:Play(mobModel, HitCategory, fadeTime, speed)
end

return MobAnimations
