local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

local function equipment(parent, name, slots)
	local frame = C.Frame(parent, name, UDim2.fromOffset(6, 44), UDim2.new(1, -12, 0, 238))
	for index, slot in slots do
		local side = (index - 1) % 2
		local row = math.floor((index - 1) / 2)
		local cell = C.Round(C.Frame(frame, slot, UDim2.new(side, side == 0 and 0 or -56, 0, row * 78), UDim2.fromOffset(56, 68), T.Soft), 6)
		C.Stroke(cell)
		local icon = C.Image(cell, "Icon", UDim2.fromOffset(7, 5), UDim2.fromOffset(42, 42))
		local button = C.New("TextButton", "TextButton", icon, { Text = "", BackgroundTransparency = 1, Position = UDim2.fromOffset(-7, -5), Size = UDim2.fromOffset(56, 68) })
		button:SetAttribute("HoverButton", true)
		local label = C.Label(cell, "Label", slot, UDim2.new(0, 0, 1, -19), UDim2.new(1, 0, 0, 17))
		label.TextSize = 10
		label.TextXAlignment = Enum.TextXAlignment.Center
	end
	return frame
end

local function itemDialog(root, name, kind)
	local overlay = C.Round(C.Frame(root, name, UDim2.fromOffset(8, 72), UDim2.new(1, -16, 1, -80), T.Paper), 12)
	overlay.Visible = false
	overlay.Active = true
	overlay.ZIndex = 10
	C.Stroke(overlay)
	local inner = C.Scroll(overlay, "Inner", UDim2.fromOffset(14, 12), UDim2.new(1, -28, 1, -24))
	for index, field in { "ItemName", "ItemLevel", "ItemDamage", "ItemDesc" } do
		local label = C.Label(inner, field, "", UDim2.new(), UDim2.new(1, -12, 0, field == "ItemDesc" and 60 or 26), field == "ItemName")
		label.LayoutOrder = index
	end
	local stats = C.Frame(inner, "Stats", UDim2.new(), UDim2.new(1, -12, 0, 140))
	stats.LayoutOrder = 5
	stats.Visible = kind == "Equipment"
	C.List(stats, false, 2)
	for _, stat in { "ATK", "CRT", "SPD", "DEF", "HP" } do C.Label(stats, stat, stat .. ": 0") end
	for index, entry in { { "Action", kind == "Usable" and "Use one" or "Equip" }, { "Unequip", "Unequip" }, { "Vanity", "Use as appearance" }, { "Use All", "Use all" }, { "Cancel", "Back to backpack" } } do
		local button = C.Button(inner, entry[1], entry[2], UDim2.new(), UDim2.new(1, -12, 0, 48), entry[1] == "Cancel" and T.Soft or T.Mint)
		button.LayoutOrder = index + 5
		button.Visible = entry[1] == "Action" or entry[1] == "Cancel" or (entry[1] == "Vanity" and kind == "Weapon") or (entry[1] == "Use All" and kind == "Usable")
	end
end

local function quantity(root, name)
	local box = C.Input(root, name, "Quantity", UDim2.new(0.5, -130, 0.5, -52), UDim2.fromOffset(260, 52))
	box.ZIndex = 20
	box.Visible = false
	C.Button(box, "TextButton", "Confirm", UDim2.fromOffset(0, 60), UDim2.fromOffset(126, 48))
	C.Button(box, "Cancel", "Cancel", UDim2.fromOffset(134, 60), UDim2.fromOffset(126, 48), T.Rose)
	return box
end

