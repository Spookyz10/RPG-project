local C = require(script.Parent.Parent.ScaleComponents)
local T = require(script.Parent.Parent.Theme)

return function()
	local templates = game:GetService("ReplicatedStorage"):FindFirstChild("RPGUITemplates")
	assert(templates, "Generate RPGUITemplates before upgrading the shop template.")
	local oldCard = templates:FindFirstChild("ShopTemplate")
	assert(oldCard and oldCard:IsA("GuiObject"), "RPGUITemplates.ShopTemplate must be a GuiObject.")
	local card = C.Frame(nil, "ShopTemplate", UDim2.new(), UDim2.fromScale(1, 0.4), Color3.fromRGB(38, 40, 50))
	card.ClipsDescendants = true
	C.Round(card, 18)
	C.Stroke(card, Color3.fromRGB(18, 20, 27)).Thickness = 3

	local accent = C.Frame(card, "Accent", UDim2.new(), UDim2.fromScale(0.012, 1), T.Mint)
	accent.ZIndex = 2

	local iconPanel = C.Round(C.Frame(card, "IconPanel", UDim2.fromScale(0.03, 0.1), UDim2.fromScale(0.205, 0.8), Color3.fromRGB(25, 27, 35)), 16)
	C.Stroke(iconPanel, T.Soft).Thickness = 2
	local iconGlow = C.Round(C.Frame(iconPanel, "Glow", UDim2.fromScale(0.15, 0.15), UDim2.fromScale(0.7, 0.7), T.Soft), 100)
	iconGlow.BackgroundTransparency = 0.45
	local placeholder = C.Label(iconPanel, "Placeholder", "?", UDim2.fromScale(0.25, 0.2), UDim2.fromScale(0.5, 0.6), true)
	placeholder.TextColor3 = T.Muted
	placeholder.TextStrokeTransparency = 1
	placeholder.TextXAlignment = Enum.TextXAlignment.Center
	placeholder.TextSize = 30
	local icon = C.New("ImageLabel", "Icon", iconPanel, {
		Position = UDim2.fromScale(0.1, 0.1),
		Size = UDim2.fromScale(0.8, 0.8),
		BackgroundTransparency = 1,
		Image = "",
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 3,
	})

	local category = C.Round(C.Label(card, "Category", "POTION", UDim2.fromScale(0.26, 0.1), UDim2.fromScale(0.125, 0.12), true), 7)
	category.BackgroundTransparency = 0
	category.BackgroundColor3 = T.Soft
	category.TextColor3 = T.Muted
	category.TextStrokeTransparency = 1
	category.TextXAlignment = Enum.TextXAlignment.Center
	category.TextSize = 10

	local rarity = C.Round(C.Label(card, "Rarity", "COMMON", UDim2.fromScale(0.395, 0.1), UDim2.fromScale(0.125, 0.12), true), 7)
	rarity.BackgroundTransparency = 0
	rarity.BackgroundColor3 = T.Rarities.Common
	rarity.TextColor3 = T.Ink
	rarity.TextStrokeTransparency = 1
	rarity.TextXAlignment = Enum.TextXAlignment.Center
	rarity.TextSize = 10

	local name = C.Label(card, "Name", "Item", UDim2.fromScale(0.26, 0.25), UDim2.fromScale(0.425, 0.18), true)
	name.TextSize = 22
	name.TextWrapped = false
	name.TextTruncate = Enum.TextTruncate.AtEnd
	C.New("UITextSizeConstraint", "TextBounds", name, { MinTextSize = 13, MaxTextSize = 22 })

	local description = C.Label(card, "Description", "Item description.", UDim2.fromScale(0.26, 0.47), UDim2.fromScale(0.425, 0.4))
	description.TextColor3 = T.Muted
	description.TextSize = 13
	description.TextYAlignment = Enum.TextYAlignment.Top
	description.TextWrapped = true
	description.TextTruncate = Enum.TextTruncate.AtEnd
	C.New("UITextSizeConstraint", "TextBounds", description, { MinTextSize = 10, MaxTextSize = 14 })

	local divider = C.Frame(card, "Divider", UDim2.fromScale(0.705, 0.12), UDim2.fromScale(0.0025, 0.76), T.Soft)
	divider.BackgroundTransparency = 0.25

	local purchase = C.Round(C.Frame(card, "Purchase", UDim2.fromScale(0.725, 0.08), UDim2.fromScale(0.25, 0.84), Color3.fromRGB(48, 51, 63)), 14)
	C.Stroke(purchase, T.Soft).Thickness = 2

	local unitLabel = C.Label(purchase, "UnitLabel", "PRICE / ITEM", UDim2.fromScale(0.08, 0.06), UDim2.fromScale(0.84, 0.11), true)
	unitLabel.TextColor3 = T.Muted
	unitLabel.TextStrokeTransparency = 1
	unitLabel.TextSize = 9
	unitLabel.TextWrapped = false

	local price = C.Label(purchase, "Price", "0 Gold", UDim2.fromScale(0.08, 0.16), UDim2.fromScale(0.84, 0.16), true)
	price.TextColor3 = T.Gold
	price.TextSize = 17
	price.TextWrapped = false
	price.TextTruncate = Enum.TextTruncate.AtEnd
	C.New("UITextSizeConstraint", "TextBounds", price, { MinTextSize = 10, MaxTextSize = 17 })

	local quantity = C.Round(C.Frame(purchase, "Quantity", UDim2.fromScale(0.08, 0.36), UDim2.fromScale(0.84, 0.2), T.Paper), 9)
	C.Stroke(quantity, T.Line).Thickness = 2
	local minus = C.Button(quantity, "Minus", "-", UDim2.fromScale(0.025, 0.12), UDim2.fromScale(0.25, 0.76), T.Rose)
	minus.TextSize = 18
	local amount = C.Label(quantity, "Amount", "1", UDim2.fromScale(0.3, 0.12), UDim2.fromScale(0.4, 0.76), true)
	amount.TextXAlignment = Enum.TextXAlignment.Center
	amount.TextSize = 16
	local plus = C.Button(quantity, "Plus", "+", UDim2.fromScale(0.725, 0.12), UDim2.fromScale(0.25, 0.76), T.Mint)
	plus.TextSize = 18

	local total = C.Label(purchase, "Total", "TOTAL  0 GOLD", UDim2.fromScale(0.08, 0.59), UDim2.fromScale(0.84, 0.11), true)
	total.TextColor3 = T.Muted
	total.TextSize = 10
	total.TextWrapped = false
	total.TextTruncate = Enum.TextTruncate.AtEnd

	local buy = C.Button(purchase, "Buy", "BUY 1", UDim2.fromScale(0.08, 0.73), UDim2.fromScale(0.84, 0.2), T.Mint)
	buy.TextSize = 14

	local serverStorage = game:GetService("ServerStorage")
	local backups = serverStorage:FindFirstChild("RPGUIBackups")
	if not backups then
		backups = Instance.new("Folder")
		backups.Name = "RPGUIBackups"
		backups.Parent = serverStorage
	end
	local backup = Instance.new("Folder")
	backup.Name = "ShopTemplate_" .. os.date("%Y-%m-%d_%H-%M-%S")
	backup.Parent = backups
	oldCard.Parent = backup
	card.Parent = templates

	return card
end
