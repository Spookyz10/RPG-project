-- STUDIO COMMAND BAR / EDIT MODE ONLY.
-- Standalone: paste this entire file; no plugin or generator module is required.
-- Existing UI is moved into ServerStorage.RPGUIBackups before replacement.
-- Runtime scripts bind the saved UI and never regenerate it.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating the UI.")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Selection = game:GetService("Selection")
local History = game:GetService("ChangeHistoryService")

local T = (function()
-- Graphite cartoon style, following Info/UITheme.txt.
-- Semantic aliases retain compatibility with the existing screen logic.
local Theme = {
	Paper = Color3.fromRGB(32, 33, 41),
	Surface = Color3.fromRGB(44, 46, 57),
	Soft = Color3.fromRGB(61, 63, 76),
	Ink = Color3.fromRGB(255, 255, 255),
	Muted = Color3.fromRGB(191, 197, 215),
	Line = Color3.fromRGB(10, 12, 19),
	Green = Color3.fromRGB(67, 222, 112),
	Mint = Color3.fromRGB(38, 184, 84),
	Blue = Color3.fromRGB(76, 184, 255),
	Sky = Color3.fromRGB(35, 138, 228),
	Gold = Color3.fromRGB(255, 208, 81),
	Sand = Color3.fromRGB(225, 153, 32),
	Red = Color3.fromRGB(255, 111, 118),
	Rose = Color3.fromRGB(221, 65, 82),
	Purple = Color3.fromRGB(153, 89, 234),
	Highlight = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamBold,
	Bold = Enum.Font.FredokaOne,
	CornerRadius = 8,
	StrokeThickness = 3,
}
Theme.Rarities = {
	Common = Color3.fromRGB(111, 124, 145),
	Uncommon = Theme.Mint,
	Rare = Theme.Sky,
	Legendary = Color3.fromRGB(217, 64, 156),
	Godly = Theme.Sand,
	Ascendant = Theme.Purple,
}
return Theme
end)()

