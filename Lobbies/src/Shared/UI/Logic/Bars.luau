local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local UI = {}

local ActiveTweens = {} :: { [string]: { Main: Tween?, Trail: Tween? } }

function UI.Init()
	UIConstants.PlayerGui:WaitForChild("HUD"):WaitForChild("Player").Icon.Image = Players:GetUserThumbnailAsync(
		UIConstants.Player.UserId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size100x100
	)

	UIConstants.PlayerGui:WaitForChild("HUD"):WaitForChild("Player").Level.Text = "Level: " .. UIConstants.Data.Level()

	UIConstants.Data.Level.Changed(function(newLevel)
		UIConstants.PlayerGui:WaitForChild("HUD"):WaitForChild("Player").Level.Text = "Level: " .. newLevel
	end)
end

function UI.UpdateBar(value: number, maxValue: number, bar: string)
	local Bar = UIConstants.PlayerGui:WaitForChild("HUD"):FindFirstChild(bar)
	local MainContainer = Bar:FindFirstChild("Container")
	local Trail = Bar:FindFirstChild("Trail")

	Bar:FindFirstChild("Value").Text = value .. "/" .. maxValue

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
	local MainTween = TweenService:Create(MainContainer, MainInfo, { Size = UDim2.fromScale(Percentage, 1) })

	local TrailInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local TrailTween = TweenService:Create(Trail, TrailInfo, { Size = UDim2.fromScale(Percentage, 1) })

	ActiveTweens[bar] = { Main = MainTween, Trail = TrailTween }

	MainTween:Play()
	TrailTween:Play()
end

return UI
