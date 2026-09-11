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

builders.Templates = (function()

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

	local mob = (function()
-- All UI dimensions use Scale. Billboard scale is measured in world studs.
return function(parent)
	local function create(class, name, owner, properties)
		local object = Instance.new(class)
		object.Name = name
		for key, value in properties do object[key] = value end
		object.Parent = owner
		return object
	end
	local function round(owner, radius)
		create("UICorner", "Corner", owner, { CornerRadius = UDim.new(radius, 0) })
	end
	local function gradient(owner, top, bottom)
		create("UIGradient", "Gradient", owner, { Rotation = 90, Color = ColorSequence.new(top, bottom) })
	end
	local function label(owner, name, text, position, size, color)
		return create("TextLabel", name, owner, {
			Position = position, Size = size, BackgroundTransparency = 1,
			Text = text, TextScaled = true, TextColor3 = color,
			Font = Enum.Font.GothamBold, TextStrokeTransparency = 0.65,
			TextStrokeColor3 = Color3.fromRGB(20, 39, 34), ZIndex = 3,
		})
	end
	local gui = create("BillboardGui", "MobOverhead", parent, {
		Size = UDim2.fromScale(5.4, 1.45), StudsOffsetWorldSpace = Vector3.new(0, 4, 0),
		AlwaysOnTop = true, MaxDistance = 85, LightInfluence = 0,
	})
	local info = create("Frame", "Info", gui, {
		Position = UDim2.fromScale(0.02, 0), Size = UDim2.fromScale(0.96, 0.44), BackgroundTransparency = 1,
	})
	local name = label(info, "MobName", "Bushling", UDim2.fromScale(0, 0.06), UDim2.fromScale(0.73, 0.88), Color3.fromRGB(255, 248, 227))
	name.TextXAlignment = Enum.TextXAlignment.Left
	local badge = create("Frame", "LevelBadge", info, {
		Position = UDim2.fromScale(0.77, 0.1), Size = UDim2.fromScale(0.23, 0.8),
		BackgroundColor3 = Color3.fromRGB(37, 65, 54), BorderSizePixel = 0,
	})
	round(badge, 0.28)
	gradient(badge, Color3.fromRGB(106, 139, 103), Color3.fromRGB(49, 79, 62))
	label(badge, "Level", "Lv. 1", UDim2.fromScale(0.06, 0.1), UDim2.fromScale(0.88, 0.8), Color3.fromRGB(255, 235, 181))
	local hp = create("Frame", "HP", gui, {
		Position = UDim2.fromScale(0, 0.51), Size = UDim2.fromScale(1, 0.47),
		BackgroundColor3 = Color3.fromRGB(22, 40, 34), BorderSizePixel = 0,
	})
	round(hp, 0.3)
	local track = create("Frame", "Track", hp, {
		Position = UDim2.fromScale(0.015, 0.12), Size = UDim2.fromScale(0.97, 0.76),
		BackgroundColor3 = Color3.fromRGB(67, 86, 68), BorderSizePixel = 0, ClipsDescendants = true,
	})
	round(track, 0.25)
	gradient(track, Color3.fromRGB(73, 91, 69), Color3.fromRGB(34, 54, 45))
	local bar = create("Frame", "Bar", track, {
		Position = UDim2.fromScale(0, 0), Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
	})
	round(bar, 0.25)
	gradient(bar, Color3.fromRGB(177, 241, 176), Color3.fromRGB(67, 165, 119))
	label(hp, "Health", "HP  45 / 45", UDim2.fromScale(0.04, 0.17), UDim2.fromScale(0.92, 0.66), Color3.fromRGB(255, 255, 240))
	return gui
end
end)()(folder)
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

	local shop = C.Card(folder, "ShopTemplate", 158)
	C.Label(shop, "Name", "Item", UDim2.fromOffset(12, 8), UDim2.new(1, -24, 0, 30), true)
	C.Label(shop, "Price", "", UDim2.fromOffset(12, 42), UDim2.new(1, -24, 0, 36)).TextColor3 = T.Gold
	C.Button(shop, "Buy", "BUY", UDim2.fromOffset(12, 94), UDim2.new(1, -24, 0, 48))
	local quest = C.Card(folder, "QuestTemplate", 260)
	C.Label(quest, "QuestName", "", UDim2.fromOffset(12, 8), UDim2.new(1, -24, 0, 28), true)
	C.Label(quest, "Description", "", UDim2.fromOffset(12, 42), UDim2.new(1, -24, 0, 64))
	local objective = C.Label(quest, "ObjectiveTemplate", "", UDim2.fromOffset(12, 110), UDim2.new(1, -24, 0, 26))
	objective.TextColor3 = T.Green
	objective.Visible = false
	C.Button(quest, "Abandon", "ABANDON QUEST", UDim2.new(0, 12, 1, -60), UDim2.new(1, -24, 0, 48), T.Rose)
	local toast = C.Label(folder, "ToastTemplate", "", nil, UDim2.new(1, 0, 0, 58), true)
	toast.BackgroundTransparency = 0
	toast.BackgroundColor3 = T.Surface
	toast.TextXAlignment = Enum.TextXAlignment.Center
	toast.TextSize = 14
	C.Round(toast)
	C.Stroke(toast)
	C.Label(folder, "EmptyTemplate", "", nil, UDim2.new(1, -8, 0, 120)).TextColor3 = T.Muted
	C.Button(folder, "DialogueChoiceTemplate", "Continue", nil, UDim2.new(1, -8, 0, 52), T.Sky)
	C.Button(folder, "AdminItemTemplate", "Item", nil, UDim2.new(1, -8, 0, 48), T.Soft)
	return folder
end
end)()

