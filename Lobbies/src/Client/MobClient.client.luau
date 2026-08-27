local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimationHandler = require(ReplicatedStorage.Shared.AnimationHandler)

local Templates = ReplicatedStorage.Resources.UI.Templates
local MobsFolder = workspace:WaitForChild("Mobs")

local ActiveOverheads: { [Model]: BillboardGui } = {}

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
	Handler:Play("Die", 0.1)
end

local function SetupMovementAnimation(mobModel: Model, Humanoid: Humanoid)
	local Handler = AnimationHandler.GetOrCreate(mobModel)
	local CurrentAnim: string? = nil

	local function SetAnim(animName: string)
		if CurrentAnim == animName then
			return
		end

		if CurrentAnim then
			Handler:Stop(CurrentAnim, 0.15)
		end

		Handler:Play(animName, 0.15)
		CurrentAnim = animName
	end

	local RunningConnection = Humanoid.Running:Connect(function(speed: number)
		if speed > 0.5 then
			SetAnim("Walk")
		else
			SetAnim("Idle")
		end
	end)

	SetAnim(Humanoid.WalkSpeed > 0 and "Idle" or "Idle")

	return RunningConnection
end

local function SetupMob(mobModel: Model)
	local Humanoid = mobModel:FindFirstChildOfClass("Humanoid") :: Humanoid?
	local RootPart = mobModel.PrimaryPart or (mobModel:FindFirstChild("HumanoidRootPart") :: BasePart?)

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
		SetupMob(mobModel)
	end
end

MobsFolder.ChildAdded:Connect(function(child)
	if child:IsA("Model") then
		SetupMob(child)
	end
end)
