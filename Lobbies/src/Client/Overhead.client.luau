local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

	ActiveOverheads[mobModel] = Overhead

	mobModel.Destroying:Connect(function()
		HealthConnection:Disconnect()
		MaxHealthConnection:Disconnect()
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
