local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local UI = {}

local ActiveTweens = {} :: { [string]: { Main: Tween?, Trail: Tween? } }

function UI.UpdateBar(value: number, maxValue: number, bar: string)
	local Bar = UIConstants.PlayerGui:WaitForChild("HUD").Main:FindFirstChild(bar)
	local MainContainer = Bar:FindFirstChild("Main")

	MainContainer:FindFirstChild("Amount").Text = value .. "/" .. maxValue

	local Percentage = math.clamp(value / maxValue, 0, 1)

	local Existing = ActiveTweens[bar]
	if Existing then
		if Existing.Main then
			Existing.Main:Cancel()
		end
		if Existing.Trail then
			Existing.Trail:Cancel()
		end
	end

	local MainInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local MainTween = TweenService:Create(MainContainer.Bar, MainInfo, { Size = UDim2.fromScale(Percentage, 1) })

	ActiveTweens[bar] = { Main = MainTween }

	MainTween:Play()
end

return UI