builders.Loading = (function()

return function(parent)
	local screen = C.Screen(parent, "LoadingScreen", 100)
	screen.ScreenInsets = Enum.ScreenInsets.None
	local bg = T.Paper
	local gold = T.Gold
	local frame = C.Frame(screen, "Frame", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), bg)
	C.New("UIGradient", "Atmosphere", frame, { Rotation = 35, Color = ColorSequence.new(Color3.fromRGB(170, 160, 205), Color3.fromRGB(255, 255, 255)) })
	local art = C.Image(frame, "BackgroundArt", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1))
	art.ScaleType = Enum.ScaleType.Crop
	art.ImageTransparency = 0.7
	C.Frame(frame, "TopRule", UDim2.fromScale(0.07, 0.12), UDim2.fromScale(0.86, 0.002), gold)
	local function text(name, value, x, y, w, h, color, font)
		local label = C.Label(frame, name, value, UDim2.fromScale(x, y), UDim2.fromScale(w, h))
		label.Font = font or T.Font
		label.TextColor3 = color or Color3.fromRGB(231, 234, 238)
		label.TextStrokeTransparency = 1
		return label
	end
	text("Chapter", "YOUR NEXT ADVENTURE AWAITS", 0.08, 0.22, 0.8, 0.035, gold, Enum.Font.GothamMedium)
	text("Title", "BOOTLEG SIM", 0.075, 0.31, 0.85, 0.13, nil, T.Bold)
	text("Subtitle", "Small beginnings. Legendary adventures.", 0.08, 0.47, 0.75, 0.045)
	text("Edition", "EXPLORE  /  GROW  /  ENDURE", 0.08, 0.56, 0.72, 0.027, gold)
	local progress = C.Frame(frame, "Progress", UDim2.fromScale(0.08, 0.77), UDim2.fromScale(0.84, 0.025), T.Soft)
	C.Round(progress)
	progress.ClipsDescendants = true
	local fill = C.Frame(progress, "Fill", UDim2.fromScale(0, 0), UDim2.fromScale(0, 1), T.Mint)
	C.Round(fill)
	C.New("UIGradient", "Gradient", fill, { Color = ColorSequence.new(T.Mint, T.Green) })
	local spark = C.Frame(frame, "Spark", UDim2.fromScale(0.88, 0.32), UDim2.fromScale(0.025, 0.025), T.Gold)
	spark.Rotation = 45
	C.New("UIAspectRatioConstraint", "Aspect", spark, { AspectRatio = 1 })
	text("Tip", "TIP  ?  Watch the red ground markers and dodge before they fill.", 0.08, 0.67, 0.84, 0.045, T.Muted)
	text("Percent", "0%", 0.8, 0.81, 0.12, 0.035, T.Green, T.Bold)
	text("Status", "Connecting to the world...", 0.08, 0.8, 0.58, 0.035)
	local play = C.New("TextButton", "Play", frame, { Position = UDim2.fromScale(0.66, 0.84), Size = UDim2.fromScale(0.26, 0.085), Text = "ENTER WORLD", Font = Enum.Font.GothamMedium, TextStrokeTransparency = 1, BackgroundColor3 = T.Mint, TextColor3 = T.Ink, Visible = false })
	C.Round(play)
	C.Gradient(play)
	local stroke = C.Stroke(play, T.Line)
	stroke.Thickness = 1
	text("Footer", "YOUR STORY CONTINUES", 0.08, 0.91, 0.5, 0.022, Color3.fromRGB(126, 139, 157))
	return screen
end
end)()

builders.HUD = (function()

return function(parent)
	local screen = C.Screen(parent, "HUD")
	local main = C.Round(C.Frame(screen, "Main", UDim2.fromOffset(12, 10), UDim2.fromOffset(300, 182), T.Paper), 16)
	C.Stroke(main)
	C.Responsive(main, UDim2.fromOffset(12, 10), UDim2.fromOffset(300, 182), UDim2.fromOffset(8, 8), UDim2.fromOffset(228, 164))
	C.Label(main, "PlayerName", "Adventurer", UDim2.fromOffset(14, 10), UDim2.new(1, -100, 0, 24), true)
	local level = C.Label(main, "Level", "Lv. 1", UDim2.new(1, -88, 0, 10), UDim2.fromOffset(74, 24), true)
	level.TextColor3 = T.Green
	level.TextXAlignment = Enum.TextXAlignment.Right
	for index, name in { "HP", "XP" } do
		local bar = C.Frame(main, name, UDim2.new(0, 14, 0, 40 + (index - 1) * 30), UDim2.new(1, -28, 0, 24))
		local track = C.Round(C.Frame(bar, "Main", UDim2.new(), UDim2.fromScale(1, 1), T.Soft), 8)
		track.ClipsDescendants = true
		C.Round(C.Frame(track, "Bar", UDim2.new(), UDim2.fromScale(1, 1), name == "HP" and T.Mint or T.Sky), 8)
		local amount = C.Label(track, "Amount", name .. "  -- / --", UDim2.fromOffset(8, 0), UDim2.new(1, -16, 1, 0), true)
		amount.TextSize = 13
	end
	local currencies = C.Frame(main, "Currencies", UDim2.fromOffset(14, 104), UDim2.new(1, -28, 0, 68))
	for index, name in { "Gold", "Raid Coins", "Tokens", "Rune Crystals" } do
		local col, row = (index - 1) % 2, math.floor((index - 1) / 2)
		local cell = C.Frame(currencies, name, UDim2.new(col * 0.5, 0, 0, row * 29), UDim2.new(0.5, -4, 0, 26))
		C.Label(cell, "Label", name == "Rune Crystals" and "Crystals" or name, UDim2.new(), UDim2.new(0.63, 0, 1, 0)).TextSize = 11
		local amount = C.Label(cell, "Amount", "0", UDim2.fromScale(0.63, 0), UDim2.fromScale(0.37, 1), true)
		amount.TextSize = 13
		amount.TextXAlignment = Enum.TextXAlignment.Right
		amount.TextColor3 = index == 1 and T.Gold or T.Blue
	end
	return screen
end
end)()

