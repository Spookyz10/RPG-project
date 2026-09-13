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
		end
		for _, child in object:GetChildren() do visit(child, wide, narrow) end
	end
	local reference = root:IsA("ScreenGui") and Vector2.new(1280, 720) or Vector2.new(400, 470)
	visit(root, reference, root:IsA("ScreenGui") and Vector2.new(390, 760) or reference)
end

return C
end)()
local build = (function()

return function(parent)
	local effect = C.New("CanvasGroup", "LevelUpFeedback", parent, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.46),
		Size = UDim2.fromScale(0.58, 0.28),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 150,
	})

	local glow = C.Round(C.Frame(effect, "Glow", UDim2.fromScale(0.36, 0.3), UDim2.fromScale(0.28, 0.4), T.Gold), 10)
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.BackgroundTransparency = 0.58
	glow.ZIndex = 151
	glow:SetAttribute("StartSize", UDim2.fromScale(0.12, 0.18))
	glow:SetAttribute("EndSize", UDim2.fromScale(0.78, 0.92))

	for index, rotation in { -35, 0, 35 } do
		local ray = C.Round(C.Frame(effect, "Ray" .. index, UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.5, 0.018), T.Gold), 8)
		ray.AnchorPoint = Vector2.new(0.5, 0.5)
		ray.Rotation = rotation
		ray.BackgroundTransparency = 0.34
		ray.ZIndex = 152
		ray:SetAttribute("EndSize", UDim2.fromScale(1.12, 0.018))
	end

	local ribbon = C.Round(C.Frame(effect, "Ribbon", UDim2.fromScale(0.18, 0.39), UDim2.fromScale(0.64, 0.24), T.Paper), 10)
	ribbon.ZIndex = 154
	C.Stroke(ribbon, T.Gold).Thickness = 3
	local topRule = C.Round(C.Frame(ribbon, "TopRule", UDim2.fromScale(0.16, 0.1), UDim2.fromScale(0.68, 0.04), T.Gold), 6)
	topRule.ZIndex = 155
	local title = C.Label(ribbon, "Title", "LEVEL UP!", UDim2.fromScale(0.04, 0.18), UDim2.fromScale(0.92, 0.43), true)
	title.TextColor3 = T.Gold
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.TextSize = 42
	title.ZIndex = 156
	local subtitle = C.Label(ribbon, "Subtitle", "A NEW CHAPTER BEGINS", UDim2.fromScale(0.04, 0.62), UDim2.fromScale(0.92, 0.2), true)
	subtitle.TextColor3 = T.Muted
	subtitle.TextXAlignment = Enum.TextXAlignment.Center
	subtitle.TextSize = 13
	subtitle.ZIndex = 156

	for index = 1, 14 do
		local angle = math.pi * 2 * index / 14
		local particle = C.Round(C.Frame(effect, "Spark" .. index, UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.018, 0.035), index % 2 == 0 and T.Gold or T.Ink), 8)
		particle.AnchorPoint = Vector2.new(0.5, 0.5)
		particle.Rotation = index * 25
		particle.ZIndex = 157
		particle:SetAttribute("EndPosition", UDim2.fromScale(0.5 + math.cos(angle) * 0.43, 0.5 + math.sin(angle) * 0.34))
		particle:SetAttribute("EndSize", UDim2.fromScale(0.004, 0.008))
	end

	local pop = C.New("UIScale", "Pop", effect, { Scale = 1 })
	pop:SetAttribute("StartScale", 0.52)
	return effect
end
end)()
local templates = ReplicatedStorage:FindFirstChild("RPGUITemplates")
if not templates then
    templates = Instance.new("Folder")
    templates.Name = "RPGUITemplates"
    templates.Parent = ReplicatedStorage
end

local replacement = build(nil)
local targetName = "LevelUpFeedback"
local old = templates:FindFirstChild(targetName)
if old then
    local backups = ServerStorage:FindFirstChild("RPGUIBackups")
    if not backups then
        backups = Instance.new("Folder")
        backups.Name = "RPGUIBackups"
        backups.Parent = ServerStorage
    end
    local backup = Instance.new("Folder")
    backup.Name = targetName .. "_" .. os.date("%Y-%m-%d_%H-%M-%S")
    backup.Parent = backups
    old.Parent = backup
end
replacement.Parent = templates
Selection:Set({ replacement })
print(targetName .. " upgraded. Only this template changed; the prior version is in ServerStorage.RPGUIBackups.")
