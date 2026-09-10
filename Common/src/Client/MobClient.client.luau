local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local AnimationHandler = require(ReplicatedStorage.Shared.AnimationHandler)
local MobAnimations = require(ReplicatedStorage.Shared.MobAnimations)
local MobsData = require(ReplicatedStorage.Shared.MobsData)

local Templates = require(ReplicatedStorage.Shared.UI.Bootstrap).GetTemplates()
local MobsFolder = workspace:WaitForChild("Mobs")

local ActiveOverheads: { [Model]: BillboardGui } = {}
local HealthTweens = {}
local PreviousHealth = {}

local function UpdateHP(Overhead: BillboardGui, Humanoid: Humanoid)
	local Bar = (Overhead.HP:FindFirstChild("Track") or Overhead.HP).Bar
	local Health = Overhead.HP.Health

	local Percent = Humanoid.MaxHealth > 0 and math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1) or 0

	local previous = PreviousHealth[Overhead]
	PreviousHealth[Overhead] = Humanoid.Health
	if HealthTweens[Overhead] then HealthTweens[Overhead]:Cancel(); HealthTweens[Overhead] = nil end
	local goal = UDim2.fromScale(Percent, 1)
	if previous ~= nil and Humanoid.Health < previous then
		local tween = TweenService:Create(Bar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = goal })
		HealthTweens[Overhead] = tween
		tween:Play()
	else
		Bar.Size = goal
	end
	Health.Text = "HP  " .. math.floor(math.max(Humanoid.Health, 0)) .. " / " .. math.floor(math.max(Humanoid.MaxHealth, 0))
end

local function PlayDeathAnimation(mobModel: Model)
	local Handler = AnimationHandler.GetOrCreate(mobModel)
	Handler:StopAll(0)
	MobAnimations:Play(mobModel, "Die", 0.1)
end

local function SetupMovementAnimation(mobModel: Model, Humanoid: Humanoid)
	local RootPart = mobModel.PrimaryPart or (mobModel:FindFirstChild("HumanoidRootPart") :: BasePart?)

	local CurrentAnimName: string? = nil
	local CurrentTrack: AnimationTrack? = nil
	local Alive = true

	local function SetAnim(animName: string)
		if CurrentAnimName == animName and CurrentTrack then
			return
		end

		local NewTrack = MobAnimations:Play(mobModel, animName, 0.15)
		if not NewTrack then
			return
		end

		if CurrentTrack and CurrentTrack.IsPlaying and CurrentTrack ~= NewTrack then
			CurrentTrack:Stop(0.15)
		end

		CurrentTrack = NewTrack
		CurrentAnimName = animName
	end

	SetAnim("Idle")

	local Connection = RunService.Heartbeat:Connect(function()
		if not Alive or not RootPart or not RootPart.Parent then
			return
		end

		if Humanoid.Health <= 0 then
			return
		end

		local Speed = RootPart.AssemblyLinearVelocity.Magnitude
		SetAnim(Speed > 1 and "Walk" or "Idle")
	end)

	return {
		Disconnect = function()
			Alive = false
			Connection:Disconnect()
		end,
	}
end

local function SetupMob(mobModel: Model)
	local Humanoid = mobModel:WaitForChild("Humanoid") :: Humanoid

	local RootPart = mobModel:WaitForChild("HumanoidRootPart")

	if not mobModel.Parent then
		return
	end

	local Overhead = Templates.MobOverhead:Clone() :: BillboardGui
	Overhead.Adornee = RootPart
	Overhead.Parent = RootPart

	Overhead.Info.MobName.Text = mobModel.Name
	local function UpdateLevel()
		local badge = Overhead.Info:FindFirstChild("LevelBadge")
		if badge then
			local info = MobsData[mobModel.Name]
			badge.Level.Text = "Lv. " .. tostring(mobModel:GetAttribute("Level") or (info and info.Level) or 1)
		end
	end
	UpdateLevel()
	local LevelConnection = mobModel:GetAttributeChangedSignal("Level"):Connect(UpdateLevel)
	local bounds, size = mobModel:GetBoundingBox()
	Overhead.StudsOffset = Vector3.zero
	Overhead.StudsOffsetWorldSpace = Vector3.new(0, bounds.Position.Y + size.Y / 2 - RootPart.Position.Y + 1.2, 0)

	UpdateHP(Overhead, Humanoid)

	local HealthConnection = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		UpdateHP(Overhead, Humanoid)
	end)

	local MaxHealthConnection = Humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
		UpdateHP(Overhead, Humanoid)
	end)

	local RunningConnection = SetupMovementAnimation(mobModel, Humanoid)

	local DiedConnection = Humanoid.Died:Connect(function()
		Overhead.Enabled = false
		RunningConnection:Disconnect()
		PlayDeathAnimation(mobModel)
	end)

	ActiveOverheads[mobModel] = Overhead

	mobModel.Destroying:Connect(function()
		if HealthTweens[Overhead] then HealthTweens[Overhead]:Cancel(); HealthTweens[Overhead] = nil end
		PreviousHealth[Overhead] = nil
		HealthConnection:Disconnect()
		LevelConnection:Disconnect()
		MaxHealthConnection:Disconnect()
		DiedConnection:Disconnect()
		RunningConnection:Disconnect()
		ActiveOverheads[mobModel] = nil
	end)
end

for _, mobModel in MobsFolder:GetChildren() do
	if mobModel:IsA("Model") then
		task.spawn(SetupMob, mobModel)
	end
end

MobsFolder.ChildAdded:Connect(function(child)
	if child:IsA("Model") then
		task.spawn(SetupMob, child)
	end
end)
