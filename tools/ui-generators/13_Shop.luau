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

builders.Shop = (function()

return function(parent)
	local screen = C.Screen(parent, "Shop", 30)

	local backdrop = C.New("TextButton", "Backdrop", screen, {
		Text = "",
		Position = UDim2.new(),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = T.Line,
		BackgroundTransparency = 0.28,
		AutoButtonColor = false,
		Active = true,
		Modal = true,
		Visible = false,
	})

	local shadow = C.Round(C.Frame(screen, "Shadow", UDim2.fromScale(0.507, 0.51), UDim2.fromScale(0.94, 0.84), T.Line), 18)
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.BackgroundTransparency = 0.35
	shadow.Visible = false
	C.New("UISizeConstraint", "Bounds", shadow, {
		MinSize = Vector2.new(300, 400),
		MaxSize = Vector2.new(980, 640),
	})

	local root = C.Round(C.Frame(screen, "Main", UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.94, 0.84), T.Paper), 18)
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Visible = false
	root.Active = true
	root.ClipsDescendants = true
	root:SetAttribute("Window", true)
	C.Stroke(root, T.Line).Thickness = 4
	C.New("UISizeConstraint", "Bounds", root, {
		MinSize = Vector2.new(300, 400),
		MaxSize = Vector2.new(980, 640),
	})

	local header = C.Frame(root, "Header", UDim2.new(), UDim2.fromScale(1, 0.19), Color3.fromRGB(38, 43, 55))
	local headerGradient = C.New("UIGradient", "HeaderGradient", header, { Rotation = 18 })
	headerGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 114, 92)),
		ColorSequenceKeypoint.new(0.55, Color3.fromRGB(37, 67, 83)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(37, 40, 51)),
	})

	local crest = C.Round(C.Frame(root, "Crest", UDim2.fromScale(0.03, 0.045), UDim2.fromScale(0.075, 0.1), T.Gold), 12)
	C.Stroke(crest, T.Line).Thickness = 2
	local crestText = C.Label(crest, "Mark", "$", UDim2.fromScale(0.18, 0.08), UDim2.fromScale(0.64, 0.84), true)
	crestText.TextColor3 = T.Line
	crestText.TextStrokeTransparency = 1
	crestText.TextXAlignment = Enum.TextXAlignment.Center
	crestText.TextSize = 24

	local eyebrow = C.Label(root, "Eyebrow", "TRAVELER'S SUPPLY", UDim2.fromScale(0.125, 0.04), UDim2.fromScale(0.34, 0.035), true)
	eyebrow.TextColor3 = T.Gold
	eyebrow.TextSize = 11
	eyebrow.TextWrapped = false

	local heading = C.Label(root, "Heading", "Village Shop", UDim2.fromScale(0.125, 0.073), UDim2.fromScale(0.62, 0.055), true)
	heading.TextSize = 30
	heading.TextWrapped = false
	heading.TextTruncate = Enum.TextTruncate.AtEnd
	C.New("UITextSizeConstraint", "TextBounds", heading, { MinTextSize = 17, MaxTextSize = 30 })

	local subtitle = C.Label(root, "Subtitle", "Stock up before your next adventure.", UDim2.fromScale(0.125, 0.128), UDim2.fromScale(0.7, 0.035))
	subtitle.TextColor3 = T.Muted
	subtitle.TextSize = 13
	subtitle.TextWrapped = false
	subtitle.TextTruncate = Enum.TextTruncate.AtEnd

	local close = C.Button(root, "Close", "X", UDim2.fromScale(0.92, 0.055), UDim2.fromScale(0.055, 0.085), T.Rose)
	close:SetAttribute("CloseWindow", true)
	close.TextSize = 18
	close.ZIndex = 3

	local body = C.Frame(root, "Body", UDim2.fromScale(0.025, 0.215), UDim2.fromScale(0.95, 0.75))
	local content = C.Frame(body, "Content", UDim2.new(), UDim2.fromScale(1, 1))

	local sectionTitle = C.Label(content, "SectionTitle", "AVAILABLE STOCK", UDim2.fromScale(0.008, 0), UDim2.fromScale(0.45, 0.06), true)
	sectionTitle.TextColor3 = T.Muted
	sectionTitle.TextSize = 12
	sectionTitle.TextWrapped = false

	local stockCount = C.Round(C.Label(content, "StockCount", "0 ITEMS", UDim2.fromScale(0.84, 0.005), UDim2.fromScale(0.145, 0.05), true), 8)
	stockCount.BackgroundTransparency = 0
	stockCount.BackgroundColor3 = T.Soft
	stockCount.TextColor3 = T.Muted
	stockCount.TextStrokeTransparency = 1
	stockCount.TextXAlignment = Enum.TextXAlignment.Center
	stockCount.TextSize = 11

	local rule = C.Frame(content, "Rule", UDim2.fromScale(0.008, 0.065), UDim2.fromScale(0.977, 0.005), T.Soft)
	rule.BackgroundTransparency = 0.35

	local container = C.New("ScrollingFrame", "Container", content, {
		Position = UDim2.fromScale(0, 0.09),
		Size = UDim2.fromScale(1, 0.91),
		BackgroundTransparency = 1,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = T.Mint,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	})
	C.New("UIPadding", "Padding", container, {
		PaddingTop = UDim.new(0.012, 0),
		PaddingLeft = UDim.new(0.008, 0),
		PaddingRight = UDim.new(0.018, 0),
		PaddingBottom = UDim.new(0.025, 0),
	})
	C.New("UIListLayout", "UIListLayout", container, {
		Padding = UDim.new(0.025, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	return screen
end
end)()

local staging = Instance.new("Folder")
local generated = {}
local ok, reason = pcall(function()

    table.insert(generated, { Object = builders.Shop(staging), Target = StarterGui })

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

local preferred = "Shop"

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
