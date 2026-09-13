local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

local function itemTemplate(parent)
	local item = C.Button(parent, "ItemTemplate", "", UDim2.fromScale(0, 0), UDim2.fromScale(0.31, 0.42), T.Surface)
	item.Visible = false
	item.Text = ""
	C.Image(item, "Icon", UDim2.fromScale(0.08, 0.08), UDim2.fromScale(0.84, 0.55))
	local name = C.Label(item, "ItemName", "Item", UDim2.fromScale(0.05, 0.64), UDim2.fromScale(0.9, 0.19), true)
	name.TextSize = 10
	name.TextXAlignment = Enum.TextXAlignment.Center
	local amount = C.Label(item, "Amount", "x1", UDim2.fromScale(0.57, 0.05), UDim2.fromScale(0.36, 0.18), true)
	amount.TextSize = 9
	amount.TextXAlignment = Enum.TextXAlignment.Right
	local source = C.Label(item, "Source", "BAG", UDim2.fromScale(0.05, 0.84), UDim2.fromScale(0.9, 0.12), true)
	source.TextSize = 7
	source.TextColor3 = T.Muted
	source.TextXAlignment = Enum.TextXAlignment.Center
	local selected = C.Round(C.Frame(item, "Selection", UDim2.fromScale(0.02, 0.02), UDim2.fromScale(0.96, 0.96), T.Green), 8)
	selected.BackgroundTransparency = 0.78
	selected.Visible = false
	selected.ZIndex = 5
	return item
end

local function offerItemTemplate(parent)
	local item = C.Button(parent, "OfferItemTemplate", "", UDim2.fromScale(0, 0), UDim2.fromOffset(420, 44), T.Soft)
	item.Visible = false
	item.Text = ""
	C.Image(item, "Icon", UDim2.fromScale(0.025, 0.12), UDim2.fromScale(0.14, 0.76))
	local name = C.Label(item, "ItemName", "Item", UDim2.fromScale(0.18, 0.06), UDim2.fromScale(0.48, 0.45), true)
	name.TextSize = 10
	name.TextTruncate = Enum.TextTruncate.AtEnd
	local amount = C.Label(item, "Amount", "x1", UDim2.fromScale(0.68, 0.06), UDim2.fromScale(0.28, 0.42), true)
	amount.TextSize = 10
	amount.TextXAlignment = Enum.TextXAlignment.Right
	local source = C.Label(item, "Source", "BACKPACK", UDim2.fromScale(0.18, 0.53), UDim2.fromScale(0.45, 0.34), true)
	source.TextSize = 7
	source.TextColor3 = T.Muted
	local action = C.Label(item, "Action", "REMOVE", UDim2.fromScale(0.68, 0.53), UDim2.fromScale(0.28, 0.34), true)
	action.TextSize = 7
	action.TextColor3 = T.Red
	action.TextXAlignment = Enum.TextXAlignment.Right
	return item
end

