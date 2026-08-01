local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AnimationsFolder = ReplicatedStorage.Assets.Animations
local PreloadStatus = RunService:IsClient()
		and require(ReplicatedFirst:WaitForChild("First"):WaitForChild("PreloadStatus"))
	or nil

local AnimationHandler = {}
AnimationHandler.__index = AnimationHandler

local ActiveHandlers: { [Model]: any } = {}

local function getAnimator(character: Model): Animator?
	local Controller = character:FindFirstChildOfClass("Humanoid")
		or character:FindFirstChildOfClass("AnimationController")

	if not Controller then
		return nil
	end

	return (Controller:FindFirstChildOfClass("Animator") :: Animator?) or Instance.new("Animator", Controller)
end

function AnimationHandler.new(character: Model)
	local Existing = ActiveHandlers[character]
	if Existing then
		return Existing
	end

	local Animator = getAnimator(character)
	if not Animator then
		warn("[AnimationHandler] Character sem Humanoid/AnimationController: " .. character:GetFullName())
		return nil
	end

	local self = setmetatable({}, AnimationHandler)

	self.Character = character
	self.Animator = Animator
	self.Tracks = {} :: { [string]: AnimationTrack }

	ActiveHandlers[character] = self

	character.Destroying:Connect(function()
		self:Destroy()
	end)

	return self
end

function AnimationHandler.Get(character: Model)
	return ActiveHandlers[character]
end

function AnimationHandler.GetOrCreate(character: Model)
	return ActiveHandlers[character] or AnimationHandler.new(character)
end

function AnimationHandler:LoadTrack(animName: string): AnimationTrack?
	local Track = self.Tracks[animName]
	if Track then
		return Track
	end

	local AnimInstance = AnimationsFolder:FindFirstChild(animName) :: Animation?
	if not AnimInstance then
		warn("[AnimationHandler] Nenhuma Animation chamada '" .. animName .. "' em Assets.Animations")
		return nil
	end

	Track = self.Animator:LoadAnimation(AnimInstance)
	self.Tracks[animName] = Track
	return Track
end

function AnimationHandler:Play(animName: string, fadeTime: number?, speed: number?): AnimationTrack?
	if PreloadStatus then
		PreloadStatus:WaitUntilReady()
	end

	if not self.Character or not self.Character.Parent then
		return nil
	end

	local Track = self:LoadTrack(animName)
	if not Track then
		return nil
	end

	if not Track.IsPlaying then
		Track:Play(fadeTime or 0.2, 1, speed or 1)
	end

	return Track
end

function AnimationHandler:Stop(animName: string, fadeTime: number?)
	local Track = self.Tracks[animName]
	if Track and Track.IsPlaying then
		Track:Stop(fadeTime or 0.2)
	end
end

function AnimationHandler:IsPlaying(animName: string): boolean
	local Track = self.Tracks[animName]
	return Track ~= nil and Track.IsPlaying
end

function AnimationHandler:StopAll(fadeTime: number?)
	for _, Track in self.Tracks do
		if Track.IsPlaying then
			Track:Stop(fadeTime or 0.2)
		end
	end
end

function AnimationHandler:Destroy()
	for _, Track in self.Tracks do
		Track:Stop(0)
		Track:Destroy()
	end
	table.clear(self.Tracks)
	ActiveHandlers[self.Character] = nil
end

return AnimationHandler