return function(parent)
	local screen, root, body = C.Window(parent, "Inventory", "Main", "INVENTORY", "Your hero. Your gear. Your next upgrade.", 510, 560)
	root.Bounds.MaxSize = Vector2.new(740, 630)
	body:SetAttribute("InventoryLayout", true)
	body:SetAttribute("Breakpoint", 580)
	C.Responsive(body, UDim2.new(), UDim2.new(1, -8, 0, 510), UDim2.new(), UDim2.new(1, -8, 0, 568))
	local tabs = C.Frame(body, "MobileTabs", UDim2.new(), UDim2.new(1, 0, 0, 48))
	tabs.Visible = false
	C.Button(tabs, "Character", "HERO", UDim2.new(), UDim2.new(0.5, -4, 0, 44), T.Purple)
	C.Button(tabs, "Bag", "ITEMS", UDim2.new(0.5, 4, 0, 0), UDim2.new(0.5, -4, 0, 44), T.Sky)
	local hero = C.Frame(body, "Hero", nil, nil, T.Surface)
	C.Round(hero)
	C.Stroke(hero)
	C.Responsive(hero, UDim2.new(), UDim2.new(0.4, -8, 0, 510), UDim2.fromOffset(0, 56), UDim2.new(1, 0, 0, 510))
	hero:SetAttribute("Breakpoint", 580)
	C.Section(hero, "Header", "YOUR HERO", UDim2.fromOffset(6, 6), UDim2.new(1, -12, 0, 28))
	local viewport = C.New("ViewportFrame", "CharacterPreview", hero, {
		Position = UDim2.fromOffset(60, 44), Size = UDim2.new(1, -120, 0, 240),
		BackgroundTransparency = 1, Ambient = Color3.fromRGB(190, 197, 224),
		LightColor = Color3.fromRGB(255, 235, 209), LightDirection = Vector3.new(-1, -1, -2),
	})
	C.New("WorldModel", "World", viewport)
	local camera = C.New("Camera", "PreviewCamera", viewport, { FieldOfView = 38 })
	viewport.CurrentCamera = camera
	local previewStatus = C.Label(viewport, "Status", "Loading hero...", nil, UDim2.fromScale(1, 1))
	previewStatus.TextSize = 12
	previewStatus.TextXAlignment = Enum.TextXAlignment.Center
	equipment(hero, "Equipped", { "Weapon", "Armor", "Ring", "Necklace", "Aura", "Rune" })
	equipment(hero, "Vanities", { "Weapon", "Aura" }).Visible = false
	C.Button(hero, "Vanity", "GEAR / LOOKS", UDim2.fromOffset(8, 286), UDim2.new(1, -16, 0, 44), T.Purple)
	C.Section(hero, "StatsHeader", "TOTAL STATS", UDim2.fromOffset(6, 340), UDim2.new(1, -12, 0, 28))
	local stats = C.Frame(hero, "Stats", UDim2.fromOffset(12, 376), UDim2.new(1, -24, 0, 128))
	C.List(stats, false, 2)
	for _, entry in { { "Attack", "ATK" }, { "Defense", "DEF" }, { "Health", "HP" }, { "Speed", "SPD" }, { "Critical", "CRIT" } } do
		local row = C.Frame(stats, entry[1], nil, UDim2.new(1, 0, 0, 23), T.Soft)
		C.Round(row, 4)
		C.Label(row, "Label", entry[2], UDim2.fromOffset(8, 0), UDim2.fromScale(0.45, 1), true).TextSize = 13
		local value = C.Label(row, "Value", "--", UDim2.fromScale(0.45, 0), UDim2.new(0.55, -8, 1, 0), true)
		value.TextColor3 = entry[1] == "Health" and T.Green or T.Gold
		value.TextSize = 13
		value.TextXAlignment = Enum.TextXAlignment.Right
	end

	local items = C.Frame(body, "Items", nil, nil, T.Surface)
	C.Round(items)
	C.Stroke(items)
	C.Responsive(items, UDim2.fromScale(0.4, 0), UDim2.new(0.6, 0, 0, 510), UDim2.fromOffset(0, 56), UDim2.new(1, 0, 0, 510))
	items:SetAttribute("Breakpoint", 580)
	C.Section(items, "Header", "BACKPACK", UDim2.fromOffset(6, 6), UDim2.new(1, -12, 0, 28))
	C.Input(items, "Search", "Search items...", UDim2.fromOffset(8, 44), UDim2.new(1, -92, 0, 44))
	local limit = C.Label(items, "ItemLimit", "0 / 100", UDim2.new(1, -80, 0, 44), UDim2.fromOffset(72, 44), true)
	limit.RichText = true
	limit.TextSize = 12
	limit.TextXAlignment = Enum.TextXAlignment.Right
	local container = C.Scroll(items, "Container", UDim2.fromOffset(8, 100), UDim2.new(1, -16, 0, 286), 76, 96)
	container:SetAttribute("NormalHeight", 286)
	container:SetAttribute("StorageHeight", 126)
	local empty = C.Label(items, "Empty", "No items here yet.", UDim2.fromOffset(16, 126), UDim2.new(1, -32, 0, 90))
	empty.TextXAlignment = Enum.TextXAlignment.Center
	empty.TextColor3 = T.Muted
	local hint = C.Label(items, "Hint", "Hover for details / Tap for actions", UDim2.fromOffset(8, 388), UDim2.new(1, -16, 0, 28))
	hint.TextSize = 11
	hint.TextColor3 = T.Muted
	local bottom = C.Frame(items, "Bottom", UDim2.fromOffset(8, 426), UDim2.new(1, -16, 0, 76))
	for index, name in { "Sell", "Storage", "Advanced" } do
		local cell = C.Frame(bottom, name, UDim2.new((index - 1) / 3, 0, 0, 0), UDim2.new(1 / 3, -6, 0, 68))
		if name == "Sell" then
			C.Button(cell, "Sell", "SELL", nil, nil, T.Sand)
			C.Button(cell, "Cancel", "CANCEL", nil, nil, T.Rose).Visible = false
		elseif name == "Storage" then
			C.Button(cell, "Storage", "STORE", nil, nil, T.Sky)
			C.Button(cell, "Cancel", "BACK", nil, nil, T.Soft).Visible = false
		else
			C.Button(cell, "Drink", "POTIONS", nil, nil, T.Mint)
			C.Button(cell, "Confirm", "CONFIRM", nil, nil, T.Sand).Visible = false
		end
	end
	-- A full-height storage panel covers the hero column; the backpack stays
	-- available beside it for deposits. Keep Bank under Items for saved-UI bindings.
	local bank = C.Round(C.Frame(items, "Bank", UDim2.fromScale(-2 / 3, 0), UDim2.fromScale(0.64, 1), T.Paper), 8)
	bank.Visible = false
	bank.Active = true
	bank.ZIndex = 5
	C.Stroke(bank)
	C.Section(bank, "Header", "STORAGE", UDim2.fromScale(0.025, 0.012), UDim2.fromScale(0.95, 0.055))
	local bankLimit = C.Label(bank, "ItemLimit", "0 / 100", UDim2.fromScale(0.05, 0.085), UDim2.fromScale(0.9, 0.055), true)
	bankLimit.TextXAlignment = Enum.TextXAlignment.Center
	bankLimit.TextColor3 = T.Gold
	local bankHint = C.Label(bank, "Title", "Tap stored items to withdraw", UDim2.fromScale(0.05, 0.15), UDim2.fromScale(0.9, 0.07))
	bankHint.TextXAlignment = Enum.TextXAlignment.Center
	bankHint.TextColor3 = T.Muted
	local storedItems = C.Scroll(bank, "ScrollingFrame", UDim2.fromScale(0.03, 0.24), UDim2.fromScale(0.94, 0.63), 72, 96)
	storedItems.UIGridLayout.CellSize = UDim2.fromScale(0.44, 0.28)
	storedItems.UIGridLayout.CellPadding = UDim2.fromScale(0.04, 0.035)
	local help = C.Label(bank, "Help", "Tap backpack items to deposit.\nUse BACK to return to your hero.", UDim2.fromScale(0.05, 0.9), UDim2.fromScale(0.9, 0.085))
	help.TextXAlignment = Enum.TextXAlignment.Center
	help.TextColor3 = T.Muted
	quantity(root, "StackMove")
	quantity(root, "StackSell")
	quantity(root, "BankStackMove")
	itemDialog(root, "ActionFrame", "Weapon")
	itemDialog(root, "GeneralFrame", "Equipment")
	itemDialog(root, "UsableFrame", "Usable")
	itemDialog(root, "MaterialFrame", "Material")
	root.MaterialFrame.Inner.Action.Visible = false

	local tip = C.Round(C.Frame(screen, "ItemTooltip", UDim2.new(), UDim2.fromOffset(252, 286), T.Paper), 8)
	tip.Visible = false
	tip.ZIndex = 50
	C.Stroke(tip)
	C.Frame(tip, "RarityBar", UDim2.fromOffset(4, 4), UDim2.new(1, -8, 0, 4), T.Sky)
	C.Label(tip, "ItemName", "", UDim2.fromOffset(12, 14), UDim2.new(1, -24, 0, 46), true).TextSize = 18
	C.Label(tip, "Meta", "", UDim2.fromOffset(12, 62), UDim2.new(1, -24, 0, 26)).TextSize = 12
	C.Label(tip, "Description", "", UDim2.fromOffset(12, 94), UDim2.new(1, -24, 0, 78)).TextSize = 13
	C.Label(tip, "Stats", "", UDim2.fromOffset(12, 180), UDim2.new(1, -24, 0, 68)).TextSize = 13
	C.Label(tip, "Footer", "", UDim2.new(0, 12, 1, -30), UDim2.new(1, -24, 0, 22)).TextColor3 = T.Gold
	return screen
end