local C = (function()
local C = {}

function C.New(className, name, parent, properties)
	local object = Instance.new(className)
	object.Name = name
	if object:IsA("GuiObject") then
		object.BorderSizePixel = 0
		object.BackgroundColor3 = T.Surface
	end
	if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
		object.Font = T.Font
		object.TextSize = 15
		object.TextScaled = true
		object.TextColor3 = T.Ink
		object.TextWrapped = true
		object.TextStrokeColor3 = T.Line
		object.TextStrokeTransparency = 0.15
	end
	for key, value in properties or {} do object[key] = value end
	object.Parent = parent
	return object
end

function C.Round(object, radius)
	C.New("UICorner", "UICorner", object, { CornerRadius = UDim.new(0, math.min(radius or T.CornerRadius, 10)) })
	return object
end

function C.Stroke(object, color)
	return C.New("UIStroke", "UIStroke", object, { Color = color or T.Line, Thickness = T.StrokeThickness, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
end

function C.Gradient(object)
	return C.New("UIGradient", "SurfaceGradient", object, {
		Rotation = 90,
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(175, 182, 205)),
	})
end

function C.Section(parent, name, text, position, size)
	local bar = C.Round(C.Frame(parent, name, position, size or UDim2.new(1, 0, 0, 28), T.Soft), 6)
	local label = C.Label(bar, "Title", text, UDim2.fromOffset(8, 0), UDim2.new(1, -16, 1, 0), true)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextSize = 15
	return bar
end

function C.Frame(parent, name, position, size, color)
	return C.New("Frame", name, parent, { Position = position or UDim2.new(), Size = size or UDim2.fromScale(1, 1), BackgroundTransparency = color and 0 or 1, BackgroundColor3 = color or T.Surface })
end

function C.Label(parent, name, text, position, size, bold)
	return C.New("TextLabel", name, parent, { Text = text, Position = position or UDim2.new(), Size = size or UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Font = bold and T.Bold or T.Font })
end

function C.Button(parent, name, text, position, size, color)
	local button = C.New("TextButton", name, parent, { Text = text, Position = position or UDim2.new(), Size = size or UDim2.new(1, 0, 0, 48), BackgroundColor3 = color or T.Mint, AutoButtonColor = true })
	C.Round(button, 10)
	C.Stroke(button)
	C.Gradient(button)
	button.Font = T.Bold
	button:SetAttribute("HoverButton", true)
	return button
end

function C.Input(parent, name, placeholder, position, size)
	local box = C.New("TextBox", name, parent, { Text = "", PlaceholderText = placeholder, PlaceholderColor3 = T.Muted, ClearTextOnFocus = false, Position = position, Size = size, BackgroundColor3 = T.Surface })
	C.Round(box, 10)
	C.Stroke(box)
	return box
end

function C.Image(parent, name, position, size)
	return C.New("ImageLabel", name, parent, { Image = "", BackgroundTransparency = 1, Position = position or UDim2.new(), Size = size or UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Fit })
end

function C.List(parent, horizontal, padding)
	return C.New("UIListLayout", "UIListLayout", parent, { FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical, Padding = UDim.new(0, padding or 8), SortOrder = Enum.SortOrder.LayoutOrder })
end

function C.Scroll(parent, name, position, size, gridWidth, rowHeight)
	local scroll = C.New("ScrollingFrame", name, parent, { Position = position, Size = size, BackgroundTransparency = 1, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 4, ScrollBarImageColor3 = T.Green, ScrollingDirection = Enum.ScrollingDirection.Y })
	C.New("UIPadding", "Padding", scroll, { PaddingTop = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) })
	if gridWidth then
		local grid = C.New("UIGridLayout", "UIGridLayout", scroll, { CellSize = UDim2.fromOffset(gridWidth, rowHeight or gridWidth), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder })
		grid:SetAttribute("CellMinWidth", gridWidth)
		grid:SetAttribute("CellHeight", rowHeight or gridWidth)
	else
		C.List(scroll)
	end
	return scroll
end

function C.Screen(parent, name, order)
	return C.New("ScreenGui", name, parent, { ResetOnSpawn = false, DisplayOrder = order or 10, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets })
end

function C.Responsive(object, widePosition, wideSize, narrowPosition, narrowSize)
	object:SetAttribute("WidePosition", widePosition)
	object:SetAttribute("WideSize", wideSize)
	object:SetAttribute("NarrowPosition", narrowPosition)
	object:SetAttribute("NarrowSize", narrowSize)
	object.Position = widePosition
	object.Size = wideSize
	return object
end

function C.Window(parent, screenName, rootName, title, subtitle, wideHeight, narrowHeight)
	local screen = C.Screen(parent, screenName, 30)
	local root = C.Frame(screen, rootName, UDim2.fromScale(0.5, 0.5), UDim2.new(1, -24, 1, -24), T.Paper)
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Visible = false
	root.Active = true
	root:SetAttribute("Window", true)
	C.Round(root, 18)
	C.Stroke(root)
	C.New("UISizeConstraint", "Bounds", root, { MaxSize = Vector2.new(800, 620) })
	C.Frame(root, "Accent", UDim2.fromOffset(14, 0), UDim2.new(1, -28, 0, 4), T.Sky)
	local heading = C.Label(root, "Heading", title, UDim2.fromOffset(20, 12), UDim2.new(1, -90, 0, 27), true)
	heading.TextSize = 29
	heading.TextScaled = true
	heading.TextWrapped = false
	C.New("UITextSizeConstraint", "TextBounds", heading, { MinTextSize = 16, MaxTextSize = 29 })
	local description = C.Label(root, "Subtitle", subtitle, UDim2.fromOffset(20, 42), UDim2.new(1, -90, 0, 24))
	description.TextColor3 = T.Muted
	description.TextSize = 12
	description.TextWrapped = false
	description.TextTruncate = Enum.TextTruncate.AtEnd
	local close = C.Button(root, "Close", "X", UDim2.new(1, -60, 0, 12), UDim2.fromOffset(44, 44), T.Rose)
	close:SetAttribute("CloseWindow", true)
	local body = C.New("ScrollingFrame", "Body", root, { Position = UDim2.fromOffset(16, 78), Size = UDim2.new(1, -32, 1, -92), BackgroundTransparency = 1, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 4, ScrollBarImageColor3 = T.Green, ScrollingDirection = Enum.ScrollingDirection.Y })
	local content = C.Frame(body, "Content")
	C.Responsive(content, UDim2.new(), UDim2.new(1, -8, 0, wideHeight or 470), UDim2.new(), UDim2.new(1, -8, 0, narrowHeight or wideHeight or 470))
	return screen, root, content
end

function C.Card(parent, name, height)
	local card = C.Round(C.Frame(parent, name, UDim2.new(), UDim2.new(1, -8, 0, height), T.Surface))
	C.Stroke(card)
	return card
end

-- Convert the design measurements once, in Edit mode. Saved instances and
-- responsive attributes use Scale, independently of the Studio viewport.
function C.SaveScale(root)
	local function scale(value, reference)
		return UDim2.fromScale(value.X.Scale + value.X.Offset / math.max(1, reference.X), value.Y.Scale + value.Y.Offset / math.max(1, reference.Y))
	end
	local function size(value, reference)
		return Vector2.new(math.max(1, value.X.Scale * reference.X + value.X.Offset), math.max(1, value.Y.Scale * reference.Y + value.Y.Offset))
	end
	local function visit(object, wideParent, narrowParent)
		local wide, narrow = wideParent, narrowParent
		if object:IsA("GuiObject") then
			wide = size(object.Size, wideParent)
			narrow = size(object:GetAttribute("NarrowSize") or object.Size, narrowParent)
			local bounds = object:FindFirstChild("Bounds")
			if bounds and bounds:IsA("UISizeConstraint") then
				wide = Vector2.new(math.min(wide.X, bounds.MaxSize.X), math.min(wide.Y, bounds.MaxSize.Y))
				narrow = Vector2.new(math.min(narrow.X, bounds.MaxSize.X), math.min(narrow.Y, bounds.MaxSize.Y))
			end
			object.Position = scale(object.Position, wideParent)
			object.Size = scale(object.Size, wideParent)
			for _, attribute in { "WidePosition", "WideSize", "NarrowPosition", "NarrowSize" } do
				local value = object:GetAttribute(attribute)
				if value then object:SetAttribute(attribute, scale(value, string.sub(attribute, 1, 6) == "Narrow" and narrowParent or wideParent)) end
			end
			if object:IsA("ScrollingFrame") then object.CanvasSize = scale(object.CanvasSize, wide) end
			for _, attribute in { "NormalHeight", "StorageHeight" } do
				local value = object:GetAttribute(attribute)
				if value then object:SetAttribute(attribute, value / wideParent.Y) end
			end
		elseif object:IsA("UIGridLayout") then
			object.CellSize = scale(object.CellSize, wideParent)
			object.CellPadding = scale(object.CellPadding, wideParent)
		elseif object:IsA("UIListLayout") then
			local reference = object.FillDirection == Enum.FillDirection.Horizontal and wideParent.X or wideParent.Y
			object.Padding = UDim.new(object.Padding.Scale + object.Padding.Offset / reference, 0)
		elseif object:IsA("UIPadding") then
			for _, key in { "PaddingLeft", "PaddingRight", "PaddingTop", "PaddingBottom" } do
				local value = object[key]
				local reference = (key == "PaddingLeft" or key == "PaddingRight") and wideParent.X or wideParent.Y
				object[key] = UDim.new(value.Scale + value.Offset / reference, 0)
			end
		elseif object:IsA("UICorner") then
			object.CornerRadius = UDim.new(object.CornerRadius.Scale + object.CornerRadius.Offset / math.min(wideParent.X, wideParent.Y), 0)
		end
		for _, child in object:GetChildren() do visit(child, wide, narrow) end
	end
	local reference = root:IsA("ScreenGui") and Vector2.new(1280, 720) or Vector2.new(400, 470)
	visit(root, reference, root:IsA("ScreenGui") and Vector2.new(390, 760) or reference)
end

return C
end)()

