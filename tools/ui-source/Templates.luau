local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local folder = C.New("Folder", "RPGUITemplates", parent)
	local inv = C.Button(folder, "InvTemplate", "", nil, UDim2.fromOffset(88, 100), T.Surface)
	inv.UIStroke.Thickness = 3
	inv.Rotation = -1.5
	C.Image(inv, "Icon", UDim2.new(0.5, -30, 0, 4), UDim2.fromOffset(60, 60))
	C.Label(inv, "ItemName", "Item", UDim2.fromOffset(4, 62), UDim2.new(1, -8, 0, 34), true).TextSize = 11
	local amount = C.Label(inv, "Amount", "1", UDim2.new(1, -36, 0, 2), UDim2.fromOffset(32, 22), true)
	amount.TextXAlignment = Enum.TextXAlignment.Right
	local equipped = C.Image(inv, "EquippedLabel", UDim2.fromOffset(4, 4), UDim2.fromOffset(20, 20))
	equipped.Visible = false
	equipped.BackgroundTransparency = 0
	equipped.BackgroundColor3 = T.Mint
	C.Round(equipped, 10)
	C.Label(equipped, "Mark", "E", UDim2.fromOffset(4, 0), UDim2.fromScale(1, 1), true).TextSize = 12
	C.Label(inv, "ItemLevel", "Lv. 1", UDim2.fromOffset(4, 3), UDim2.fromOffset(40, 16), true).TextSize = 10
	local rarity = C.Image(inv, "RarityTag", UDim2.new(0, 5, 1, -4), UDim2.new(1, -10, 0, 3))
	rarity.BackgroundTransparency = 0
	C.Round(rarity, 2)

	local buff = C.Image(folder, "BuffTemplate", UDim2.new(), UDim2.fromOffset(38, 38))
	buff.Visible = false
	buff.BackgroundTransparency = 0
	buff.BackgroundColor3 = T.Paper
	C.Round(buff, 8)
	C.Label(buff, "CD", "", UDim2.new(0, 0, 1, -16), UDim2.new(1, 0, 0, 16), true).TextSize = 11

	local skill = C.Card(folder, "SkillTemplate", 208)
	skill.Visible = false
	C.Image(skill, "Icon", UDim2.fromOffset(12, 12), UDim2.fromOffset(40, 40))
	C.Label(skill, "SkillName", "Skill", UDim2.fromOffset(64, 10), UDim2.new(1, -76, 0, 25), true)
	C.Label(skill, "Req", "Level 1", UDim2.fromOffset(64, 35), UDim2.new(1, -76, 0, 22)).TextSize = 12
	C.Label(skill, "Desc", "", UDim2.fromOffset(12, 60), UDim2.new(1, -24, 0, 72))
	for index, key in { "Q", "E", "R" } do
		C.Button(skill, "Slot" .. index, "Slot " .. key, UDim2.new((index - 1) / 3, 8, 0, 146), UDim2.new(1 / 3, -16, 0, 48), index == 1 and T.Mint or T.Sky)
	end

	local zone = C.Button(folder, "ZoneTemplate", "", nil, UDim2.fromOffset(230, 160), T.Surface)
	local area = C.Label(zone, "AreaName", "Zone", UDim2.fromOffset(12, 10), UDim2.new(1, -24, 0, 48), true)
	C.New("UIGradient", "UIGradient", area)
	C.Label(zone, "LevelReq", "Lv. 1", UDim2.fromOffset(12, 58), UDim2.new(1, -24, 0, 25)).TextSize = 12
	local enter = C.Label(zone, "Status", "Explore →", UDim2.fromOffset(12, 108), UDim2.new(1, -24, 0, 36), true)
	enter.TextColor3 = T.Green
	zone.UIStroke.Thickness = 3

	local raid = C.New("ImageButton", "RaidTemplate", folder, { Size = UDim2.new(1, -8, 0, 176), Image = "", BackgroundColor3 = T.Sky, ScaleType = Enum.ScaleType.Crop })
	C.Round(raid)
	C.Stroke(raid, T.Blue)
	C.Gradient(raid)
	raid:SetAttribute("HoverButton", true)
	local stand = C.Frame(raid, "Stand", UDim2.new(0, 0, 1, -60), UDim2.new(1, 0, 0, 60), T.Paper)
	C.Label(stand, "Raid", "Raid", UDim2.fromOffset(8, 4), UDim2.new(1, -16, 0, 28), true)
	C.Label(stand, "Req", "Lv. 1", UDim2.fromOffset(8, 32), UDim2.new(1, -16, 0, 22)).TextSize = 12
	local loot = C.New("ImageButton", "RaidLootTemplate", folder, { Size = UDim2.fromOffset(72, 84), Image = "", BackgroundColor3 = T.Surface, ScaleType = Enum.ScaleType.Fit })
	C.Round(loot)
	C.Stroke(loot)
	C.Gradient(loot)
	loot:SetAttribute("HoverButton", true)
	C.Image(loot, "ImageLabel", UDim2.new(0, 0, 1, -4), UDim2.new(1, 0, 0, 4)).BackgroundTransparency = 0
	C.Label(loot, "rate", "0%", UDim2.new(0, 4, 1, -22), UDim2.new(1, -8, 0, 20), true).TextSize = 12
	local toggled = C.Label(loot, "toggled", "DELETE", UDim2.new(), UDim2.new(1, 0, 0, 24), true)
	toggled.TextColor3 = T.Red
	toggled.Visible = false
	toggled.TextSize = 11

	local party = C.Card(folder, "PartyEntry", 56)
	C.Label(party, "User", "Adventurer", UDim2.fromOffset(12, 4), UDim2.new(1, -100, 1, -8), true)
	C.Button(party, "Kick", "Remove", UDim2.new(1, -88, 0, 4), UDim2.fromOffset(80, 48), T.Rose)
	local invite = C.Round(C.Frame(folder, "PartyInvite", UDim2.new(0.5, 0, 0, 12), UDim2.new(1, -24, 0, 154), T.Paper), 14)
	invite.AnchorPoint = Vector2.new(0.5, 0)
	C.New("UISizeConstraint", "Bounds", invite, { MaxSize = Vector2.new(430, 154) })
	C.Stroke(invite)
	C.Label(invite, "TextLabel", "Party invitation", UDim2.fromOffset(16, 12), UDim2.new(1, -32, 0, 68), true)
	C.Button(invite, "YES", "Join party", UDim2.new(0, 12, 1, -60), UDim2.new(0.5, -18, 0, 48))
	C.Button(invite, "NO", "Decline", UDim2.new(0.5, 6, 1, -60), UDim2.new(0.5, -18, 0, 48), T.Soft)

	local player = C.Card(folder, "ListTemplate", 64)
	local info = C.Frame(player, "Info", UDim2.fromOffset(12, 4), UDim2.new(1, -104, 0, 30))
	C.Label(info, "User", "Adventurer", nil, nil, true)
	local stats = C.Frame(player, "Stats", UDim2.fromOffset(12, 32), UDim2.new(1, -104, 0, 24))
	C.Label(stats, "Level", "Lv. 1").TextSize = 12
	C.Button(player, "View", "View", UDim2.new(1, -88, 0, 8), UDim2.fromOffset(80, 48), T.Sky)
	C.Image(player, "Icon", UDim2.new(1, -124, 0, 22), UDim2.fromOffset(24, 24))

	local mob = require(script.Parent.MobOverhead)(folder)
	local damage = C.New("BillboardGui", "Damage", folder, { Size = UDim2.fromOffset(140, 70), AlwaysOnTop = true })
	for _, name in { "Base", "Crit", "Heal" } do
		local frame = C.Frame(damage, name)
		local label = C.Label(frame, "Amount", "", UDim2.fromScale(0.5, 0.5), UDim2.fromScale(1, 1), true)
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.TextSize = name == "Crit" and 30 or 24
		label.TextColor3 = name == "Heal" and T.Mint or name == "Crit" and T.Sand or T.Ink
		C.New("UIStroke", "UIStroke", label, { Color = T.Ink, Thickness = 2 })
	end

	local shop = C.Round(C.Frame(folder, "ShopTemplate", UDim2.new(), UDim2.fromScale(1, 0.4), Color3.fromRGB(38, 40, 50)), 18)
	shop.ClipsDescendants = true
	C.Stroke(shop, Color3.fromRGB(18, 20, 27)).Thickness = 3

	local shopAccent = C.Frame(shop, "Accent", UDim2.new(), UDim2.fromScale(0.012, 1), T.Mint)
	shopAccent.ZIndex = 2

	local iconPanel = C.Round(C.Frame(shop, "IconPanel", UDim2.fromScale(0.03, 0.1), UDim2.fromScale(0.205, 0.8), Color3.fromRGB(25, 27, 35)), 16)
	C.Stroke(iconPanel, T.Soft).Thickness = 2
	local iconGlow = C.Round(C.Frame(iconPanel, "Glow", UDim2.fromScale(0.15, 0.15), UDim2.fromScale(0.7, 0.7), T.Soft), 100)
	iconGlow.BackgroundTransparency = 0.45
	local iconPlaceholder = C.Label(iconPanel, "Placeholder", "?", UDim2.fromScale(0.25, 0.2), UDim2.fromScale(0.5, 0.6), true)
	iconPlaceholder.TextColor3 = T.Muted
	iconPlaceholder.TextStrokeTransparency = 1
	iconPlaceholder.TextXAlignment = Enum.TextXAlignment.Center
	iconPlaceholder.TextSize = 30
	local shopIcon = C.New("ImageLabel", "Icon", iconPanel, {
		Position = UDim2.fromScale(0.1, 0.1),
		Size = UDim2.fromScale(0.8, 0.8),
		BackgroundTransparency = 1,
		Image = "",
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 3,
	})

	local shopCategory = C.Round(C.Label(shop, "Category", "POTION", UDim2.fromScale(0.26, 0.1), UDim2.fromScale(0.125, 0.12), true), 7)
	shopCategory.BackgroundTransparency = 0
	shopCategory.BackgroundColor3 = T.Soft
	shopCategory.TextColor3 = T.Muted
	shopCategory.TextStrokeTransparency = 1
	shopCategory.TextXAlignment = Enum.TextXAlignment.Center
	shopCategory.TextSize = 10

	local shopRarity = C.Round(C.Label(shop, "Rarity", "COMMON", UDim2.fromScale(0.395, 0.1), UDim2.fromScale(0.125, 0.12), true), 7)
	shopRarity.BackgroundTransparency = 0
	shopRarity.BackgroundColor3 = T.Rarities.Common
	shopRarity.TextStrokeTransparency = 1
	shopRarity.TextXAlignment = Enum.TextXAlignment.Center
	shopRarity.TextSize = 10

	local shopName = C.Label(shop, "Name", "Item", UDim2.fromScale(0.26, 0.25), UDim2.fromScale(0.425, 0.18), true)
	shopName.TextSize = 22
	shopName.TextWrapped = false
	shopName.TextTruncate = Enum.TextTruncate.AtEnd
	C.New("UITextSizeConstraint", "TextBounds", shopName, { MinTextSize = 13, MaxTextSize = 22 })

	local shopDescription = C.Label(shop, "Description", "Item description.", UDim2.fromScale(0.26, 0.47), UDim2.fromScale(0.425, 0.4))
	shopDescription.TextColor3 = T.Muted
	shopDescription.TextSize = 13
	shopDescription.TextYAlignment = Enum.TextYAlignment.Top
	shopDescription.TextTruncate = Enum.TextTruncate.AtEnd
	C.New("UITextSizeConstraint", "TextBounds", shopDescription, { MinTextSize = 10, MaxTextSize = 14 })

	local shopDivider = C.Frame(shop, "Divider", UDim2.fromScale(0.705, 0.12), UDim2.fromScale(0.0025, 0.76), T.Soft)
	shopDivider.BackgroundTransparency = 0.25

	local purchase = C.Round(C.Frame(shop, "Purchase", UDim2.fromScale(0.725, 0.08), UDim2.fromScale(0.25, 0.84), Color3.fromRGB(48, 51, 63)), 14)
	C.Stroke(purchase, T.Soft).Thickness = 2
	local unitLabel = C.Label(purchase, "UnitLabel", "PRICE / ITEM", UDim2.fromScale(0.08, 0.06), UDim2.fromScale(0.84, 0.11), true)
	unitLabel.TextColor3 = T.Muted
	unitLabel.TextStrokeTransparency = 1
	unitLabel.TextSize = 9
	unitLabel.TextWrapped = false
	local shopPrice = C.Label(purchase, "Price", "0 Gold", UDim2.fromScale(0.08, 0.16), UDim2.fromScale(0.84, 0.16), true)
	shopPrice.TextColor3 = T.Gold
	shopPrice.TextSize = 17
	shopPrice.TextWrapped = false
	shopPrice.TextTruncate = Enum.TextTruncate.AtEnd
	C.New("UITextSizeConstraint", "TextBounds", shopPrice, { MinTextSize = 10, MaxTextSize = 17 })

	local quantity = C.Round(C.Frame(purchase, "Quantity", UDim2.fromScale(0.08, 0.36), UDim2.fromScale(0.84, 0.2), T.Paper), 9)
	C.Stroke(quantity, T.Line).Thickness = 2
	local minus = C.Button(quantity, "Minus", "-", UDim2.fromScale(0.025, 0.12), UDim2.fromScale(0.25, 0.76), T.Rose)
	minus.TextSize = 18
	local amount = C.Label(quantity, "Amount", "1", UDim2.fromScale(0.3, 0.12), UDim2.fromScale(0.4, 0.76), true)
	amount.TextXAlignment = Enum.TextXAlignment.Center
	amount.TextSize = 16
	local plus = C.Button(quantity, "Plus", "+", UDim2.fromScale(0.725, 0.12), UDim2.fromScale(0.25, 0.76), T.Mint)
	plus.TextSize = 18
	local shopTotal = C.Label(purchase, "Total", "TOTAL  0 GOLD", UDim2.fromScale(0.08, 0.59), UDim2.fromScale(0.84, 0.11), true)
	shopTotal.TextColor3 = T.Muted
	shopTotal.TextSize = 10
	shopTotal.TextWrapped = false
	shopTotal.TextTruncate = Enum.TextTruncate.AtEnd
	local shopBuy = C.Button(purchase, "Buy", "BUY 1", UDim2.fromScale(0.08, 0.73), UDim2.fromScale(0.84, 0.2), T.Mint)
	shopBuy.TextSize = 14
	local quest = C.Card(folder, "QuestTemplate", 260)
	C.Label(quest, "QuestName", "", UDim2.fromOffset(12, 8), UDim2.new(1, -24, 0, 28), true)
	C.Label(quest, "Description", "", UDim2.fromOffset(12, 42), UDim2.new(1, -24, 0, 64))
	local objective = C.Label(quest, "ObjectiveTemplate", "", UDim2.fromOffset(12, 110), UDim2.new(1, -24, 0, 26))
	objective.TextColor3 = T.Green
	objective.Visible = false
	C.Button(quest, "Abandon", "ABANDON QUEST", UDim2.new(0, 12, 1, -60), UDim2.new(1, -24, 0, 48), T.Rose)
	local toast = require(script.Parent.ToastTemplate)(folder)
	require(script.Parent.FeedbackTemplates)(folder)
	require(script.Parent.NPCInteractionTemplate)(folder)
	C.Label(folder, "EmptyTemplate", "", nil, UDim2.new(1, -8, 0, 120)).TextColor3 = T.Muted
	C.Button(folder, "DialogueChoiceTemplate", "Continue", nil, UDim2.new(1, -8, 0, 52), T.Sky)
	C.Button(folder, "AdminItemTemplate", "Item", nil, UDim2.new(1, -8, 0, 48), T.Soft)
	return folder
end
