local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local Abbreviation = require(ReplicatedStorage.Shared.Utils.Abbreviation)

local UI = {}
local StatusEffects = require(ReplicatedStorage.Shared.StatusEffects)

local ActiveTweens = {} :: { [string]: { Main: Tween?, Trail: Tween? } }
local PreviousValues: { [string]: number } = {}
local OriginalHPColor: Color3? = nil

local function pulse(object: GuiObject, scale: number, duration: number)
	local effect = object:FindFirstChild("FeedbackScale") :: UIScale?
	if not effect then
		effect = Instance.new("UIScale")
		effect.Name = "FeedbackScale"
		effect.Parent = object
	end
	TweenService:Create(effect, TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = scale }):Play()
	task.delay(duration, function()
		if effect and effect.Parent then
			TweenService:Create(effect, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		end
	end)
end

local function playXPGain(main: Frame)
	local shine = main:FindFirstChild("XPGainShine") :: Frame?
	if not shine then
		shine = Instance.new("Frame")
		shine.Name = "XPGainShine"
		shine.AnchorPoint = Vector2.new(0.5, 0.5)
		shine.BackgroundColor3 = Color3.fromRGB(235, 250, 255)
		shine.BackgroundTransparency = 0.35
		shine.BorderSizePixel = 0
		shine.Size = UDim2.fromScale(0.16, 1.8)
		shine.ZIndex = main.ZIndex + 1
		shine.Parent = main
	end
	shine.Position = UDim2.fromScale(-0.12, 0.5)
	shine.BackgroundTransparency = 0.35
	TweenService:Create(shine, TweenInfo.new(0.48, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(1.12, 0.5),
		BackgroundTransparency = 1,
	}):Play()
	pulse(main, 1.05, 0.13)
end

local function playHealthLoss(main: Frame, previousPercentage: number, percentage: number)
	local trail = main:FindFirstChild("HealthLossTrail") :: Frame?
	if not trail then
		trail = Instance.new("Frame")
		trail.Name = "HealthLossTrail"
		trail.BackgroundColor3 = Color3.fromRGB(255, 92, 101)
		trail.BorderSizePixel = 0
		trail.ZIndex = math.max(0, main.ZIndex - 1)
		trail.Parent = main
	end
	trail.Size = UDim2.fromScale(previousPercentage, 1)
	trail.BackgroundTransparency = 0.1
	task.delay(0.12, function()
		if trail and trail.Parent then
			TweenService:Create(trail, TweenInfo.new(0.42, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.fromScale(percentage, 1),
				BackgroundTransparency = 1,
			}):Play()
		end
	end)
	pulse(main, 1.045, 0.1)
end

function UI.UpdateBar(value: number, maxValue: number, bar: string, isInitial: boolean?)
	local Bar = UIConstants.PlayerGui:WaitForChild("HUD").Main:FindFirstChild(bar)
	if not Bar then return end
	local MainContainer = Bar:FindFirstChild("Main")
	if not MainContainer or not MainContainer:IsA("Frame") then return end
	local Fill = MainContainer:FindFirstChild("Bar")
	if not Fill or not Fill:IsA("Frame") then return end

	MainContainer:FindFirstChild("Amount").Text = bar .. "  " .. Abbreviation:Number(math.max(0, value), 0) .. " / " .. Abbreviation:Number(math.max(0, maxValue), 0)
	if bar == "HP" then
		OriginalHPColor = OriginalHPColor or MainContainer.Bar.BackgroundColor3
		local character = game:GetService("Players").LocalPlayer.Character
		local selected
		for _, effect in StatusEffects do
			if character and effect.Attribute and effect.HealthBar and character:GetAttribute(effect.Attribute) and value > 0 then
				if not selected or (effect.HealthBar.Priority or 0) > (selected.Priority or 0) then selected = effect.HealthBar end
			end
		end
		MainContainer.Bar.BackgroundColor3 = selected and Color3.fromRGB(table.unpack(selected.Color)) or OriginalHPColor
		if selected then MainContainer.Amount.Text ..= "  [" .. selected.Label .. "]" end
	end

	local Percentage = maxValue > 0 and math.clamp(value / maxValue, 0, 1) or 0
	local previousValue = PreviousValues[bar]
	local previousPercentage = previousValue and maxValue > 0 and math.clamp(previousValue / maxValue, 0, 1) or Percentage
	PreviousValues[bar] = value

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
	local MainTween = TweenService:Create(Fill, MainInfo, { Size = UDim2.fromScale(Percentage, 1) })

	ActiveTweens[bar] = { Main = MainTween }

	MainTween:Play()
	if not isInitial and previousValue then
		if bar == "XP" and value > previousValue then
			playXPGain(MainContainer)
		elseif bar == "HP" and value < previousValue then
			playHealthLoss(MainContainer, previousPercentage, Percentage)
		end
	end
end

function UI.PlayLevelUp()
	local hud = UIConstants.PlayerGui:WaitForChild("HUD").Main
	local level = hud:FindFirstChild("Level")
	if level and level:IsA("TextLabel") then
		local originalColor = level.TextColor3
		level.TextColor3 = Color3.fromRGB(255, 217, 92)
		pulse(level, 1.22, 0.18)
		task.delay(0.5, function()
			if level.Parent then
				TweenService:Create(level, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { TextColor3 = originalColor }):Play()
			end
		end)
	end
	local xp = hud:FindFirstChild("XP")
	local main = xp and xp:FindFirstChild("Main")
	if main and main:IsA("Frame") then
		playXPGain(main)
	end
end

return UI
