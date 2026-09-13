assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating the UI.")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Selection = game:GetService("Selection")
local History = game:GetService("ChangeHistoryService")

local T = (function()
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
		elseif object:IsA("BillboardGui") then
			-- Billboard contents are laid out inside the billboard's own pixel canvas,
			-- not the generic template folder reference.
			wide = size(object.Size, wideParent)
			narrow = wide
		end
		for _, child in object:GetChildren() do visit(child, wide, narrow) end
	end
	local reference = root:IsA("ScreenGui") and Vector2.new(1280, 720) or Vector2.new(400, 470)
	visit(root, reference, root:IsA("ScreenGui") and Vector2.new(390, 760) or reference)
end

return C
end)()

local builders = {}

builders.Trading = (function()

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
end)()

local staging = Instance.new("Folder")
local generated = {}
local ok, reason = pcall(function()

    table.insert(generated, { Object = builders.Trading(staging), Target = StarterGui })

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

local preferred = "Trading"

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
for _, name in { "LoadingScreen", "Tutorial", "UIStylePreview" } do
    local screen = StarterGui:FindFirstChild(name)
    if screen then screen.Enabled = preferred == name end
end
if selected then Selection:Set({ selected }) end
if recording then History:FinishRecording(recording, Enum.FinishRecordingOperation.Commit) end
print("RPG UI saved as editable instances. Save the place before Play. Backups: ServerStorage.RPGUIBackups")