builders.Navigation = (function()

return function(parent)
	local screen = C.Screen(parent, "Buttons", 15)
	local main = C.Frame(screen, "Main", UDim2.new(1, -92, 0, 10), UDim2.fromOffset(80, 280))
	local toggle = C.Button(main, "Menu", "Menu", UDim2.new(), UDim2.fromOffset(80, 48), T.Sand)
	toggle:SetAttribute("ToggleMenu", true)
	local drawer = C.Round(C.Frame(main, "Drawer", UDim2.new(1, -184, 0, 56), UDim2.fromOffset(184, 408), T.Paper), 14)
	drawer.Visible = false
	C.Stroke(drawer)
	local list = C.Scroll(drawer, "Items", UDim2.fromOffset(8, 8), UDim2.new(1, -16, 1, -16))
	for index, entry in {
		{ "Inventory", "Backpack", "Inventory" }, { "Skills", "Skills", "SkillSelector" },
		{ "Zones", "Explore", "ZoneSelector" }, { "Raids", "Boss raids", "RaidsGUI" },
		{ "Players", "Adventurers", "Playerlist" }, { "Party", "My party", "Partylist" },
		{ "Journal", "Quest journal", "Journal" }, { "Home", "Return to village", "Home" },
		{ "Admin", "Developer tools", "Main" },
	} do
		local button = C.Button(list, entry[1], entry[2])
		button.LayoutOrder = index
		button:SetAttribute("OpenScreen", entry[3])
		if entry[1] == "Admin" then button.Visible = false end
	end
	-- A small primary shortcut stays visible when the menu is collapsed.
	local bag = C.Button(main, "Backpack", "Bag", UDim2.fromOffset(0, 56), UDim2.fromOffset(80, 48), T.Mint)
	bag:SetAttribute("OpenScreen", "Inventory")
	local amount = C.Label(bag, "Amount", "0 / 100", UDim2.fromOffset(0, 28), UDim2.new(1, 0, 0, 16))
	amount.TextSize = 10
	amount.TextXAlignment = Enum.TextXAlignment.Center
	C.Responsive(drawer, UDim2.new(1, -184, 0, 56), UDim2.fromOffset(184, 408), UDim2.new(1, -184, 0, 56), UDim2.fromOffset(184, 260))
	return screen
end
end)()

builders.Combat = (function()

return function(parent)
	local screen = C.Screen(parent, "Attack", 12)
	local slots = C.Frame(screen, "Slots")
	C.Responsive(slots, UDim2.new(0.5, -116, 1, -88), UDim2.fromOffset(232, 72), UDim2.new(1, -256, 1, -280), UDim2.fromOffset(232, 64))
	C.List(slots, true, 8)
	for index, key in { "Q", "E", "R" } do
		local slot = C.Button(slots, "Slot" .. index, "", UDim2.new(), UDim2.fromOffset(72, 64), T.Paper)
		C.Stroke(slot)
		slot.LayoutOrder = index
		C.Image(slot, "Icon", UDim2.fromOffset(18, 4), UDim2.fromOffset(36, 36))
		local caption = C.Label(slot, "SkillName", "Empty", UDim2.fromOffset(2, 40), UDim2.new(1, -4, 0, 20), true)
		caption.TextSize = 10
		caption.TextXAlignment = Enum.TextXAlignment.Center
		C.Label(slot, "Key", key, UDim2.fromOffset(5, 3), UDim2.fromOffset(16, 18), true).TextSize = 11
		local cooldown = C.Label(slot, "Cooldown", "", UDim2.new(), UDim2.fromScale(1, 1), true)
		cooldown.BackgroundColor3 = T.Paper
		cooldown.BackgroundTransparency = 0.15
		cooldown.TextXAlignment = Enum.TextXAlignment.Center
		cooldown.TextSize = 22
		cooldown.Visible = false
		C.Round(cooldown)
	end
	local attack = C.Button(screen, "AttackButton", "ATTACK", UDim2.new(1, -104, 1, -208), UDim2.fromOffset(88, 72), T.Sand)
	attack.Visible = false
	C.Stroke(attack, T.Gold)
	local buffs = C.Frame(screen, "Buffs", UDim2.new(0.5, -112, 1, -134), UDim2.fromOffset(224, 38))
	C.Responsive(buffs, buffs.Position, buffs.Size, UDim2.new(1, -256, 1, -326), UDim2.fromOffset(232, 38))
	C.List(buffs, true, 6)
	local debuffs = C.Frame(screen, "Debuffs", UDim2.new(0.5, -112, 1, -178), UDim2.fromOffset(224, 38))
	C.Responsive(debuffs, debuffs.Position, debuffs.Size, UDim2.new(1, -256, 1, -370), UDim2.fromOffset(232, 38))
	C.List(debuffs, true, 6)
	return screen
end
end)()

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
	local stats = C.Frame(inner, "Stats", UDim2.new(), UDim2.new(1, -12, 0, 170))
	stats.LayoutOrder = 5
	stats.Visible = kind == "Equipment"
	C.List(stats, false, 2)
	for _, stat in { "ATK", "CRT", "CPWR", "SPD", "DEF", "HP" } do C.Label(stats, stat, stat .. ": 0") end
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
end)()