local function sidePanel(parent, name, title, position)
	local panel = C.Round(C.Frame(parent, name, position, UDim2.fromScale(0.475, 0.49), T.Surface), 10)
	C.Stroke(panel)
	local heading = C.Label(panel, "Heading", title, UDim2.fromScale(0.035, 0.025), UDim2.fromScale(0.93, 0.07), true)
	heading.TextColor3 = name == "Mine" and T.Green or T.Gold
	heading.TextXAlignment = Enum.TextXAlignment.Center
	local balance = C.Label(panel, "Balance", "0 GOLD AVAILABLE", UDim2.fromScale(0.04, 0.1), UDim2.fromScale(0.92, 0.05), true)
	balance.TextColor3 = T.Gold
	balance.TextSize = 9
	balance.TextXAlignment = Enum.TextXAlignment.Center
	local tabs = C.Frame(panel, "Tabs", UDim2.fromScale(0.035, 0.17), UDim2.fromScale(0.93, 0.09))
	C.Button(tabs, "Inventory", "BACKPACK", UDim2.fromScale(0, 0), UDim2.fromScale(0.49, 1), T.Sky)
	C.Button(tabs, "Storage", "STORAGE", UDim2.fromScale(0.51, 0), UDim2.fromScale(0.49, 1), T.Soft)

	local goldLabel = C.Label(panel, "GoldLabel", name == "Mine" and "GOLD YOU GIVE" or "GOLD YOU REQUEST", UDim2.fromScale(0.04, 0.285), UDim2.fromScale(0.48, 0.065), true)
	goldLabel.TextColor3 = T.Gold
	goldLabel.TextSize = 10
	local gold = C.Input(panel, "Gold", "0", UDim2.fromScale(0.53, 0.28), UDim2.fromScale(0.43, 0.08))
	gold.Text = "0"
	gold.TextXAlignment = Enum.TextXAlignment.Center

	local items = C.New("ScrollingFrame", "Items", panel, {
		Position = UDim2.fromScale(0.035, 0.39),
		Size = UDim2.fromScale(0.93, 0.56),
		BackgroundTransparency = 1,
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = name == "Mine" and T.Green or T.Gold,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	})
	C.New("UIPadding", "Padding", items, {
		PaddingTop = UDim.new(0.012, 0),
		PaddingLeft = UDim.new(0.012, 0),
		PaddingRight = UDim.new(0.012, 0),
		PaddingBottom = UDim.new(0.012, 0),
	})
	C.New("UIGridLayout", "Grid", items, {
		CellSize = UDim2.fromScale(0.31, 0.42),
		CellPadding = UDim2.fromScale(0.025, 0.025),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	local empty = C.Label(panel, "Empty", "No tradable items here.", UDim2.fromScale(0.08, 0.62), UDim2.fromScale(0.84, 0.12))
	empty.TextColor3 = T.Muted
	empty.TextXAlignment = Enum.TextXAlignment.Center
	return panel
end

local function offerColumn(parent, name, title, position, color)
	local panel = C.Round(C.Frame(parent, name, position, UDim2.fromScale(0.465, 0.76), T.Paper), 8)
	C.Stroke(panel, color).Thickness = 2
	local heading = C.Label(panel, "Heading", title, UDim2.fromScale(0.04, 0.035), UDim2.fromScale(0.64, 0.16), true)
	heading.TextColor3 = color
	local count = C.Label(panel, "Count", "0 ITEMS", UDim2.fromScale(0.69, 0.04), UDim2.fromScale(0.27, 0.15), true)
	count.TextColor3 = T.Muted
	count.TextSize = 8
	count.TextXAlignment = Enum.TextXAlignment.Right
	local gold = C.Label(panel, "Gold", "0 GOLD", UDim2.fromScale(0.04, 0.2), UDim2.fromScale(0.92, 0.12), true)
	gold.TextColor3 = T.Gold
	gold.TextSize = 9
	local items = C.New("ScrollingFrame", "Items", panel, {
		Position = UDim2.fromScale(0.03, 0.35),
		Size = UDim2.fromScale(0.94, 0.61),
		BackgroundTransparency = 1,
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = color,
	})
	C.New("UIPadding", "Padding", items, {
		PaddingTop = UDim.new(0.015, 0),
		PaddingLeft = UDim.new(0, 0),
		PaddingRight = UDim.new(0.02, 0),
		PaddingBottom = UDim.new(0.015, 0),
	})
	C.New("UIListLayout", "List", items, {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0.025, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	local empty = C.Label(panel, "Empty", "No items selected.", UDim2.fromScale(0.08, 0.56), UDim2.fromScale(0.84, 0.18))
	empty.TextColor3 = T.Muted
	empty.TextSize = 9
	empty.TextXAlignment = Enum.TextXAlignment.Center
	return panel
end

local function offerSummary(parent)
	local offer = C.Round(C.Frame(parent, "OfferSummary", UDim2.fromScale(0, 0.51), UDim2.fromScale(1, 0.35), T.Surface), 10)
	C.Stroke(offer)
	local heading = C.Label(offer, "Heading", "CURRENT OFFER", UDim2.fromScale(0.03, 0.02), UDim2.fromScale(0.45, 0.12), true)
	heading.TextColor3 = T.Gold
	local hint = C.Label(offer, "Hint", "Tap an item here to remove it.", UDim2.fromScale(0.5, 0.025), UDim2.fromScale(0.47, 0.1))
	hint.TextColor3 = T.Muted
	hint.TextSize = 9
	hint.TextXAlignment = Enum.TextXAlignment.Right
	offerColumn(offer, "Give", "YOU GIVE", UDim2.fromScale(0.025, 0.18), T.Green)
	offerColumn(offer, "Receive", "YOU RECEIVE", UDim2.fromScale(0.51, 0.18), T.Gold)
	return offer
end

local function summaryPanel(parent, name, title, position, color)
	local panel = C.Round(C.Frame(parent, name, position, UDim2.fromScale(0.47, 0.55), T.Surface), 9)
	C.Stroke(panel, color).Thickness = 2
	local heading = C.Label(panel, "Heading", title, UDim2.fromScale(0.04, 0.04), UDim2.fromScale(0.92, 0.13), true)
	heading.TextColor3 = color
	heading.TextXAlignment = Enum.TextXAlignment.Center
	local text = C.Label(panel, "Summary", "Nothing", UDim2.fromScale(0.05, 0.2), UDim2.fromScale(0.9, 0.75))
	text.TextYAlignment = Enum.TextYAlignment.Top
	text.TextSize = 12
	return panel
end

return function(parent)
	local screen = C.Screen(parent, "Trading", 65)
	local root = C.Round(C.Frame(screen, "Main", UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.9, 0.9), T.Paper), 16)
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Visible = false
	root.Active = true
	root:SetAttribute("Window", true)
	C.Stroke(root)
	C.New("UISizeConstraint", "Bounds", root, { MaxSize = Vector2.new(1120, 700) })
	C.Frame(root, "Accent", UDim2.fromScale(0.025, 0), UDim2.fromScale(0.95, 0.008), T.Gold)
	local heading = C.Label(root, "Heading", "TRADE OFFER", UDim2.fromScale(0.03, 0.02), UDim2.fromScale(0.7, 0.06), true)
	heading.TextColor3 = T.Gold
	heading.TextSize = 26
	local subtitle = C.Label(root, "Subtitle", "Choose what you give and what you want to receive.", UDim2.fromScale(0.03, 0.075), UDim2.fromScale(0.72, 0.04))
	subtitle.TextColor3 = T.Muted
	subtitle.TextSize = 11
	C.Button(root, "Close", "X", UDim2.fromScale(0.93, 0.022), UDim2.fromScale(0.05, 0.065), T.Rose):SetAttribute("CloseWindow", true)

	local composer = C.Frame(root, "Composer", UDim2.fromScale(0.025, 0.13), UDim2.fromScale(0.95, 0.84))
	local mobileTabs = C.Frame(composer, "MobileTabs", UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.085))
	mobileTabs.Visible = false
	C.Button(mobileTabs, "Give", "YOU GIVE", UDim2.fromScale(0, 0), UDim2.fromScale(0.49, 1), T.Green)
	C.Button(mobileTabs, "Receive", "YOU RECEIVE", UDim2.fromScale(0.51, 0), UDim2.fromScale(0.49, 1), T.Soft)
	sidePanel(composer, "Mine", "YOU GIVE", UDim2.fromScale(0, 0))
	sidePanel(composer, "Theirs", "YOU RECEIVE", UDim2.fromScale(0.525, 0))
	offerSummary(composer)
	local target = C.Label(composer, "Target", "Trading with Adventurer", UDim2.fromScale(0.2, 0.865), UDim2.fromScale(0.6, 0.04), true)
	target.TextXAlignment = Enum.TextXAlignment.Center
	target.TextColor3 = T.Muted
	C.Button(composer, "Review", "REVIEW OFFER", UDim2.fromScale(0.32, 0.915), UDim2.fromScale(0.36, 0.075), T.Gold)

	local confirmation = C.Round(C.Frame(root, "Confirmation", UDim2.fromScale(0.18, 0.16), UDim2.fromScale(0.64, 0.7), T.Paper), 14)
	confirmation.Visible = false
	confirmation.Active = true
	confirmation.ZIndex = 20
	C.Stroke(confirmation, T.Gold)
	local confirmTitle = C.Label(confirmation, "Title", "ARE YOU SURE?", UDim2.fromScale(0.06, 0.05), UDim2.fromScale(0.88, 0.1), true)
	confirmTitle.TextColor3 = T.Gold
	confirmTitle.TextXAlignment = Enum.TextXAlignment.Center
	local confirmSummary = C.Label(confirmation, "Summary", "You will receive this and give this.", UDim2.fromScale(0.07, 0.18), UDim2.fromScale(0.86, 0.57))
	confirmSummary.TextYAlignment = Enum.TextYAlignment.Top
	confirmSummary.TextSize = 13
	C.Button(confirmation, "Send", "SEND OFFER", UDim2.fromScale(0.08, 0.82), UDim2.fromScale(0.4, 0.11), T.Mint)
	C.Button(confirmation, "Cancel", "GO BACK", UDim2.fromScale(0.52, 0.82), UDim2.fromScale(0.4, 0.11), T.Soft)

	local quantity = C.Round(C.Frame(root, "Quantity", UDim2.fromScale(0.32, 0.34), UDim2.fromScale(0.36, 0.32), T.Paper), 12)
	quantity.Visible = false
	quantity.Active = true
	quantity.ZIndex = 25
	C.Stroke(quantity, T.Sky)
	local quantityTitle = C.Label(quantity, "Title", "SELECT QUANTITY", UDim2.fromScale(0.06, 0.07), UDim2.fromScale(0.88, 0.17), true)
	quantityTitle.TextColor3 = T.Sky
	quantityTitle.TextXAlignment = Enum.TextXAlignment.Center
	local quantityItem = C.Label(quantity, "Item", "Item", UDim2.fromScale(0.08, 0.26), UDim2.fromScale(0.84, 0.14), true)
	quantityItem.TextXAlignment = Enum.TextXAlignment.Center
	local quantityAmount = C.Input(quantity, "Amount", "1", UDim2.fromScale(0.18, 0.45), UDim2.fromScale(0.64, 0.17))
	quantityAmount.Text = "1"
	quantityAmount.TextXAlignment = Enum.TextXAlignment.Center
	C.Button(quantity, "Add", "ADD", UDim2.fromScale(0.08, 0.72), UDim2.fromScale(0.4, 0.18), T.Mint)
	C.Button(quantity, "Cancel", "CANCEL", UDim2.fromScale(0.52, 0.72), UDim2.fromScale(0.4, 0.18), T.Soft)

	local viewer = C.Frame(root, "Viewer", UDim2.fromScale(0.025, 0.13), UDim2.fromScale(0.95, 0.84))
	viewer.Visible = false
	local sender = C.Round(C.Frame(viewer, "Sender", UDim2.fromScale(0.12, 0), UDim2.fromScale(0.76, 0.2), T.Surface), 10)
	C.Stroke(sender, T.Purple).Thickness = 2
	C.Image(sender, "Avatar", UDim2.fromScale(0.025, 0.08), UDim2.fromScale(0.14, 0.84))
	local senderName = C.Label(sender, "PlayerName", "Adventurer", UDim2.fromScale(0.19, 0.12), UDim2.fromScale(0.76, 0.38), true)
	senderName.TextSize = 20
	local senderLevel = C.Label(sender, "Level", "LEVEL 1", UDim2.fromScale(0.19, 0.53), UDim2.fromScale(0.76, 0.27), true)
	senderLevel.TextColor3 = T.Gold
	summaryPanel(viewer, "Receive", "YOU RECEIVE", UDim2.fromScale(0.01, 0.25), T.Green)
	summaryPanel(viewer, "Give", "YOU GIVE", UDim2.fromScale(0.52, 0.25), T.Rose)
	local expires = C.Label(viewer, "Expires", "Offer expires in 120s", UDim2.fromScale(0.2, 0.82), UDim2.fromScale(0.6, 0.05), true)
	expires.TextXAlignment = Enum.TextXAlignment.Center
	expires.TextColor3 = T.Muted
	C.Button(viewer, "Accept", "ACCEPT TRADE", UDim2.fromScale(0.19, 0.9), UDim2.fromScale(0.29, 0.085), T.Mint)
	C.Button(viewer, "Decline", "DECLINE", UDim2.fromScale(0.52, 0.9), UDim2.fromScale(0.29, 0.085), T.Rose)

	local queue = C.New("ScrollingFrame", "OfferQueue", screen, {
		Position = UDim2.fromScale(0.705, 0.04),
		Size = UDim2.fromScale(0.275, 0.48),
		BackgroundTransparency = 1,
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3,
	})
	C.New("UIListLayout", "List", queue, {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0.025, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	local offer = C.New("CanvasGroup", "OfferTemplate", queue, {
		Size = UDim2.fromScale(1, 0.34),
		BackgroundColor3 = T.Paper,
		Visible = false,
	})
	C.Round(offer, 12)
	C.Stroke(offer, T.Gold).Thickness = 2
	C.New("UIScale", "Pop", offer, { Scale = 1 })
	C.Image(offer, "Avatar", UDim2.fromScale(0.035, 0.1), UDim2.fromScale(0.2, 0.52))
	local offerName = C.Label(offer, "PlayerName", "Adventurer sent a trade", UDim2.fromScale(0.27, 0.08), UDim2.fromScale(0.69, 0.25), true)
	offerName.TextSize = 12
	local offerLevel = C.Label(offer, "Level", "LEVEL 1", UDim2.fromScale(0.27, 0.34), UDim2.fromScale(0.69, 0.18), true)
	offerLevel.TextColor3 = T.Gold
	offerLevel.TextSize = 9
	local offerExpires = C.Label(offer, "Expires", "120s", UDim2.fromScale(0.27, 0.52), UDim2.fromScale(0.69, 0.12))
	offerExpires.TextColor3 = T.Muted
	offerExpires.TextSize = 8
	C.Button(offer, "Ignore", "IGNORE", UDim2.fromScale(0.035, 0.72), UDim2.fromScale(0.44, 0.2), T.Soft)
	C.Button(offer, "View", "VIEW OFFER", UDim2.fromScale(0.525, 0.72), UDim2.fromScale(0.44, 0.2), T.Gold)

	itemTemplate(screen)
	offerItemTemplate(screen)
	return screen
end
