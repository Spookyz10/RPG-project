local C = require(script.Parent.Parent.ScaleComponents)
local T = require(script.Parent.Parent.Theme)

return function()
	local templates = game:GetService("ReplicatedStorage"):FindFirstChild("RPGUITemplates")
	assert(templates, "Generate RPGUITemplates before upgrading the shop template.")
	local card = templates:FindFirstChild("ShopTemplate")
	assert(card and card:IsA("GuiObject"), "RPGUITemplates.ShopTemplate must be a GuiObject.")
	card.Size = UDim2.new(1, -8, 0, 206)
	local oldBuy = card:FindFirstChild("Buy")
	assert(oldBuy and oldBuy:IsA("TextButton"), "ShopTemplate.Buy must be a TextButton.")
	oldBuy.Position = UDim2.fromScale(0.06, 0.82)
	oldBuy.Size = UDim2.fromScale(0.88, 0.15)
	local oldQuantity = card:FindFirstChild("Quantity")
	if oldQuantity then oldQuantity:Destroy() end
	local oldTotal = card:FindFirstChild("Total")
	if oldTotal then oldTotal:Destroy() end
	local quantity = C.Round(C.Frame(card, "Quantity", UDim2.fromScale(0.06, 0.47), UDim2.fromScale(0.88, 0.2), T.Soft), 8)
	C.Stroke(quantity)
	C.Button(quantity, "Minus", "-", UDim2.fromScale(0.02, 0.12), UDim2.fromScale(0.2, 0.76), T.Rose)
	local amount = C.Label(quantity, "Amount", "1", UDim2.fromScale(0.26, 0.12), UDim2.fromScale(0.48, 0.76), true)
	amount.TextXAlignment = Enum.TextXAlignment.Center
	C.Button(quantity, "Plus", "+", UDim2.fromScale(0.78, 0.12), UDim2.fromScale(0.2, 0.76), T.Mint)
	C.Label(card, "Total", "Total: 0 Gold", UDim2.fromScale(0.07, 0.7), UDim2.fromScale(0.86, 0.1)).TextColor3 = T.Muted
end