builders.Skills = (function()

return function(parent)
	local screen, _, body = C.Window(parent, "SkillSelector", "Frame", "Find your fighting style", "Choose a skill, then choose its slot. Q · E · R on keyboard.", 470, 470)
	local sidebar = C.Frame(body, "Sidebar", UDim2.new(), UDim2.new(1, 0, 0, 48))
	C.Button(sidebar, "Attack", "Attack skills", UDim2.new(), UDim2.new(0.5, -4, 1, 0), T.Mint)
	C.Button(sidebar, "Support", "Support skills", UDim2.new(0.5, 4, 0, 0), UDim2.new(0.5, -4, 1, 0), T.Sky)
	local holder = C.Frame(body, "Holder", UDim2.fromOffset(0, 60), UDim2.new(1, 0, 0, 410))
	C.Scroll(holder, "Attack", UDim2.new(), UDim2.fromScale(1, 1))
	C.Scroll(holder, "Support", UDim2.new(), UDim2.fromScale(1, 1)).Visible = false
	return screen
end
end)()

builders.Zones = (function()

return function(parent)
	local screen, _, body = C.Window(parent, "ZoneSelector", "Main", "Explore the world", "Choose a zone to inspect its creatures and rewards.", 460, 460)
	local list = C.Scroll(body, "Container", UDim2.new(), UDim2.fromScale(1, 1))
	local detail = C.Frame(body, "Details")
	detail.Visible = false
	C.Button(detail, "Back", "? Zones", UDim2.fromScale(0, 0), UDim2.fromScale(0.23, 0.09))
	C.Label(detail, "ZoneName", "Grasslands", UDim2.fromScale(0.27, 0), UDim2.fromScale(0.73, 0.09), true)
	C.Label(detail, "LevelRange", "Lv. 1?15", UDim2.fromScale(0, 0.11), UDim2.fromScale(1, 0.07))
	C.Scroll(detail, "Mobs", UDim2.fromScale(0, 0.2), UDim2.fromScale(1, 0.66))
	C.Button(detail, "Enter", "Enter zone", UDim2.fromScale(0, 0.89), UDim2.fromScale(1, 0.11))
	local templates = C.New("Folder", "Templates", screen)
	local zone = C.Button(templates, "ZoneEntry", "", nil, UDim2.fromScale(0.96, 0.22))
	zone.Visible = false
	C.Label(zone, "AreaName", "Zone", UDim2.fromScale(0.04, 0.08), UDim2.fromScale(0.92, 0.35), true)
	C.Label(zone, "LevelReq", "Lv. 1?15", UDim2.fromScale(0.04, 0.48), UDim2.fromScale(0.48, 0.3))
	C.Label(zone, "Status", "View mobs ?", UDim2.fromScale(0.53, 0.48), UDim2.fromScale(0.43, 0.3), true)
	local mob = C.Frame(templates, "MobEntry", nil, UDim2.fromScale(0.96, 1.25), Color3.fromRGB(38, 48, 56))
	mob.Visible = false
	C.Round(mob); C.Stroke(mob)
	C.Label(mob, "MobName", "Bushling ? Lv. 1", UDim2.fromScale(0.04, 0.03), UDim2.fromScale(0.92, 0.09), true)
	C.Label(mob, "Stats", "Stats", UDim2.fromScale(0.04, 0.14), UDim2.fromScale(0.92, 0.2))
	C.Label(mob, "Rewards", "Rewards", UDim2.fromScale(0.04, 0.36), UDim2.fromScale(0.92, 0.1))
	C.Label(mob, "DropsTitle", "ITEM DROPS", UDim2.fromScale(0.04, 0.49), UDim2.fromScale(0.92, 0.07), true)
	local drops = C.Label(mob, "Drops", "No item drops", UDim2.fromScale(0.04, 0.58), UDim2.fromScale(0.92, 0.38))
	drops.TextYAlignment = Enum.TextYAlignment.Top
	C.Label(detail.Mobs, "Empty", "No creatures have been recorded in this zone yet.", UDim2.new(), UDim2.fromScale(0.96, 0.3))
	return screen
end
end)()

