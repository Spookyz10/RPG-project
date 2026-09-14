local UI = script.Parent.Parent
local Constants = require(UI.UIConstants)
local Templates = require(UI.Bootstrap).GetTemplates()
local T = require(UI.Theme)
local Shops = require(UI.Parent.Shops)
local Items = require(UI.Parent.ItemsData)
local UIFunctions = require(UI.UIFunctions)
local Windows = require(UI.WindowManager)
local Toast = require(UI.Toast)
local Remotes = require(UI.Parent.Utils.RemoteManager)
local Abbreviation = require(UI.Parent.Utils.Abbreviation)

local Shop = {}
local chromeBound = false

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

	local screen = Constants.PlayerGui.Shop
	local root = screen.Main
	if not chromeBound then
		chromeBound = true
		root:GetPropertyChangedSignal("Visible"):Connect(function()
			screen.Backdrop.Visible = root.Visible
			screen.Shadow.Visible = root.Visible
		end)
	end
	local container = root.Body.Content.Container
	for _, child in container:GetChildren() do
		if child:IsA("GuiObject") then child:Destroy() end
	end

	root.Heading.Text = shopName == "Shop" and "Village Shop" or shopName
	root.Subtitle.Text = "Choose your supplies and purchase the amount you need."
	local itemNames = {}
	for itemName in definition do table.insert(itemNames, itemName) end
	table.sort(itemNames)
	root.Body.Content.StockCount.Text = tostring(#itemNames) .. (#itemNames == 1 and " ITEM" or " ITEMS")

	for index, itemName in itemNames do
		local offer = definition[itemName]
		local item = Items[itemName]
		local stackable = item and item.Data.Stackable == true
		local maxAmount = stackable and math.max(1, offer.MaxPurchase or 25) or 1
		local quantity = 1
		local available = offer.itemType == "Consumable" and item ~= nil and item.Kind == "Consumable"
		local pending = false

		local card = Templates.ShopTemplate:Clone()
		card.Name = itemName
		card.LayoutOrder = index
		local itemNameLabel = card:FindFirstChild("Name") :: TextLabel
		itemNameLabel.Text = item and item.Data.Name or itemName
		card.Description.Text = item and item.Data.Description or "No description is available for this item."
		card.Category.Text = string.upper(item and (item.Data.SubType or item.Kind) or offer.itemType)
		card.Rarity.Text = string.upper(item and item.Data.Rarity or "Common")
		local rarityColor = T.Rarities[item and item.Data.Rarity or "Common"] or T.Soft
		card.Rarity.BackgroundColor3 = rarityColor
		card.Accent.BackgroundColor3 = rarityColor
		card.IconPanel.Glow.BackgroundColor3 = rarityColor
		local hasIcon = UIFunctions:SetIcon(card.IconPanel.Icon, item and item.Data.Icon)
		card.IconPanel.Placeholder.Visible = not hasIcon

		local purchase = card.Purchase
		purchase.Price.Text = formatCost(offer.Cost)
		card.Parent = container

		local function totalCost()
			local total = {}
			for currency, amount in offer.Cost do total[currency] = amount * quantity end
			return total
		end

		local function refresh()
			purchase.Quantity.Visible = stackable
			purchase.Quantity.Amount.Text = tostring(quantity)
			purchase.Quantity.Minus.Active = quantity > 1 and not pending
			purchase.Quantity.Minus.Selectable = quantity > 1 and not pending
			purchase.Quantity.Minus.BackgroundColor3 = quantity > 1 and not pending and T.Rose or T.Soft
			purchase.Quantity.Plus.Active = quantity < maxAmount and not pending
			purchase.Quantity.Plus.Selectable = quantity < maxAmount and not pending
			purchase.Quantity.Plus.BackgroundColor3 = quantity < maxAmount and not pending and T.Mint or T.Soft
			purchase.Total.Text = "TOTAL  " .. string.upper(formatCost(totalCost()))
			purchase.Buy.Text = pending and "PROCESSING..."
				or available and (quantity == 1 and "BUY 1" or "BUY " .. quantity)
				or "UNAVAILABLE"
			purchase.Buy.Active = available and not pending
			purchase.Buy.Selectable = available and not pending
			purchase.Buy.BackgroundColor3 = available and not pending and T.Mint or T.Soft
		end

		purchase.Quantity.Minus.Activated:Connect(function()
			if quantity > 1 then quantity -= 1; refresh() end
		end)
		purchase.Quantity.Plus.Activated:Connect(function()
			if quantity < maxAmount then quantity += 1; refresh() end
		end)
		purchase.Buy.Activated:Connect(function()
			if not available or pending then return end
			for currency, amount in totalCost() do
				if (Constants.Data.Currencies()[currency] or 0) < amount then
					Toast.Show("Not enough " .. currency .. ".")
					return
				end
			end
			pending = true
			refresh()
			Remotes.SendServerEvent("ShopBuy", shopName, itemName, quantity)
			task.delay(0.7, function()
				pending = false
				if card.Parent then refresh() end
			end)
		end)
		refresh()
	end

	Windows.Open("Shop")
end

return Shop
