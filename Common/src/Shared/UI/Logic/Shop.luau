local UI = script.Parent.Parent
local Constants = require(UI.UIConstants)
local Templates = require(UI.Bootstrap).GetTemplates()
local T = require(UI.Theme)
local Shops = require(UI.Parent.Shops)
local Items = require(UI.Parent.ItemsData)
local Windows = require(UI.WindowManager)
local Toast = require(UI.Toast)
local Remotes = require(UI.Parent.Utils.RemoteManager)
local Abbreviation = require(UI.Parent.Utils.Abbreviation)

local Shop = {}

local function formatCost(cost)
	local values = {}
	for currency, amount in cost do
		table.insert(values, Abbreviation:Number(amount) .. " " .. currency)
	end
	table.sort(values)
	return table.concat(values, " · ")
end

function Shop.Open(shopName)
	local definition = Shops[shopName]
	if not definition then
		Toast.Show("This shop is not available yet.")
		return
	end

	local root = Constants.PlayerGui.Shop.Main
	local container = root.Body.Content.Container
	for _, child in container:GetChildren() do
		if child:IsA("GuiObject") then child:Destroy() end
	end

	root.Heading.Text = shopName
	root.Subtitle.Text = "Choose potions and the quantity you want."
	local itemNames = {}
	for itemName in definition do table.insert(itemNames, itemName) end
	table.sort(itemNames)

	for _, itemName in itemNames do
		local offer = definition[itemName]
		local item = Items[itemName]
		local stackable = item and item.Data.Stackable == true
		local maxAmount = stackable and math.max(1, offer.MaxPurchase or 25) or 1
		local quantity = 1
		local available = offer.itemType == "Consumable" and item ~= nil
		local pending = false

		local card = Templates.ShopTemplate:Clone()
		card.Name = itemName
		card:FindFirstChild("Name").Text = itemName
		card.Price.Text = formatCost(offer.Cost) .. " each"
		card.Parent = container

		local function totalCost()
			local total = {}
			for currency, amount in offer.Cost do total[currency] = amount * quantity end
			return total
		end

		local function refresh()
			card.Quantity.Visible = stackable
			card.Quantity.Amount.Text = tostring(quantity)
			card.Quantity.Minus.Active = quantity > 1
			card.Quantity.Minus.BackgroundColor3 = quantity > 1 and T.Rose or T.Soft
			card.Quantity.Plus.Active = quantity < maxAmount
			card.Quantity.Plus.BackgroundColor3 = quantity < maxAmount and T.Mint or T.Soft
			card.Total.Text = "Total: " .. formatCost(totalCost())
			card.Buy.Text = available and (quantity == 1 and "BUY 1" or "BUY " .. quantity) or "Not available yet"
			card.Buy.BackgroundColor3 = available and T.Mint or T.Soft
		end

		card.Quantity.Minus.Activated:Connect(function()
			if quantity > 1 then quantity -= 1; refresh() end
		end)
		card.Quantity.Plus.Activated:Connect(function()
			if quantity < maxAmount then quantity += 1; refresh() end
		end)
		card.Buy.Activated:Connect(function()
			if not available or pending then return end
			for currency, amount in totalCost() do
				if (Constants.Data.Currencies()[currency] or 0) < amount then
					Toast.Show("Not enough " .. currency .. ".")
					return
				end
			end
			pending = true
			Remotes.SendServerEvent("ShopBuy", shopName, itemName, quantity)
			task.delay(0.7, function() pending = false end)
		end)
		refresh()
	end

	Windows.Open("Shop")
end

return Shop
