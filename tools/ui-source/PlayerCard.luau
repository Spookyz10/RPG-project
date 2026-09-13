local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

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
