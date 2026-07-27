local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Indicators = {}

local IndicatorList = {}

for _, indicator: BasePart in ReplicatedStorage.Assets.Indicators:GetDescendants() do
	if indicator:IsA("BasePart") then
		IndicatorList[indicator] = true
	end
end

function Indicators:CreateIndicator(indicator: string, color: {}, position: CFrame | Vector3, time: number)
	task.spawn(function()
		local Indicator = IndicatorList[indicator] :: BasePart
		if not Indicator then
			return
		end

		Indicator = Indicator:Clone()
		Indicator.Color = color.Main
		Indicator.Transparency = 0.5
		if typeof(position) == CFrame then
			Indicator:PivotTo(position)
		else
			Indicator.Position = position
		end

		local TweenInfo = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingStyle.Linear)
		local Tween
		local FakeIndicator = Indicator:Clone()
		FakeIndicator.Color = color.Display
		if FakeIndicator.Shape == Enum.PartType.Block then
			FakeIndicator.Size = Vector3.new(1, FakeIndicator.Size.Y, 1)
			Tween = TweenService:Create(FakeIndicator, TweenInfo, { Size = Indicator.Size })
		elseif FakeIndicator.Shape == Enum.PartType.Cylinder then
			FakeIndicator.Size = Vector3.new(1, 1, FakeIndicator.Size.Z)
			Tween = TweenService:Create(FakeIndicator, TweenInfo, { Size = Indicator.Size })
		end

		Tween:Play()
		Tween.Completed:Wait()
		FakeIndicator.Material = Enum.Material.Neon
		Debris:AddItem(FakeIndicator, 1)
	end)
end

return Indicators
