local StunManager = {}

local StunnedUntil: { [Instance]: number } = {}

function StunManager:Stun(entity: Instance, duration: number)
	local EndTime = os.clock() + duration
	StunnedUntil[entity] = EndTime

	task.delay(duration, function()
		if StunnedUntil[entity] == EndTime then
			StunnedUntil[entity] = nil
		end
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

function StunManager:GetTimeLeft(entity: Instance): number
	local EndTime = StunnedUntil[entity]
	if not EndTime then
		return 0
	end
	return math.max(0, EndTime - os.clock())
end

function StunManager:Clear(entity: Instance)
	StunnedUntil[entity] = nil
end

function StunManager.OnPlayerRemoved(Player: Player)
	StunnedUntil[Player] = nil
end

return StunManager