local builders = {}

builders.Inventory = (function()

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
	local bank = C.Round(C.Frame(items, "Bank", UDim2.fromOffset(6, 238), UDim2.new(1, -12, 0, 176), T.Paper), 6)
	bank.Visible = false
	C.Label(bank, "Title", "STORAGE / tap to withdraw", UDim2.fromOffset(8, 4), UDim2.new(1, -80, 0, 28), true).TextSize = 11
	C.Label(bank, "ItemLimit", "0 / 100", UDim2.new(1, -72, 0, 4), UDim2.fromOffset(64, 28)).TextSize = 11
	C.Scroll(bank, "ScrollingFrame", UDim2.fromOffset(6, 38), UDim2.new(1, -12, 1, -44), 72, 96)
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
end)()

local staging = Instance.new("Folder")
local generated = {}
local ok, reason = pcall(function()

    table.insert(generated, { Object = builders.Inventory(staging), Target = StarterGui })

for _, entry in generated do C.SaveScale(entry.Object) end
end)
if not ok then staging:Destroy(); error("UI generation failed; existing screens were preserved: " .. tostring(reason)) end
local recording
pcall(function() recording = History:TryBeginRecording("GenerateRPGUI", "Generate RPG interface") end)
local backupRoot = ServerStorage:FindFirstChild("RPGUIBackups")
local backup
for _, entry in generated do
    local old = entry.Target:FindFirstChild(entry.Object.Name)
    if old then
        if not backupRoot then backupRoot = Instance.new("Folder"); backupRoot.Name = "RPGUIBackups"; backupRoot.Parent = ServerStorage end
        if not backup then
            backup = Instance.new("Folder")
            backup.Name = os.date("%Y-%m-%d_%H-%M-%S")
            backup.Parent = backupRoot
        end
        old:SetAttribute("OriginalService", entry.Target.Name)
        old.Parent = backup
    end
    entry.Object:SetAttribute("RPGUIVersion", 2)
    entry.Object.Parent = entry.Target
end
staging:Destroy()
local selected

local preferred = "Inventory"

for _, entry in generated do
    local object = entry.Object
    if object.Name == preferred then
        selected = object
        if object:IsA("ScreenGui") then
            for _, child in object:GetChildren() do
                if child:IsA("GuiObject") and child:GetAttribute("Window") then child.Visible = true end
            end
        end
    end
end
-- Loading/tutorial are enabled by their client controllers, not while editing.
for _, name in { "LoadingScreen", "Tutorial", "UIStylePreview" } do
    local screen = StarterGui:FindFirstChild(name)
    if screen then screen.Enabled = preferred == name end
end
if selected then Selection:Set({ selected }) end
if recording then History:FinishRecording(recording, Enum.FinishRecordingOperation.Commit) end
print("RPG UI saved as editable instances. Save the place before Play. Backups: ServerStorage.RPGUIBackups")
