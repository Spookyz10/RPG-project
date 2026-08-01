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

function AnimationHandler:_WaitReady(): boolean
	local Character = self.Character

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		or Character:FindFirstChildOfClass("AnimationController")
	if not Humanoid then
		Humanoid = Character:WaitForChild("Humanoid", 10) :: Humanoid?
	end
	if not Humanoid or self._Destroyed then
		return false
	end

	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not RootPart then
		RootPart = Character:WaitForChild("HumanoidRootPart", 10)
	end
	if not RootPart or self._Destroyed then
		return false
	end

	local Animator = Humanoid:FindFirstChildOfClass("Animator")
	if not Animator then
		Animator = Humanoid:WaitForChild("Animator", 5) :: Animator?
	end
	if not Animator then
		Animator = Instance.new("Animator", Humanoid)
	end
	if self._Destroyed then
		return false
	end

	self.Animator = Animator

	if Humanoid:IsA("Humanoid") and Humanoid:GetState() == Enum.HumanoidStateType.Physics then
		Humanoid.StateChanged:Wait()
	end

	return not self._Destroyed
end

function AnimationHandler:WaitUntilReady(): boolean
	if self.Ready then
		return true
	end
	if self._Destroyed then
		return false
	end
	self._ReadyEvent.Event:Wait()
	return self.Ready
end

function AnimationHandler.new(character: Model)
	local Existing = ActiveHandlers[character]
	if Existing then
		return Existing
	end

	local self = setmetatable({}, AnimationHandler)

	self.Character = character
	self.Animator = nil :: Animator?
	self.Tracks = {} :: { [string]: AnimationTrack }
	self.Ready = false
	self._Destroyed = false
	self._ReadyEvent = Instance.new("BindableEvent")

	ActiveHandlers[character] = self

	character.Destroying:Connect(function()
		self:Destroy()
	end)

	task.spawn(function()
		local ok = self:_WaitReady()
		if self._Destroyed then
			return
		end
		if ok then
			self.Ready = true
		end
		self._ReadyEvent:Fire()
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

	if not self.Animator then
		return nil
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

	if not self.Character or not self.Character.Parent or self._Destroyed then
		return nil
	end

	if not self:WaitUntilReady() then
		return nil
	end

	if not self.Character or not self.Character.Parent or self._Destroyed then
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
	self._Destroyed = true

	if not self.Ready then
		self._ReadyEvent:Fire()
	end

	for _, Track in self.Tracks do
		Track:Stop(0)
		Track:Destroy()
	end
	table.clear(self.Tracks)

	self._ReadyEvent:Destroy()
	ActiveHandlers[self.Character] = nil
end

return AnimationHandler
