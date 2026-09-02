local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AnimationHandler = require(ReplicatedStorage.Shared.AnimationHandler)
local MobAnimations = require(ReplicatedStorage.Shared.MobAnimations)

local Templates = ReplicatedStorage.Resources.UI.Templates
local MobsFolder = workspace:WaitForChild("Mobs")

local ActiveOverheads: { [Model]: BillboardGui } = {}

local MOVE_THRESHOLD = 1
local WAIT_TIMEOUT = 5

local function UpdateHP(Overhead: BillboardGui, Humanoid: Humanoid)
	local Bar = Overhead.HP.Bar
	local Health = Overhead.HP.Health

	local Percent = Humanoid.MaxHealth > 0 and math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1) or 0

	Bar.Size = UDim2.new(Percent, 0, Bar.Size.Y.Scale, Bar.Size.Y.Offset)
	Health.Text = math.floor(math.max(Humanoid.Health, 0)) .. "/" .. math.floor(Humanoid.MaxHealth)
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
		SetAnim(Speed > MOVE_THRESHOLD and "Walk" or "Idle")
	end)

	return {
		Disconnect = function()
			Alive = false
			Connection:Disconnect()
		end,
	}
end

local function SetupMob(mobModel: Model)
	local Humanoid = mobModel:FindFirstChildOfClass("Humanoid") :: Humanoid?
		or (mobModel:WaitForChild("Humanoid", WAIT_TIMEOUT) :: Humanoid?)

	local RootPart = mobModel.PrimaryPart
		or (mobModel:FindFirstChild("HumanoidRootPart") :: BasePart?)
		or (mobModel:WaitForChild("HumanoidRootPart", WAIT_TIMEOUT) :: BasePart?)

	if not mobModel.Parent then
		return
	end

	if not Humanoid or not RootPart then
		return
	end

	local Overhead = Templates.MobOverhead:Clone() :: BillboardGui
	Overhead.Adornee = RootPart
	Overhead.Parent = RootPart

	Overhead.Info.MobName.Text = mobModel.Name

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
		HealthConnection:Disconnect()
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