builders.Raids = (function()

return function(parent)
	local screen, _, body = C.Window(parent, "RaidsGUI", "Main", "Something bigger awaits", "Choose a boss and bring your party.", 560, 900)
	local tabs = C.Frame(body, "RaidTypes", UDim2.new(), UDim2.new(1, 0, 0, 48))
	C.Button(tabs, "Standard", "Standard raids", UDim2.new(), UDim2.fromOffset(170, 48), T.Sand)
	local containers = C.Frame(body, "RaidContainers", UDim2.fromOffset(0, 60), UDim2.new(1, 0, 1, -60))
	local list = C.Scroll(containers, "RaidList", UDim2.new(), UDim2.new(0.34, -12, 1, 0))
	C.Responsive(list, UDim2.new(), UDim2.new(0.34, -12, 1, 0), UDim2.new(), UDim2.new(1, 0, 0, 190))
	local display = C.Frame(containers, "RaidDisplay")
	C.Responsive(display, UDim2.fromScale(0.34, 0), UDim2.fromScale(0.66, 1), UDim2.fromOffset(0, 206), UDim2.new(1, 0, 0, 630))
	local clicked = C.Frame(display, "Clicked")
	C.Label(clicked, "Raid", "Select a raid", UDim2.new(), UDim2.new(1, 0, 0, 28), true).TextSize = 22
	local picture = C.Image(clicked, "Picture", UDim2.fromOffset(0, 36), UDim2.new(1, 0, 0, 140))
	picture.BackgroundTransparency = 0
	picture.BackgroundColor3 = T.Sky
	C.Round(picture)
	C.Label(picture, "Warning", "BOSS", UDim2.fromOffset(8, 8), UDim2.fromOffset(64, 24), true).TextColor3 = T.Red
	local info = C.Frame(clicked, "Info", UDim2.fromOffset(0, 182), UDim2.new(1, 0, 0, 30))
	for index, entry in { { "Time", "Best time" }, { "Runs", "Runs" } } do
		local cell = C.Frame(info, entry[1], UDim2.new((index - 1) * 0.5, 0, 0, 0), UDim2.fromScale(0.5, 1))
		C.Label(cell, "Label", entry[2], UDim2.new(), UDim2.fromScale(0.5, 1)).TextSize = 12
		C.Label(cell, entry[1], "--", UDim2.fromScale(0.5, 0), UDim2.fromScale(0.5, 1), true)
	end
	local mode = C.Frame(clicked, "Mode", UDim2.fromOffset(0, 218), UDim2.new(1, 0, 0, 52))
	C.Label(mode, "Current", "Mode: Normal", UDim2.new(), UDim2.new(0.55, 0, 1, 0), true).RichText = true
	local switchFrame = C.Frame(mode, "Frame", UDim2.fromScale(0.55, 0), UDim2.fromScale(0.45, 1))
	C.Button(switchFrame, "Switch", "Change", UDim2.new(), UDim2.new(1, 0, 0, 48), T.Sky)
	C.Label(clicked, "Warning", "Harder enemies. Prepare before entering!", UDim2.fromOffset(0, 274), UDim2.new(1, 0, 0, 32)).TextColor3 = T.Red
	local rewards = C.Frame(clicked, "Rewards", UDim2.fromOffset(0, 310), UDim2.new(1, 0, 0, 128))
	C.Label(rewards, "Label", "LOOT · tap to toggle auto-delete", UDim2.new(), UDim2.new(1, 0, 0, 24)).TextSize = 12
	C.Scroll(rewards, "ScrollingFrame", UDim2.fromOffset(0, 28), UDim2.new(1, 0, 1, -28), 72, 84)
	C.Button(clicked, "Enter", "Enter raid", UDim2.fromOffset(0, 446), UDim2.new(1, 0, 0, 52), T.Sand)
	return screen
end
end)()

builders.Players = (function()

return function(parent)
	local screen = C.Screen(parent, "Playerlist", 14)
	screen.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	local list = C.Round(C.Frame(screen, "List", UDim2.fromScale(1, 0), UDim2.fromScale(0.22, 0.4), T.Paper))
	list.AnchorPoint = Vector2.new(1, 0)
	list:SetAttribute("SideTab", true)
	C.New("UISizeConstraint", "Bounds", list, { MinSize = Vector2.new(220, 200), MaxSize = Vector2.new(320, 360) })
	C.Stroke(list)
	C.Frame(list, "Accent", UDim2.fromScale(0.05, 0), UDim2.fromScale(0.9, 0.012), T.Sky)
	local toggle = C.Button(list, "Toggle", "", UDim2.fromScale(-0.12, 0.02), UDim2.fromScale(0.12, 0.18), T.Sky)
	local arrow = C.Label(toggle, "Arrow", ">", UDim2.fromScale(0.15, 0.2), UDim2.fromScale(0.7, 0.6), true)
	arrow.TextXAlignment = Enum.TextXAlignment.Center
	C.New("UISizeConstraint", "TouchBounds", toggle, { MinSize = Vector2.new(32, 44) })
	local title = C.Label(list, "Title", "ADVENTURERS", UDim2.fromScale(0.06, 0.035), UDim2.fromScale(0.88, 0.09), true)
	title.TextXAlignment = Enum.TextXAlignment.Center
	local heading = C.Round(C.Frame(list, "Columns", UDim2.fromScale(0.04, 0.15), UDim2.fromScale(0.92, 0.09), T.Soft), 6)
	C.Label(heading, "Adventurer", "Adventurer", UDim2.fromScale(0.15, 0.1), UDim2.fromScale(0.57, 0.8), true)
	local levelHeading = C.Label(heading, "Level", "Lvl", UDim2.fromScale(0.75, 0.1), UDim2.fromScale(0.22, 0.8), true)
	levelHeading.TextColor3 = T.Gold
	levelHeading.TextXAlignment = Enum.TextXAlignment.Center
	local container = C.Scroll(list, "Container", UDim2.fromScale(0.035, 0.26), UDim2.fromScale(0.94, 0.71))
	container.UIListLayout.Padding = UDim.new(0.035, 0)
	local row = C.New("TextButton", "EntryTemplate", list, { Text = "", Visible = false, Size = UDim2.fromScale(0.96, 0.2), BackgroundColor3 = T.Surface, AutoButtonColor = true })
	C.Round(row, 6)
	C.Stroke(row)
	C.Gradient(row)
	C.Image(row, "Rank", UDim2.fromScale(0.025, 0.22), UDim2.fromScale(0.11, 0.56))
	local name = C.Label(row, "PlayerName", "Adventurer", UDim2.fromScale(0.15, 0.16), UDim2.fromScale(0.56, 0.68), true)
	name.TextWrapped = false
	name.TextTruncate = Enum.TextTruncate.AtEnd
	C.Frame(row, "Divider", UDim2.fromScale(0.735, 0.2), UDim2.fromScale(0.006, 0.6), T.Soft)
	local level = C.Label(row, "Level", "1", UDim2.fromScale(0.76, 0.18), UDim2.fromScale(0.21, 0.64), true)
	level.TextColor3 = T.Gold
	level.TextXAlignment = Enum.TextXAlignment.Center
	return screen
end
end)()

