-- Client-only pose evaluation. No per-frame joint replication.
local RunService = game:GetService("RunService")
local Resources = game:GetService("ReplicatedStorage"):WaitForChild("Resources")
assert(RunService:IsClient(), "Animation playback is client-only")
local MobAnimations = {}
local active = {}
local compiled = setmetatable({}, { __mode = "k" })
local connection
local startedFolders = setmetatable({}, { __mode = "k" })

local function compile(sequence)
	if compiled[sequence] then return compiled[sequence] end
	local frames = sequence:GetKeyframes()
	table.sort(frames, function(a, b) return a.Time < b.Time end)
	local clip = { Frames = {}, Length = 0, Loop = sequence.Loop }
	for _, frame in frames do
		local poses = {}
		for _, pose in frame:GetDescendants() do
			if pose:IsA("Pose") and pose.Weight > 0 then poses[pose.Name] = pose.CFrame end
		end
		table.insert(clip.Frames, { Time = frame.Time, Poses = poses })
		clip.Length = math.max(clip.Length, frame.Time)
	end
	compiled[sequence] = clip
	return clip
end

local function sample(clip, time, name)
	if not clip or #clip.Frames == 0 then return CFrame.identity end
	if clip.Loop and clip.Length > 0 then time %= clip.Length end
	local frames = clip.Frames
	local a, b = frames[1], frames[#frames]
	for i = 2, #frames do
		if time <= frames[i].Time then a, b = frames[i - 1], frames[i]; break end
	end
	local alpha = math.clamp((time - a.Time) / math.max(0.0001, b.Time - a.Time), 0, 1)
	return (a.Poses[name] or CFrame.identity):Lerp(b.Poses[name] or CFrame.identity, alpha)
end

function MobAnimations:Detach(model)
	local state = active[model]
	if not state then return end
	active[model] = nil
	if state.OneShot then model:SetAttribute("ClientMotion", nil) end
	for _, joint in state.Joints do if joint.Parent then joint.Transform = CFrame.identity end end
	for _, signal in state.Connections do signal:Disconnect() end
	if next(active) == nil and connection then connection:Disconnect(); connection = nil end
end

local function step(dt)
	local now = workspace:GetServerTimeNow()

	for model, state in active do
		if not model:IsDescendantOf(workspace) or not state.Root.Parent or not state.Humanoid.Parent or state.Humanoid.Health <= 0 then
			MobAnimations:Detach(model)
			continue
		end
		local position = state.Root.Position
		local camera = workspace.CurrentCamera
		if not state.OneShot and camera and (camera.CFrame.Position - position).Magnitude > 240 then
			state.LastPosition = position
			continue
		end
		local distance = (position - state.LastPosition) * Vector3.new(1, 0, 1)
		state.LastPosition = position
		local speed = math.min(distance.Magnitude / math.max(dt, 0.001), state.Humanoid.WalkSpeed * 1.8)
		state.Speed += (speed - state.Speed) * (1 - math.exp(-dt * 12))
		state.WalkTime += dt * math.clamp(state.Speed / state.ReferenceSpeed, 0, 1.8)
		if state.OneShot then
			if now - state.Started >= state.AttackClip.Length then
				MobAnimations:Detach(model)
				continue
			end
		end
		local attack = state.OneShot or model:GetAttribute("Attack")
		local started = state.OneShot and state.Started or model:GetAttribute("AttackStartedAt")
		if attack and (attack ~= state.Attack or started ~= state.Started) then
			state.Attack, state.Started = attack, started or now
			state.AttackClip = state.Clips[attack]
		elseif not attack and state.Attack then
			state.Attack = nil
			state.RecoveryEnds = now + 0.18
		end
		local attackClip = state.AttackClip
		local attackTime = state.Started and now - state.Started or 0
		local attacking = attackClip and (attack ~= nil or now < (state.RecoveryEnds or 0))
		local walkWeight = math.clamp(state.Speed / 3, 0, 1)
		for name, joint in state.Joints do
			if not joint.Parent then continue end
			local pose = sample(state.Clips.Idle, now + state.Phase, name)
			pose = pose:Lerp(sample(state.Clips.Walk, state.WalkTime, name), walkWeight)
			if attacking then pose = sample(attackClip, attackTime, name) end
			pose = CFrame.new(pose.Position * state.Scale) * pose.Rotation
			local previous = state.Poses[name] or CFrame.identity
			pose = previous:Lerp(pose, 1 - math.exp(-dt * (attacking and 35 or 14)))
			state.Poses[name] = pose
			joint.Transform = pose
		end
	end
end

function MobAnimations:Attach(model, playerClip, startedAt)
	if active[model] then return end
	local library = Resources:FindFirstChild("MobMotion")
	local folder = playerClip and playerClip.Parent or library and library:FindFirstChild(model.Name)
	local root = model:FindFirstChild("HumanoidRootPart")
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not folder or not root or not hum or hum.Health <= 0 then return end
	local state = { Root = root, Humanoid = hum, Joints = {}, Clips = {}, Poses = {}, Connections = {},
		LastPosition = root.Position, Speed = 0, WalkTime = 0, Phase = math.random() * 3,
		Scale = model:GetScale() / (folder:GetAttribute("RigScale") or 1),
		ReferenceSpeed = folder:GetAttribute("WalkSpeed") or 12 }
	local names = {}
	for _, seq in (playerClip and { playerClip } or folder:GetChildren()) do
		if seq:IsA("KeyframeSequence") then
			local clip = compile(seq)
			state.Clips[seq.Name] = clip
			for _, frame in clip.Frames do for name in frame.Poses do names[name] = true end end
		end
	end
	local function addJoint(joint)
		if joint:IsA("Motor6D") and joint.Part1 and names[joint.Part1.Name] then
			state.Joints[joint.Part1.Name] = joint
		end
	end
	for _, joint in model:GetDescendants() do addJoint(joint) end
	table.insert(state.Connections, model.DescendantAdded:Connect(addJoint))
	if playerClip then
		model:SetAttribute("ClientMotion", playerClip.Name)
		state.OneShot = playerClip.Name
		state.Attack = playerClip.Name
		state.AttackClip = state.Clips[playerClip.Name]
		state.Started = startedAt or workspace:GetServerTimeNow()
	end
	active[model] = state
	table.insert(state.Connections, model.Destroying:Connect(function() self:Detach(model) end))
	table.insert(state.Connections, hum.Died:Connect(function() self:Detach(model) end))
	if not connection then
		connection = RunService.PreSimulation:Connect(step)
	end
	return state
end

function MobAnimations:Play(model, name, startedAt)
	local library = Resources:FindFirstChild("PlayerMotion")
	local clip = library and library:FindFirstChild(name)
	if not clip or not clip:IsA("KeyframeSequence") then
		warn("Missing client PlayerMotion clip: " .. name)
		return 0
	end
	if startedAt and workspace:GetServerTimeNow() - startedAt >= compile(clip).Length then return 0 end
	local current = active[model]
	if current and startedAt and current.Started and startedAt <= current.Started then return 0 end
	self:Detach(model)
	local state = self:Attach(model, clip, startedAt)
	return state and state.AttackClip.Length or 0
end

function MobAnimations:Start(folder)
	if startedFolders[folder] then return end
	startedFolders[folder] = true
	local function attach(model)
		if not model:IsA("Model") then return end
		task.spawn(function()
			local hum = model:WaitForChild("Humanoid", 10)
			local root = model:WaitForChild("HumanoidRootPart", 10)
			if hum and root and model.Parent == folder then self:Attach(model) end
		end)
	end
	for _, model in folder:GetChildren() do attach(model) end
	folder.ChildAdded:Connect(attach)
	folder.ChildRemoved:Connect(function(model) self:Detach(model) end)
end

-- Compile replicated pose data during loading, before the first cast or spawn.
function MobAnimations:Preload()
	for _, name in { "MobMotion", "PlayerMotion" } do
		local library = Resources:WaitForChild(name, 10)
		if library then
			for _, sequence in library:GetDescendants() do
				if sequence:IsA("KeyframeSequence") then compile(sequence) end
			end
		end
	end
end

return MobAnimations
