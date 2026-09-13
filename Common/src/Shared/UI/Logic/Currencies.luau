local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Abbreviation = require(ReplicatedStorage.Shared.Utils.Abbreviation)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local TweenService = game:GetService("TweenService")

local Currencies = {}

local CurrencyNames = { "Gold", "Raid Coins", "Tokens", "Rune Crystals" }

local Container: Instance = nil
local LastAmounts: { [string]: number } = {}
local ActiveGainTweens: { [Instance]: { Tween } } = {}
local GainPositions: { [Instance]: UDim2 } = {}
local AmountScales: { [Instance]: number } = {}

local function UpdateCurrency(currencyName: string, amount: number, previous: number?)
	if not Container then
		return
	end

	local Frame = Container:FindFirstChild(currencyName)
	if not Frame then
		return
	end

	local AmountLabel = Frame:FindFirstChild("Amount") :: TextLabel?
	if not AmountLabel then
		return
	end

	AmountLabel.Text = Abbreviation:Number(amount)
	if previous and amount > previous then
		local scale = AmountLabel:FindFirstChild("GainPop") :: UIScale?
		local gain = Frame:FindFirstChild("Gain") :: TextLabel?
		if not scale or not gain then return end
		GainPositions[Frame] = GainPositions[Frame] or gain.Position
		AmountScales[Frame] = AmountScales[Frame] or scale.Scale
		local current = ActiveGainTweens[Frame]
		if current then for _, tween in current do tween:Cancel() end end
		gain.Text = "+" .. Abbreviation:Number(amount - previous); gain.TextTransparency = 0
		local startPosition = GainPositions[Frame]
		local endPosition = gain:GetAttribute("EndPosition") or startPosition
		gain.Position = startPosition
		scale.Scale = scale:GetAttribute("PulseStartScale") or scale.Scale
		local scaleTween = TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = AmountScales[Frame] })
		local gainTween = TweenService:Create(gain, TweenInfo.new(0.7, Enum.EasingStyle.Quad), { Position = endPosition, TextTransparency = 1 })
		ActiveGainTweens[Frame] = { scaleTween, gainTween }
		scaleTween:Play()
		gainTween:Play()
		gainTween.Completed:Once(function()
			local active = ActiveGainTweens[Frame]
			if active and active[2] == gainTween then
				gain.Position = startPosition
				ActiveGainTweens[Frame] = nil
			end
		end)
	end
end

function Currencies.Init()
	Container = UIConstants.PlayerGui:WaitForChild("HUD"):WaitForChild("Main"):WaitForChild("Currencies")

	local CurrentCurrencies = UIConstants.Data.Currencies()

	for _, currencyName in CurrencyNames do
		UpdateCurrency(currencyName, CurrentCurrencies[currencyName] or 0)
		LastAmounts[currencyName] = CurrentCurrencies[currencyName] or 0
	end

	for _, currencyName in CurrencyNames do
		UIConstants.Data.Currencies[currencyName].Changed(function(newAmount)
			local oldAmount = LastAmounts[currencyName] or 0
			UpdateCurrency(currencyName, newAmount, oldAmount)
			LastAmounts[currencyName] = newAmount
		end)
	end
end

return Currencies