builders.Party = (function()

return function(parent)
	local screen, _, body = C.Window(parent, "Partylist", "Panel", "Better together", "Invite adventurers from the player list.", 460, 460)
	screen.DisplayOrder = 50
	C.Label(body, "Empty", "No party yet. Open Adventurers to invite a friend.", UDim2.fromOffset(12, 48), UDim2.new(1, -24, 0, 84)).TextColor3 = T.Muted
	C.Scroll(body, "Frame", UDim2.new(), UDim2.new(1, 0, 0, 380))
	C.Button(body, "Leave", "Leave party", UDim2.fromOffset(0, 396), UDim2.new(1, 0, 0, 48), T.Rose).Visible = false
	return screen
end
end)()

builders.Dialogue = (function()

return function(parent)
	local screen, _, body = C.Window(parent, "Dialogue", "Main", "A friendly face", "", 540, 540)
	C.Label(body, "Speaker", "", UDim2.new(), UDim2.new(1, 0, 0, 30), true).TextSize = 21
	C.Label(body, "Text", "", UDim2.fromOffset(0, 40), UDim2.new(1, 0, 0, 160))
	local options = C.Frame(body, "Options", UDim2.fromOffset(0, 216), UDim2.new(1, 0, 0, 316))
	C.List(options)
	return screen
end
end)()

builders.Shop = (function()

return function(parent)
	local screen, _, body = C.Window(parent, "Shop", "Main", "Village shop", "Choose something for your next adventure.", 470, 470)
	C.Scroll(body, "Container", UDim2.new(), UDim2.fromScale(1, 1))
	return screen
end
end)()

builders.Journal = (function()

return function(parent)
	local screen, _, body = C.Window(parent, "Journal", "Main", "Your next adventure", "Quests complete automatically when their objectives are met.", 470, 470)
	C.Scroll(body, "Container", UDim2.new(), UDim2.fromScale(1, 1))
	return screen
end
end)()

builders.Notifications = (function()

return function(parent)
	local screen = C.Screen(parent, "Notifications", 80)
	local container = C.Frame(screen, "Container", UDim2.new(0.5, 0, 0, 12), UDim2.new(1, -24, 0, 200))
	container.AnchorPoint = Vector2.new(0.5, 0)
	C.New("UISizeConstraint", "Bounds", container, { MaxSize = Vector2.new(400, 200) })
	C.List(container)
	return screen
end
end)()

builders.Tutorial = (function()

return function(parent)
	local screen = C.Screen(parent, "Tutorial", 90)
	screen.Enabled = false
	local panel = C.Round(C.Frame(screen, "ImageLabel", UDim2.new(0.5, 0, 1, -12), UDim2.new(1, -24, 0, 220), T.Paper), 18)
	panel.AnchorPoint = Vector2.new(0.5, 1)
	C.New("UISizeConstraint", "Bounds", panel, { MaxSize = Vector2.new(740, 220) })
	C.Stroke(panel)
	local info = C.Frame(panel, "Info", UDim2.fromOffset(16, 12), UDim2.new(1, -32, 1, -24))
	C.Label(info, "Title", "Welcome, adventurer", UDim2.new(), UDim2.new(1, -120, 0, 24), true).TextColor3 = T.Green
	C.Label(info, "TextLabel", "", UDim2.fromOffset(0, 28), UDim2.new(1, 0, 1, -88))
	C.Button(info, "Next", "Continue", UDim2.new(1, -144, 1, -48), UDim2.fromOffset(144, 48))
	C.Button(info, "Skip", "Skip tour", UDim2.new(0, 0, 1, -48), UDim2.fromOffset(112, 48), T.Soft)
	C.Frame(screen, "Open", UDim2.new(), UDim2.new())
	C.Frame(screen, "Closed", UDim2.new(), UDim2.new())
	return screen
end
end)()

builders.StylePreview = (function()

return function(parent)
	local screen, root, body = C.Window(parent, "UIStylePreview", "Main", "RUNE / UI STYLE", "Official component reference · Edit mode only", 620, 620)
	root.Visible = true
	C.Section(body, "ButtonsHeader", "ACTIONS", UDim2.new(), UDim2.new(1, 0, 0, 30))
	for index, entry in { { "Equip", T.Mint }, { "Explore", T.Sky }, { "Remove", T.Rose } } do
		C.Button(body, entry[1], string.upper(entry[1]), UDim2.new((index - 1) / 3, 4, 0, 44), UDim2.new(1 / 3, -12, 0, 48), entry[2])
	end
	C.Input(body, "Search", "Search your items...", UDim2.fromOffset(4, 108), UDim2.new(1, -8, 0, 44))
	C.Section(body, "RaritiesHeader", "ITEM RARITIES", UDim2.fromOffset(0, 174), UDim2.new(1, 0, 0, 30))
	local cards = C.Scroll(body, "Cards", UDim2.fromOffset(4, 216), UDim2.new(1, -8, 0, 268), 106, 116)
	for _, rarity in { "Common", "Uncommon", "Rare", "Legendary", "Godly", "Ascendant" } do
		local card = C.Button(cards, rarity, "", nil, UDim2.fromOffset(106, 116), T.Rarities[rarity])
		card.Rotation = -1.5
		local rune = C.Label(card, "Rune", "◇", UDim2.fromOffset(4, 8), UDim2.new(1, -8, 0, 64), true)
		rune.TextSize = 52
		rune.TextXAlignment = Enum.TextXAlignment.Center
		C.Label(card, "Level", "Lv. 25", UDim2.fromOffset(6, 4), UDim2.new(1, -12, 0, 18), true).TextSize = 10
		local caption = C.Label(card, "Rarity", rarity, UDim2.new(0, 4, 1, -32), UDim2.new(1, -8, 0, 26), true)
		caption.TextSize = 13
		caption.TextXAlignment = Enum.TextXAlignment.Center
	end
	C.Section(body, "StatsHeader", "CHARACTER STATS", UDim2.fromOffset(0, 506), UDim2.new(1, 0, 0, 30))
	local stat = C.Frame(body, "StatRow", UDim2.fromOffset(4, 548), UDim2.new(1, -8, 0, 34), T.Soft)
	C.Label(stat, "Name", "ATTACK", UDim2.fromOffset(12, 0), UDim2.fromScale(0.5, 1), true)
	local amount = C.Label(stat, "Amount", "125", UDim2.fromScale(0.5, 0), UDim2.new(0.5, -12, 1, 0), true)
	amount.TextXAlignment = Enum.TextXAlignment.Right
	amount.TextColor3 = T.Gold
	return screen
end
end)()

