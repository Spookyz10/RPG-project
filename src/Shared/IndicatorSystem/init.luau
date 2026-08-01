local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Indicators = {}

local IndicatorList: { [string]: BasePart } = {}

for _, indicator: BasePart in ReplicatedStorage.Assets.Indicators:GetDescendants() do
	if indicator:IsA("BasePart") then
		IndicatorList[indicator.Name] = indicator
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
		local Template = IndicatorList[indicatorName] :: BasePart
		if not Template then
			return
		end

		local Indicator = Template:Clone()
		Indicator.Color = color.Main
		Indicator.Transparency = 0.5

		if size then
			Indicator.Size = size
		end

		if typeof(position) == CFrame then
			Indicator:PivotTo(position)
		else
			Indicator.Position = position
		end

		local TweenInfo = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingStyle.Linear)
		local Tween
		local FakeIndicator = Indicator:Clone()
		FakeIndicator.Color = color.Display
		FakeIndicator.Parent = Indicator.Parent

		if FakeIndicator.Shape == Enum.PartType.Block then
			FakeIndicator.Size = Vector3.new(1, FakeIndicator.Size.Y, 1)
			Tween = TweenService:Create(FakeIndicator, TweenInfo, { Size = Indicator.Size })
		elseif FakeIndicator.Shape == Enum.PartType.Cylinder then
			FakeIndicator.Size = Vector3.new(FakeIndicator.Size.X, 1, 1)
			Tween = TweenService:Create(FakeIndicator, TweenInfo, { Size = Indicator.Size })
		end

		Tween:Play()
		Tween.Completed:Wait()
		FakeIndicator.Material = Enum.Material.Neon
		Debris:AddItem(FakeIndicator, 1)
	end)
end

return Indicators
