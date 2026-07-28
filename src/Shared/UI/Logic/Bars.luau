local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local UI = {}

function UI.Init()
	UIConstants.PlayerGui:FindFirstChild("HUD"):FindFirstChild("Player").Icon.Image = Players:GetUserThumbnailAsync(
		UIConstants.Player.UserId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size100x100
	)

	UIConstants.PlayerGui:FindFirstChild("HUD"):FindFirstChild("Player").Level.Text = "Level: "
		.. UIConstants.Data.Level()

	UIConstants.Data.Level.Changed(function(newLevel)
		UIConstants.PlayerGui:FindFirstChild("HUD"):FindFirstChild("Player").Level.Text = "Level: " .. newLevel
	end)
end

function UI.UpdateBar(value: number, maxValue: number, bar: string)
	local Bar = UIConstants.PlayerGui:FindFirstChild("HUD"):FindFirstChild(bar)
	local MainContainer = Bar:FindFirstChild("Container")
	local Trail = Bar:FindFirstChild("Trail")

	Bar:FindFirstChild("Value").Text = value .. "/" .. maxValue

	local TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local Percentage = value / maxValue
	local ContTween = TweenService:Create(MainContainer, TweenInfo, { Size = UDim2.fromScale(Percentage, 1) })
	local TrailTween = TweenService:Create(Trail, TweenInfo, { Size = UDim2.fromScale(Percentage, 1) })

	ContTween:Play()
	ContTween.Completed:Wait()
	TrailTween:Play()
end

return UI
