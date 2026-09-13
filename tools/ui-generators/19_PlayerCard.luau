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

local builders = {}

builders.PlayerCard = (function()

local STATS = {
	{ "Attack", "ATK", T.Red },
	{ "Defense", "DEF", T.Blue },
	{ "Health", "HP", T.Green },
	{ "Speed", "SPD", T.Gold },
	{ "Critical", "CRIT", T.Purple },
}

local function meter(parent, color)
	local progress = C.Round(C.Frame(parent, "Progress", UDim2.fromScale(0.035, 0.6), UDim2.fromScale(0.93, 0.27), T.Paper), 5)
	progress.ClipsDescendants = true
	local fill = C.Round(C.Frame(progress, "Fill", UDim2.new(), UDim2.fromScale(0, 1), color), 5)
	fill:SetAttribute("DynamicProgress", true)
	local potion = C.Label(progress, "Potion", "POTIONS  0/10  |  10 TO MAX", UDim2.fromScale(0.03, 0), UDim2.fromScale(0.94, 1), true)
	potion.TextSize = 10
	potion.TextXAlignment = Enum.TextXAlignment.Center
	return progress
end

local function gearSlot(parent, name, order)
	local slot = C.Round(C.Frame(parent, name, nil, nil, T.Paper), 7)
	slot.LayoutOrder = order
	C.Stroke(slot, T.Line).Thickness = 2
	C.Image(slot, "Icon", UDim2.fromScale(0.16, 0.08), UDim2.fromScale(0.68, 0.62))
	local label = C.Label(slot, "Slot", string.upper(name), UDim2.fromScale(0.04, 0.72), UDim2.fromScale(0.92, 0.23), true)
	label.TextSize = 8
	label.TextXAlignment = Enum.TextXAlignment.Center
	return slot
end

return function(parent)
	local screen, root, body = C.Window(parent, "PlayerCard", "Main", "ADVENTURER DOSSIER", "Inspect their build, progress and battle record", 520, 620)
	root.Bounds.MaxSize = Vector2.new(800, 680)

	local profile = C.Round(C.Frame(body, "Profile", UDim2.fromScale(0, 0), UDim2.fromScale(0.35, 0.89), T.Surface), 10)
	C.Stroke(profile)
	C.Frame(profile, "Accent", UDim2.fromScale(0.04, 0.015), UDim2.fromScale(0.92, 0.012), T.Purple)
	local playerName = C.Label(profile, "PlayerName", "Adventurer", UDim2.fromScale(0.055, 0.035), UDim2.fromScale(0.89, 0.075), true)
	playerName.TextSize = 20
	playerName.TextXAlignment = Enum.TextXAlignment.Center
	local level = C.Round(C.Frame(profile, "LevelBadge", UDim2.fromScale(0.24, 0.115), UDim2.fromScale(0.52, 0.065), T.Purple), 8)
	C.Label(level, "Level", "LEVEL 1", nil, UDim2.fromScale(1, 1), true).TextXAlignment = Enum.TextXAlignment.Center

	local preview = C.New("ViewportFrame", "Avatar", profile, {
		Position = UDim2.fromScale(0.06, 0.195),
		Size = UDim2.fromScale(0.88, 0.43),
		BackgroundColor3 = T.Paper,
		Ambient = Color3.fromRGB(200, 205, 220),
		LightColor = Color3.fromRGB(255, 241, 220),
		LightDirection = Vector3.new(-1, -1, -2),
	})
	C.Round(preview, 9)
	C.Stroke(preview, T.Line).Thickness = 2
	C.New("WorldModel", "World", preview)
	local camera = C.New("Camera", "Camera", preview, { FieldOfView = 32 })
	preview.CurrentCamera = camera
	local avatarStatus = C.Label(preview, "Status", "Loading avatar...", UDim2.fromScale(0.05, 0.4), UDim2.fromScale(0.9, 0.2))
	avatarStatus.TextXAlignment = Enum.TextXAlignment.Center
	avatarStatus.TextColor3 = T.Muted

	local gearHeader = C.Section(profile, "GearHeader", "EQUIPPED GEAR", UDim2.fromScale(0.04, 0.645), UDim2.fromScale(0.92, 0.065))
	gearHeader.Title.TextSize = 12
	local gear = C.Frame(profile, "Gear", UDim2.fromScale(0.055, 0.73), UDim2.fromScale(0.89, 0.245))
	C.New("UIGridLayout", "Grid", gear, {
		CellSize = UDim2.fromScale(0.29, 0.43),
		CellPadding = UDim2.fromScale(0.065, 0.1),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	for index, name in { "Weapon", "Armor", "Ring", "Necklace", "Aura", "Rune" } do
		gearSlot(gear, name, index)
	end

	local details = C.Frame(body, "Details", UDim2.fromScale(0.37, 0), UDim2.fromScale(0.63, 0.89))
	local record = C.Round(C.Frame(details, "Record", nil, UDim2.fromScale(1, 0.245), T.Surface), 10)
	C.Stroke(record)
	local recordHeader = C.Section(record, "Header", "ADVENTURE RECORD", UDim2.fromScale(0.025, 0.045), UDim2.fromScale(0.95, 0.2))
	recordHeader.Title.TextSize = 12
	local recordGrid = C.Frame(record, "Grid", UDim2.fromScale(0.025, 0.29), UDim2.fromScale(0.95, 0.65))
	C.New("UIGridLayout", "Layout", recordGrid, {
		CellSize = UDim2.fromScale(0.31, 0.44),
		CellPadding = UDim2.fromScale(0.035, 0.1),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	for index, entry in { { "Gold", "GOLD" }, { "Kills", "KILLS" }, { "Deaths", "DEATHS" }, { "PlayTime", "PLAY TIME" }, { "SessionTime", "SESSION" } } do
		local key = entry[1]
		local row = C.Round(C.Frame(recordGrid, key, nil, nil, T.Paper), 6)
		row.LayoutOrder = index
		local label = C.Label(row, "Label", entry[2], UDim2.fromScale(0.04, 0.08), UDim2.fromScale(0.92, 0.35), true)
		label.TextSize = 8
		label.TextColor3 = T.Muted
		label.TextXAlignment = Enum.TextXAlignment.Center
		local value = C.Label(row, "Value", "--", UDim2.fromScale(0.04, 0.42), UDim2.fromScale(0.92, 0.5), true)
		value.TextSize = 13
		value.TextXAlignment = Enum.TextXAlignment.Center
	end

	local statsPanel = C.Round(C.Frame(details, "StatsPanel", UDim2.fromScale(0, 0.275), UDim2.fromScale(1, 0.725), T.Surface), 10)
	C.Stroke(statsPanel)
	local statsHeader = C.Section(statsPanel, "Header", "ATTRIBUTES & POTION MASTERY", UDim2.fromScale(0.025, 0.018), UDim2.fromScale(0.95, 0.09))
	statsHeader.Title.TextSize = 12
	local stats = C.Frame(statsPanel, "Rows", UDim2.fromScale(0.025, 0.125), UDim2.fromScale(0.95, 0.85))
	C.List(stats, false, 5)
	for index, entry in STATS do
		local row = C.Round(C.Frame(stats, entry[1], nil, UDim2.new(1, 0, 0, 48), T.Soft), 7)
		row.LayoutOrder = index
		C.Frame(row, "Mark", UDim2.fromScale(0, 0.12), UDim2.fromScale(0.012, 0.76), entry[3])
		local label = C.Label(row, "Label", entry[2], UDim2.fromScale(0.035, 0.07), UDim2.fromScale(0.28, 0.42), true)
		label.TextSize = 12
		local value = C.Label(row, "Value", "--", UDim2.fromScale(0.66, 0.07), UDim2.fromScale(0.3, 0.42), true)
		value.TextSize = 13
		value.TextColor3 = entry[3]
		value.TextXAlignment = Enum.TextXAlignment.Right
		meter(row, entry[3])
	end

	local actions = C.Frame(body, "Actions", UDim2.fromScale(0, 0.915), UDim2.fromScale(1, 0.085))
	local status = C.Label(actions, "Status", "", UDim2.fromScale(0.01, 0), UDim2.fromScale(0.43, 1))
	status.TextSize = 11
	status.TextColor3 = T.Muted
	C.Button(actions, "Invite", "INVITE TO PARTY", UDim2.fromScale(0.46, 0.08), UDim2.fromScale(0.35, 0.84), T.Sky)
	C.Button(actions, "Trade", "TRADE", UDim2.fromScale(0.83, 0.08), UDim2.fromScale(0.16, 0.84), T.Gold)
	return screen
end
end)()

local staging = Instance.new("Folder")
local generated = {}
local ok, reason = pcall(function()

    table.insert(generated, { Object = builders.PlayerCard(staging), Target = StarterGui })

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

local preferred = "PlayerCard"

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
