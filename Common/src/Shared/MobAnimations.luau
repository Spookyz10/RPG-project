-- Local playback of editable KeyframeSequences. Server owns combat and movement.
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local MobAnimations = {}
local active = {}
local compiled = setmetatable({}, { __mode = "k" })
local connection

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
	for _, joint in state.Joints do if joint.Parent then joint.Transform = CFrame.identity end end
	for _, signal in state.Connections do signal:Disconnect() end
	if next(active) == nil and connection then connection:Disconnect(); connection = nil end
end

local function step(dt)
	local now = workspace:GetServerTimeNow()
	local camera = workspace.CurrentCamera
	for model, state in active do
		if not model:IsDescendantOf(workspace) or state.Humanoid.Health <= 0 then
			MobAnimations:Detach(model)
			continue
		end
		local position = state.Root.Position
		local distance = (position - state.LastPosition) * Vector3.new(1, 0, 1)
		state.LastPosition = position
		local speed = math.min(distance.Magnitude / math.max(dt, 0.001), state.Humanoid.WalkSpeed * 1.8)
		state.Speed += (speed - state.Speed) * (1 - math.exp(-dt * 12))
		state.WalkTime += dt * math.clamp(state.Speed / state.ReferenceSpeed, 0, 1.8)
		if camera and (camera.CFrame.Position - position).Magnitude > 220 then continue end
		local attack = model:GetAttribute("Attack")
		local started = model:GetAttribute("AttackStartedAt")
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

function MobAnimations:Attach(model)
	if not RunService:IsClient() or active[model] then return end
	local resources = RS:FindFirstChild("Resources")
	local library = resources and resources:FindFirstChild("MobMotion")
	local folder = library and library:FindFirstChild(model.Name)
	local root = model:FindFirstChild("HumanoidRootPart")
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not folder or not root or not hum or hum.Health <= 0 then return end
	local state = { Root = root, Humanoid = hum, Joints = {}, Clips = {}, Poses = {}, Connections = {},
		LastPosition = root.Position, Speed = 0, WalkTime = 0, Phase = math.random() * 3,
		Scale = model:GetScale() / (folder:GetAttribute("RigScale") or 1),
		ReferenceSpeed = folder:GetAttribute("WalkSpeed") or 12 }
	local names = {}
	for _, seq in folder:GetChildren() do
		if seq:IsA("KeyframeSequence") then
			local clip = compile(seq)
			state.Clips[seq.Name] = clip
			for _, frame in clip.Frames do for name in frame.Poses do names[name] = true end end
		end
	end
	for _, joint in model:GetDescendants() do
		if joint:IsA("Motor6D") and joint.Part1 and names[joint.Part1.Name] then
			state.Joints[joint.Part1.Name] = joint
		end
	end
	active[model] = state
	table.insert(state.Connections, model.Destroying:Connect(function() self:Detach(model) end))
	table.insert(state.Connections, hum.Died:Connect(function() self:Detach(model) end))
	if not connection then connection = RunService.PreSimulation:Connect(step) end
end

function MobAnimations:Start(folder)
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

return MobAnimations
