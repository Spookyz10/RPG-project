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
	local toast = (function()

return function(parent)
	local toast = C.New("CanvasGroup", "ToastTemplate", parent, {
		Size = UDim2.new(1, 0, 0, 66),
		BackgroundColor3 = T.Surface,
		ClipsDescendants = true,
		Visible = false,
	})
	C.Round(toast, 10)
	C.Stroke(toast, T.Gold)

	C.Frame(toast, "Accent", UDim2.fromScale(0, 0), UDim2.fromScale(0.018, 1), T.Gold)
	local message = C.Label(toast, "Message", "", UDim2.fromScale(0.07, 0.08), UDim2.fromScale(0.86, 0.68), true)
	message.TextXAlignment = Enum.TextXAlignment.Center
	message.TextSize = 14

	local shine = C.Frame(toast, "Shine", UDim2.fromScale(-0.35, 0), UDim2.fromScale(0.24, 1), T.Highlight)
	shine:SetAttribute("EndPosition", UDim2.fromScale(1.2, 0))
	shine.BackgroundTransparency = 0.78
	shine.Rotation = 18
	local pop = C.New("UIScale", "Pop", toast, { Scale = 1 })
	pop:SetAttribute("StartScale", 0.82)
	return toast
end
end)()(folder)
	local buildFeedbackTemplates = (function()

local function skillTemplate(parent)
	local root = C.New("CanvasGroup", "Skill", parent, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(2.8, 3.15),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 200,
	})
	local pulse = C.Round(C.Frame(root, "Pulse", UDim2.fromScale(0.39, 0.4), UDim2.fromScale(0.22, 0.2), T.Sky), 10)
	pulse.BackgroundTransparency = 0.72
	pulse.ZIndex = 201
	pulse:SetAttribute("EndSize", UDim2.fromScale(0.72, 0.64))
	pulse:SetAttribute("EndPosition", UDim2.fromScale(0.14, 0.18))
	local border = C.Stroke(pulse, T.Ink)
	border.Thickness = 3
	local echo = C.Image(root, "Echo", UDim2.fromScale(0.4, 0.4), UDim2.fromScale(0.2, 0.2))
	echo.ZIndex = 202
	echo:SetAttribute("EndPosition", UDim2.fromScale(0.325, 0.14))
	echo:SetAttribute("EndSize", UDim2.fromScale(0.35, 0.35))
	local title = C.Label(root, "Title", "SKILL", UDim2.fromScale(0.05, 0.22), UDim2.fromScale(0.9, 0.13), true)
	title.ZIndex = 203
	title.TextColor3 = T.Sky
	title.TextXAlignment = Enum.TextXAlignment.Center
	title:SetAttribute("EndPosition", UDim2.fromScale(0.05, 0.08))
	for index = 1, 8 do
		local angle = math.pi * 2 * index / 8
		local particle = C.Round(C.Frame(root, "Particle" .. index, UDim2.fromScale(0.48, 0.47), UDim2.fromScale(0.04, 0.04), index % 2 == 0 and T.Sky or T.Ink), 10)
		particle.AnchorPoint = Vector2.new(0.5, 0.5)
		particle.Rotation = 45
		particle.ZIndex = 204
		particle:SetAttribute("EndPosition", UDim2.fromScale(0.5 + math.cos(angle) * 0.3, 0.49 + math.sin(angle) * 0.27))
		particle:SetAttribute("EndSize", UDim2.fromScale(0.012, 0.012))
	end
	return root
end