builders.Admin = (function()

return function(parent)
	local screen, root, body = C.Window(parent, "Main", "Admin", "ITEM SPAWNER", "Developer tools", 460, 460)
	screen.DisplayOrder = 40
	root.Bounds.MaxSize = Vector2.new(500, 590)
	C.Scroll(body, "ItemList", UDim2.new(), UDim2.new(1, 0, 0, 388))
	C.Button(body, "Spawn", "SPAWN ITEM", UDim2.fromOffset(0, 402), UDim2.new(1, 0, 0, 48), T.Mint)
	return screen
end
end)()

builders.PlayerCard = (function()

return function(parent)
	local screen, root, body = C.Window(parent, "PlayerCard", "Main", "PLAYER PROFILE", "Equipment, progress and combat record", 490, 490)
	root.Bounds.MaxSize = Vector2.new(720, 620)
	C.Label(body, "PlayerName", "Adventurer", UDim2.fromScale(0.02, 0), UDim2.fromScale(0.96, 0.065), true)
	C.Label(body, "Level", "Level 1", UDim2.fromScale(0.02, 0.075), UDim2.fromScale(0.96, 0.045))
	local preview = C.New("ViewportFrame", "Avatar", body, { Position = UDim2.fromScale(0.02, 0.15), Size = UDim2.fromScale(0.4, 0.51), BackgroundColor3 = T.Surface, Ambient = Color3.fromRGB(200, 205, 220), LightColor = Color3.fromRGB(255, 241, 220), LightDirection = Vector3.new(-1, -1, -2) })
	C.Round(preview)
	C.New("WorldModel", "World", preview)
	C.New("Camera", "Camera", preview, { FieldOfView = 32 })
	C.Label(preview, "Status", "Loading avatar...", UDim2.fromScale(0.05, 0.4), UDim2.fromScale(0.9, 0.2))
	local record = C.Frame(body, "Record", UDim2.fromScale(0.46, 0.15), UDim2.fromScale(0.52, 0.51))
	for index, key in { "Gold", "Kills", "Deaths", "PlayTime", "SessionTime" } do
		local row = C.Frame(record, key, UDim2.fromScale(0, (index - 1) * 0.2), UDim2.fromScale(1, 0.17), T.Surface)
		C.Label(row, "Label", key, UDim2.fromScale(0.04, 0.12), UDim2.fromScale(0.48, 0.76))
		C.Label(row, "Value", "--", UDim2.fromScale(0.54, 0.12), UDim2.fromScale(0.42, 0.76), true).TextXAlignment = Enum.TextXAlignment.Right
	end
	local gear = C.Frame(body, "Gear", UDim2.fromScale(0.02, 0.69), UDim2.fromScale(0.96, 0.14))
	for index, key in { "Weapon", "Armor", "Ring", "Necklace", "Aura", "Rune" } do
		local slot = C.Image(gear, key, UDim2.fromScale((index - 1) / 6, 0), UDim2.fromScale(0.15, 0.72))
		slot.BackgroundTransparency = 0
		slot.BackgroundColor3 = T.Surface
		C.Label(slot, "Slot", key, UDim2.fromScale(0, 1.04), UDim2.fromScale(1, 0.32))
	end
	C.Label(body, "Stats", "ATK --   DEF --   HP --   SPD --   CRIT --", UDim2.fromScale(0.02, 0.85), UDim2.fromScale(0.96, 0.055), true)
	C.Button(body, "Invite", "INVITE TO PARTY", UDim2.fromScale(0.52, 0.93), UDim2.fromScale(0.46, 0.07), T.Sky)
	C.Label(body, "Status", "", UDim2.fromScale(0.02, 0.93), UDim2.fromScale(0.47, 0.07))
	return screen
end
end)()

builders.Crafting = (function()

return function(parent)
	local screen, _, body = C.Window(parent, "Crafting", "Main", "Blacksmith crafting", "Turn trophies from the wild into equipment. Craft one at a time.", 600, 560)
	local container = C.Scroll(body, "Container", UDim2.new(), UDim2.fromScale(1, 1))
	local row = C.Frame(screen, "RecipeTemplate", UDim2.new(), UDim2.new(1, -12, 0, 210), T.Paper)
	row.Visible = false
	C.Stroke(row)
	C.Label(row, "Title", "Recipe", UDim2.fromOffset(12, 8), UDim2.new(1, -24, 0, 24), true)
	local description = C.Label(row, "Description", "", UDim2.fromOffset(12, 36), UDim2.new(1, -24, 0, 68))
	description.TextWrapped = true
	description.TextSize = 13
	local cost = C.Label(row, "Cost", "", UDim2.fromOffset(12, 106), UDim2.new(1, -24, 0, 52))
	cost.TextWrapped = true
	cost.TextSize = 13
	C.Button(row, "Craft", "CRAFT", UDim2.new(0, 12, 1, -42), UDim2.new(1, -24, 0, 32), T.Mint)
	return screen
end
end)()

