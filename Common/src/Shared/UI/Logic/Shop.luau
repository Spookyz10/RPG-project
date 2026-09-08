local UI = script.Parent.Parent
local Constants = require(UI.UIConstants)
local Templates = require(UI.Bootstrap).GetTemplates()
local T = require(UI.Theme)
local Shops = require(UI.Parent.Shops)
local Items = require(UI.Parent.ItemsData)
local Windows = require(UI.WindowManager)
local Toast = require(UI.Toast)
local Remotes = require(UI.Parent.Utils.RemoteManager)
local Shop = {}

function Shop.Open(shopName)
	local definition = Shops[shopName]
	if not definition then Toast.Show("This shop is not available yet."); return end
	local root = Constants.PlayerGui.Shop.Main
	local container = root.Body.Content.Container
	for _, child in container:GetChildren() do
		if child:IsA("GuiObject") then child:Destroy() end
	end
	root.Heading.Text = shopName:gsub("Shop$", "") .. "'s shop"
	local count = 0
	for itemName, offer in definition do
		count += 1
		local card = Templates.ShopTemplate:Clone()
		card.Name = itemName
		card:FindFirstChild("Name").Text = itemName
		card.Parent = container
		local cost = {}
		for currency, amount in offer.Cost do table.insert(cost, tostring(amount) .. " " .. currency) end
		table.sort(cost)
		card.Price.Text = table.concat(cost, " · ")
		-- The current skill shop lists skills that do not exist and has no unlock service.
		-- Keep these visible as unavailable instead of sending a purchase that could charge players.
		local available = offer.itemType ~= "Skill" and Items[itemName] ~= nil
		local buy = card.Buy
		buy.Text = available and "BUY ONE" or "Not available yet"
		buy.BackgroundColor3 = available and T.Mint or T.Soft
		local pending = false
		buy.Activated:Connect(function()
			if not available or pending then return end
			for currency, amount in offer.Cost do
				if (Constants.Data.Currencies()[currency] or 0) < amount then Toast.Show("Not enough " .. currency .. "."); return end
			end
			pending = true
			Remotes.SendServerEvent("ShopBuy", shopName, itemName)
			task.delay(0.7, function() pending = false end)
		end)
	end
	if count == 0 then
		local empty = Templates.EmptyTemplate:Clone()
		empty.Text = "Nothing for sale here yet."
		empty.Parent = container
	end
	Windows.Open("Shop")
end

return Shop
