local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Abbreviation = require(ReplicatedStorage.Shared.Utils.Abbreviation)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local Currencies = {}

local CurrencyNames = { "Gold", "Raid Coins", "Tokens", "Rune Crystals" }

local Container: Instance = nil

local function UpdateCurrency(currencyName: string, amount: number)
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
end

function Currencies.Init()
	Container = UIConstants.PlayerGui:WaitForChild("HUD"):WaitForChild("Main"):WaitForChild("Currencies")

	local CurrentCurrencies = UIConstants.Data.Currencies()

	for _, currencyName in CurrencyNames do
		UpdateCurrency(currencyName, CurrentCurrencies[currencyName] or 0)
	end

	for _, currencyName in CurrencyNames do
		UIConstants.Data.Currencies[currencyName].Changed(function(newAmount)
			UpdateCurrency(currencyName, newAmount)
		end)
	end
end

return Currencies
