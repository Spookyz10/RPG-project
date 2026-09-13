local StunManager = {}

local StunnedUntil: { [Instance]: number } = {}
local HardStuns: { [Instance]: {
	EndTime: number,
	Humanoid: Humanoid,
	WalkSpeed: number,
	JumpPower: number,
	JumpHeight: number,
	AutoRotate: boolean,
} } = {}

local function humanoidFor(entity: Instance): Humanoid?
	if entity:IsA("Player") then
		local character = entity.Character
		return character and character:FindFirstChildOfClass("Humanoid")
	end
	if entity:IsA("Model") then return entity:FindFirstChildOfClass("Humanoid") end
	return nil
end

local function releaseHardStun(entity: Instance, entry)
	if HardStuns[entity] ~= entry then return end
	HardStuns[entity] = nil
	local humanoid = entry.Humanoid
	if humanoid.Parent then
		humanoid.WalkSpeed = entry.WalkSpeed
		humanoid.JumpPower = entry.JumpPower
		humanoid.JumpHeight = entry.JumpHeight
		humanoid.AutoRotate = entry.AutoRotate
	end
	if entity:IsA("Player") then
		task.defer(function()
			if entity.Parent then require(script.Parent.SpeedManager):Refresh(entity) end
		end)
	end
end

function StunManager:Stun(entity: Instance, duration: number)
	local EndTime = os.clock() + duration
	StunnedUntil[entity] = EndTime

	task.delay(duration, function()
		if StunnedUntil[entity] == EndTime then
			StunnedUntil[entity] = nil
		end
	end)
end

function StunManager:HardStun(entity: Instance, duration: number)
	self:Stun(entity, duration)
	local humanoid = humanoidFor(entity)
	if not humanoid or humanoid.Health <= 0 then return end
	local endTime = os.clock() + duration
	local entry = HardStuns[entity]
	if entry then
		entry.EndTime = math.max(entry.EndTime, endTime)
		return
	end
	entry = {
		EndTime = endTime,
		Humanoid = humanoid,
		WalkSpeed = humanoid.WalkSpeed,
		JumpPower = humanoid.JumpPower,
		JumpHeight = humanoid.JumpHeight,
		AutoRotate = humanoid.AutoRotate,
	}
	HardStuns[entity] = entry
	task.spawn(function()
		while HardStuns[entity] == entry and humanoid.Parent and humanoid.Health > 0 and os.clock() < entry.EndTime do
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
			humanoid.JumpHeight = 0
			humanoid.AutoRotate = false
			humanoid:Move(Vector3.zero)
			local root = humanoid.RootPart
			if root then
				root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
				root.AssemblyAngularVelocity = Vector3.zero
			end
			task.wait()
		end
		releaseHardStun(entity, entry)
	end)
end

function StunManager:StunUntilAnimationEnds(
	entity: Instance,
	track: AnimationTrack?,
	buffer: number?,
	fallbackDuration: number?
)
	buffer = buffer or 0.1

	if not track then
		self:Stun(entity, fallbackDuration or 0.6)
		return
	end

	StunnedUntil[entity] = math.huge

	local Session = StunnedUntil[entity]
	local Connection: RBXScriptConnection
	local Cleared = false

	local function Release()
		if Cleared then
			return
		end
		Cleared = true

		if Connection then
			Connection:Disconnect()
		end

		task.delay(buffer, function()
			if StunnedUntil[entity] == Session then
				StunnedUntil[entity] = nil
			end
		end)
	end

	Connection = track.Ended:Connect(Release)

	if not track.IsPlaying then
		Release()
	end
end

function StunManager:IsStunned(entity: Instance): boolean
	local EndTime = StunnedUntil[entity]
	return EndTime ~= nil and EndTime > os.clock()
end

function StunManager:IsHardStunned(entity: Instance): boolean
	local entry = HardStuns[entity]
	return entry ~= nil and entry.EndTime > os.clock()
end

function StunManager:GetTimeLeft(entity: Instance): number
	local EndTime = StunnedUntil[entity]
	if not EndTime then
		return 0
	end
	return math.max(0, EndTime - os.clock())
end

function StunManager:Clear(entity: Instance)
	StunnedUntil[entity] = nil
	local entry = HardStuns[entity]
	if entry then releaseHardStun(entity, entry) end
end

function StunManager.OnPlayerRemoved(Player: Player)
	StunnedUntil[Player] = nil
	HardStuns[Player] = nil
end

return StunManager
