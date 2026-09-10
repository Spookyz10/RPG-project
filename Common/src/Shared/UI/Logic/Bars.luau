local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local UI = {}
local StatusEffects = require(ReplicatedStorage.Shared.StatusEffects)

local ActiveTweens = {} :: { [string]: { Main: Tween?, Trail: Tween? } }
local OriginalHPColor: Color3? = nil

function UI.UpdateBar(value: number, maxValue: number, bar: string)
	local Bar = UIConstants.PlayerGui:WaitForChild("HUD").Main:FindFirstChild(bar)
	local MainContainer = Bar:FindFirstChild("Main")

	MainContainer:FindFirstChild("Amount").Text = bar .. "  " .. math.floor(math.max(0, value)) .. " / " .. math.floor(math.max(0, maxValue))
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