local function banner(parent, name, color, detail)
	local card = C.New("CanvasGroup", name, parent, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.62),
		Size = UDim2.fromScale(0.24, 0.085),
		BackgroundColor3 = T.Paper,
		BackgroundTransparency = 0.08,
		Visible = false,
		ZIndex = 201,
	})
	card:SetAttribute("BasePosition", card.Position)
	card:SetAttribute("EntryOffset", UDim2.fromScale(0, 0.08))
	card:SetAttribute("ExitOffset", UDim2.fromScale(0, -0.04))
	card:SetAttribute("StackSpacing", 0.095)
	C.New("UISizeConstraint", "Bounds", card, { MinSize = Vector2.new(250, 56), MaxSize = Vector2.new(310, 64) })
	C.Round(card, 10)
	C.Stroke(card, color)
	local accent = C.Round(C.Frame(card, "Accent", UDim2.fromScale(0.022, 0.1), UDim2.fromScale(0.022, 0.8), color), 10)
	accent.ZIndex = 202
	local title = C.Label(card, "Title", name, UDim2.fromScale(0.09, 0.08), UDim2.fromScale(0.87, 0.43), true)
	title.ZIndex = 203
	title.TextColor3 = color
	local subtitle = C.Label(card, "Detail", detail, UDim2.fromScale(0.09, 0.52), UDim2.fromScale(0.87, 0.3))
	subtitle.ZIndex = 203
	subtitle.TextColor3 = T.Muted
	local pop = C.New("UIScale", "Pop", card, { Scale = 1 })
	pop:SetAttribute("StartScale", 0.72)
	return card
end

return function(parent)
	local folder = C.New("Folder", "FeedbackTemplates", parent)
	skillTemplate(folder)
	banner(folder, "Passive", T.Gold, "PASSIVE TRIGGERED")
	banner(folder, "Buff", T.Green, "BUFF ACTIVE")
	banner(folder, "Debuff", T.Red, "NEGATIVE EFFECT APPLIED")
	return folder
end
end)()
buildFeedbackTemplates(folder)
	(function()

return function(parent)
	local prompt = C.New("BillboardGui", "NPCInteractionTemplate", parent, {
		Size = UDim2.fromScale(4.6, 1.18),
		StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0),
		AlwaysOnTop = true,
		ResetOnSpawn = false,
		LightInfluence = 0,
		Enabled = false,
	})
	local main = C.Round(C.New("CanvasGroup", "Main", prompt, {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = T.Paper,
		GroupTransparency = 0,
	}), 14)
	C.Stroke(main, T.Line).Thickness = 3
	C.New("UIScale", "PromptScale", main, { Scale = 1 })
	local accent = C.Round(C.Frame(main, "Accent", UDim2.fromScale(0.027, 0.145), UDim2.fromScale(0.017, 0.711), T.Gold), 3)
	accent.ZIndex = main.ZIndex + 1
	local name = C.Label(main, "NPCName", "Friendly face", UDim2.fromScale(0.08, 0.118), UDim2.fromScale(0.64, 0.355), true)
	name.TextColor3 = T.Gold
	name.TextSize = 16
	local action = C.Label(main, "Action", "Talk", UDim2.fromScale(0.08, 0.5), UDim2.fromScale(0.64, 0.316))
	action.TextColor3 = T.Muted
	action.TextSize = 12
	local key = C.Round(C.Label(main, "Key", "F", UDim2.fromScale(0.773, 0.197), UDim2.fromScale(0.173, 0.605), true), 10)
	key.BackgroundColor3 = T.Sky
	key.BackgroundTransparency = 0
	key.TextXAlignment = Enum.TextXAlignment.Center
	key.TextSize = 19
	C.Stroke(key, T.Ink).Thickness = 2
	local tap = C.New("TextButton", "Tap", main, {
		Text = "",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		ZIndex = key.ZIndex + 2,
	})
	return prompt
end
end)()(folder)
	C.Label(folder, "EmptyTemplate", "", nil, UDim2.new(1, -8, 0, 120)).TextColor3 = T.Muted
	C.Button(folder, "DialogueChoiceTemplate", "Continue", nil, UDim2.new(1, -8, 0, 52), T.Sky)
	C.Button(folder, "AdminItemTemplate", "Item", nil, UDim2.new(1, -8, 0, 48), T.Soft)
	return folder
end
end)()

local staging = Instance.new("Folder")
local generated = {}
local ok, reason = pcall(function()

    table.insert(generated, { Object = builders.Templates(staging), Target = ReplicatedStorage })

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

local preferred = "RPGUITemplates"

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
