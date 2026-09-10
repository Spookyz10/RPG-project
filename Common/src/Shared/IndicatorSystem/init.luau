local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Indicators = {}

local IndicatorList: { [string]: BasePart } = {}

for _, indicator: BasePart in ReplicatedStorage.Resources.Indicators:GetDescendants() do
	if indicator:IsA("BasePart") then
		IndicatorList[string.lower(indicator.Name)] = indicator
	end
end

function Indicators:CreateIndicator(
	indicatorName: string,
	color: {},
	position: CFrame | Vector3,
	time: number,
	size: Vector3?
)
	task.spawn(function()
		local Template = IndicatorList[string.lower(indicatorName)] :: BasePart
		if not Template then
			return
		end

		local Indicator = Template:Clone()
		Indicator.Anchored = true
		Indicator.CanCollide = false
		Indicator.CanTouch = false
		Indicator.CanQuery = false
		Indicator.Color = Color3.fromRGB(220, 25, 35)
		Indicator.Material = Enum.Material.SmoothPlastic
		Indicator.Transparency = 0.5
		Indicator.Parent = workspace

		if size then
			-- Callers provide footprint X/Z and thickness Y. Cylinders run along local X.
			Indicator.Size = Indicator:IsA("Part") and Indicator.Shape == Enum.PartType.Cylinder
				and Vector3.new(size.Y, size.X, size.Z) or size
		end

		if typeof(position) == "CFrame" then
			Indicator:PivotTo(position * (Indicator:IsA("Part") and Indicator.Shape == Enum.PartType.Cylinder
				and CFrame.Angles(0, 0, math.pi / 2) or CFrame.identity))
		else
			Indicator.Position = position
		end

		local TweenInfoObj = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local Tween
		local FakeIndicator = Indicator:Clone()
		FakeIndicator.Color = Color3.fromRGB(255, 35, 45)
		FakeIndicator.Transparency = 0
		FakeIndicator.CFrame += Vector3.new(0, 0.02, 0)
		FakeIndicator.Parent = Indicator.Parent

		if FakeIndicator:IsA("Part") and FakeIndicator.Shape == Enum.PartType.Block then
			FakeIndicator.Size = Vector3.new(1, FakeIndicator.Size.Y, 1)
			Tween = TweenService:Create(FakeIndicator, TweenInfoObj, { Size = Indicator.Size })
		elseif FakeIndicator:IsA("Part") and FakeIndicator.Shape == Enum.PartType.Cylinder then
			FakeIndicator.Size = Vector3.new(FakeIndicator.Size.X, 1, 1)
			Tween = TweenService:Create(FakeIndicator, TweenInfoObj, { Size = Indicator.Size })
		end

		if Tween then
			Tween:Play()
			Tween.Completed:Wait()
		else
			task.wait(time)
		end

		FakeIndicator.Material = Enum.Material.Neon
		Indicator.Material = Enum.Material.Neon
		Debris:AddItem(FakeIndicator, 0.15)
		Debris:AddItem(Indicator, 0.15)
	end)
end

return Indicators
