local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local MobsFolder = workspace:WaitForChild("Mobs")
local Template = ReplicatedStorage.Assets.UI.Templates.MobOverhead

local ActiveTweens: { [BillboardGui]: Tween } = {}

local function UpdateHPBar(Overhead: BillboardGui, hp: number, maxHp: number)
	local HP = Overhead:FindFirstChild("HP")
	if not HP then
		return
	end

	local Container = HP:FindFirstChild("Container")
	local Value = HP:FindFirstChild("Value")

	if Value then
		Value.Text = math.max(0, math.floor(hp)) .. "/" .. math.floor(maxHp)
	end

	if Container then
		local Percentage = math.clamp(hp / maxHp, 0, 1)

		local Existing = ActiveTweens[Overhead]
		if Existing then
			Existing:Cancel()
		end

		local Tween = TweenService:Create(
			Container,
			TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = UDim2.fromScale(Percentage, 1) }
		)
		ActiveTweens[Overhead] = Tween
		Tween:Play()
	end
end

local function WaitForPrimaryPart(mob: Model): boolean
	while not mob.PrimaryPart do
		if not mob.Parent then
			return false
		end
		task.wait(0.1)
	end
	return true
end

local function SetupMob(mob: Instance)
	if not mob:IsA("Model") then
		return
	end

	if not WaitForPrimaryPart(mob) then
		return
	end

	local Humanoid = mob:FindFirstChild("Humanoid") :: Humanoid

	if not Humanoid then
		return
	end

	local Overhead = Template:Clone()
	Overhead.Adornee = mob.PrimaryPart
	Overhead.MobName.Text = mob.Name
	Overhead.Parent = mob

	local function Refresh()
		if Humanoid then
			local HP = Humanoid.Health
			local MaxHP = Humanoid.MaxHealth
			UpdateHPBar(Overhead, HP, MaxHP)
		end
	end

	Humanoid.HealthChanged:Connect(Refresh)
	Humanoid:GetAttributeChangedSignal("MaxHealth"):Connect(Refresh)

	Refresh()

	mob.Destroying:Connect(function()
		ActiveTweens[Overhead] = nil
	end)
end

for _, mob in MobsFolder:GetChildren() do
	task.spawn(SetupMob, mob)
end

MobsFolder.ChildAdded:Connect(function(mob)
	task.spawn(SetupMob, mob)
end)