builders.Leaderboards = (function()
return function(parent)
	local screen = C.Screen(parent, "Leaderboards", 1)
	for _, id in { "Gold", "Kills", "Donations", "PlayTime" } do
		local surface = C.New("SurfaceGui", id, screen, {
			Face = Enum.NormalId.Front, SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
			CanvasSize = Vector2.new(700, 900), LightInfluence = 0, AlwaysOnTop = false,
		})
		local models = workspace:FindFirstChild("Leaderboards")
		local model = models and models:FindFirstChild(id)
		local img = model and model:FindFirstChild("IMG", true)
		if img and img:IsA("BasePart") then surface.Adornee = img end
		local main = C.Frame(surface, "Main", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1))
		C.Label(main, "Status", "Loading rankings...", UDim2.fromScale(0.04, 0.02), UDim2.fromScale(0.92, 0.045)).TextScaled = true
		C.Scroll(main, "Rows", UDim2.fromScale(0.04, 0.085), UDim2.fromScale(0.92, 0.895))
		local row = C.Frame(main, "RowTemplate", UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.1), T.Surface)
		row.Visible = false
		C.New("UICorner", "UICorner", row, { CornerRadius = UDim.new(0.16, 0) })
		C.Stroke(row)
		C.Gradient(row)
		local accent = ({ Gold = T.Gold, Kills = T.Rose, Donations = T.Purple, PlayTime = T.Sky })[id]
		local badge = C.Frame(row, "RankBadge", UDim2.fromScale(0.018, 0.15), UDim2.fromScale(0.12, 0.7), T.Paper)
		C.New("UICorner", "UICorner", badge, { CornerRadius = UDim.new(0.22, 0) })
		C.Stroke(badge, T.Line)
		C.Gradient(badge)
		local valueBox = C.Frame(row, "ValueBadge", UDim2.fromScale(0.685, 0.16), UDim2.fromScale(0.295, 0.68), T.Paper)
		C.New("UICorner", "UICorner", valueBox, { CornerRadius = UDim.new(0.2, 0) })
		C.Stroke(valueBox, T.Line)
		local line = C.Frame(row, "Accent", UDim2.fromScale(0.16, 0.73), UDim2.fromScale(0.075, 0.055), accent)
		C.New("UICorner", "UICorner", line, { CornerRadius = UDim.new(0.5, 0) })
		for _, entry in { { "Rank", "#1", 0.025, 0.105 }, { "Username", "Adventurer", 0.16, 0.50 }, { "Value", "0", 0.705, 0.255 } } do
			local text = C.Label(row, entry[1], entry[2], UDim2.fromScale(entry[3], 0.24), UDim2.fromScale(entry[4], 0.48), true)
			text.TextScaled = true
			text.TextWrapped = false
			text.TextTruncate = Enum.TextTruncate.AtEnd
			text.ZIndex = 2
			if entry[1] ~= "Username" then text.TextXAlignment = Enum.TextXAlignment.Center end
			if entry[1] == "Value" then text.TextColor3 = accent end
		end
	end
	return screen
end
end)()

builders.LootRewards = (function()
return function(parent)
	local screen = C.Screen(parent, "LootRewards", 24)
	local card = C.New("CanvasGroup", "Card", screen, {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.76), Size = UDim2.fromScale(0.38, 0.15), BackgroundColor3 = Color3.fromRGB(32, 38, 44), Visible = false})
	C.Round(card); C.Stroke(card)
	C.New("UIScale", "Pop", card, {Scale = 1})
	C.New("UISizeConstraint", "Bounds", card, {MaxSize = Vector2.new(480, 130), MinSize = Vector2.new(270, 90)})
	C.Image(card, "Icon", UDim2.fromScale(0.035, 0.13), UDim2.fromScale(0.18, 0.74))
	C.Label(card, "Rarity", "RARE DROP", UDim2.fromScale(0.25, 0.08), UDim2.fromScale(0.7, 0.19), true)
	C.Label(card, "ItemName", "Dire Claw", UDim2.fromScale(0.25, 0.32), UDim2.fromScale(0.7, 0.32), true)
	C.Label(card, "Amount", "+1 • Added to inventory", UDim2.fromScale(0.25, 0.72), UDim2.fromScale(0.7, 0.18))
	local shine = C.Frame(card, "Shine", UDim2.fromScale(-0.3, 0), UDim2.fromScale(0.13, 1), Color3.fromRGB(255, 255, 255))
	shine.BackgroundTransparency = 0.8; shine.Rotation = 18; shine.ZIndex = 4
	local spark = C.Frame(screen, "Spark", UDim2.new(), UDim2.fromScale(0.006, 0.01), Color3.fromRGB(255, 255, 255))
	spark.Visible = false; spark.AnchorPoint = Vector2.new(0.5, 0.5)
	return screen
end
end)()

local staging = Instance.new("Folder")
local generated = {}
local ok, reason = pcall(function()

    table.insert(generated, { Object = builders.Templates(staging), Target = ReplicatedStorage })

    table.insert(generated, { Object = builders.Loading(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.HUD(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.Navigation(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.Combat(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.Inventory(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.Skills(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.Zones(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.Raids(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.Players(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.Party(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.Dialogue(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.Shop(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.Journal(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.Notifications(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.Tutorial(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.StylePreview(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.Admin(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.PlayerCard(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.Crafting(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.Leaderboards(staging), Target = StarterGui })

    table.insert(generated, { Object = builders.LootRewards(staging), Target = StarterGui })

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
