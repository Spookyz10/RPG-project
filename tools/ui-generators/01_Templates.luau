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
	local zoneImage = C.Image(zone, "Image", UDim2.fromOffset(10, 10), UDim2.fromOffset(64, 64))
	C.Stroke(zoneImage)
	local area = C.Label(zone, "AreaName", "Zone", UDim2.fromOffset(84, 10), UDim2.new(1, -94, 0, 48), true)
	C.New("UIGradient", "UIGradient", area)
	C.Label(zone, "LevelReq", "Lv. 1", UDim2.fromOffset(84, 58), UDim2.new(1, -94, 0, 25)).TextSize = 12
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

	local mob = C.New("BillboardGui", "MobOverhead", folder, { Size = UDim2.fromOffset(180, 52), StudsOffset = Vector3.new(0, 3.5, 0), AlwaysOnTop = true, MaxDistance = 85 })
	local mobInfo = C.Frame(mob, "Info", UDim2.new(), UDim2.new(1, 0, 0, 26))
	local mobName = C.Label(mobInfo, "MobName", "Mob", nil, UDim2.fromScale(1, 1), true)
	mobName.TextColor3 = T.Ink
	mobName.TextXAlignment = Enum.TextXAlignment.Center
	C.New("UIStroke", "UIStroke", mobName, { Color = T.Ink, Thickness = 1.5 })
	local hp = C.Round(C.Frame(mob, "HP", UDim2.fromOffset(0, 30), UDim2.new(1, 0, 0, 20), T.Paper), 7)
	hp.ClipsDescendants = true
	C.Round(C.Frame(hp, "Bar", UDim2.new(), UDim2.fromScale(1, 1), T.Mint), 7)
	local health = C.Label(hp, "Health", "", nil, UDim2.fromScale(1, 1), true)
	health.TextSize = 11
	health.TextXAlignment = Enum.TextXAlignment.Center
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
-- Loading/tutorial are enabled by their client controllers, not while editing.
for _, name in { "LoadingScreen", "Tutorial", "UIStylePreview" } do
    local screen = StarterGui:FindFirstChild(name)
    if screen then screen.Enabled = preferred == name end
end
if selected then Selection:Set({ selected }) end
if recording then History:FinishRecording(recording, Enum.FinishRecordingOperation.Commit) end
print("RPG UI saved as editable instances. Save the place before Play. Backups: ServerStorage.RPGUIBackups")
