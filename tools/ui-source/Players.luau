local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen = C.Screen(parent, "Playerlist", 14)
	screen.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	local list = C.Round(C.Frame(screen, "List", UDim2.fromScale(1, 0.03), UDim2.fromScale(0.255, 0.5), T.Paper))
	list.AnchorPoint = Vector2.new(1, 0)
	list:SetAttribute("SideTab", true)
	list:SetAttribute("ExpandedPosition", UDim2.fromScale(1, 0.03))
	list:SetAttribute("CollapsedPosition", UDim2.fromScale(1.22, 0.03))
	C.New("UISizeConstraint", "Bounds", list, { MinSize = Vector2.new(260, 250), MaxSize = Vector2.new(390, 460) })
	C.Stroke(list)
	C.Frame(list, "Accent", UDim2.fromScale(0.05, 0), UDim2.fromScale(0.9, 0.012), T.Sky)
	local toggle = C.Button(list, "Toggle", "", UDim2.fromScale(-0.12, 0.02), UDim2.fromScale(0.12, 0.18), T.Sky)
	local arrow = C.Label(toggle, "Arrow", ">", UDim2.fromScale(0.15, 0.2), UDim2.fromScale(0.7, 0.6), true)
	arrow.TextXAlignment = Enum.TextXAlignment.Center
	arrow:SetAttribute("ExpandedRotation", 0)
	arrow:SetAttribute("CollapsedRotation", 180)
	C.New("UISizeConstraint", "TouchBounds", toggle, { MinSize = Vector2.new(32, 44) })
	local title = C.Label(list, "Title", "ADVENTURERS", UDim2.fromScale(0.06, 0.03), UDim2.fromScale(0.88, 0.09), true)
	title.TextXAlignment = Enum.TextXAlignment.Center
	C.Label(list, "Subtitle", "Inspect gear, records and party status", UDim2.fromScale(0.07, 0.11), UDim2.fromScale(0.86, 0.05)).TextColor3 = T.Muted
	local heading = C.Round(C.Frame(list, "Columns", UDim2.fromScale(0.04, 0.18), UDim2.fromScale(0.92, 0.08), T.Soft), 6)
	C.Label(heading, "Adventurer", "Adventurer", UDim2.fromScale(0.15, 0.1), UDim2.fromScale(0.57, 0.8), true)
	local levelHeading = C.Label(heading, "Level", "Lvl", UDim2.fromScale(0.75, 0.1), UDim2.fromScale(0.22, 0.8), true)
	levelHeading.TextColor3 = T.Gold
	levelHeading.TextXAlignment = Enum.TextXAlignment.Center
	local container = C.Scroll(list, "Container", UDim2.fromScale(0.035, 0.29), UDim2.fromScale(0.94, 0.67))
	container.UIListLayout.Padding = UDim.new(0.035, 0)
	local row = C.New("TextButton", "EntryTemplate", list, { Text = "", Visible = false, Size = UDim2.fromScale(0.96, 0.23), BackgroundColor3 = T.Surface, AutoButtonColor = true })
	C.Round(row, 9)
	C.Stroke(row)
	C.Gradient(row)
	C.Image(row, "Rank", UDim2.fromScale(0.035, 0.2), UDim2.fromScale(0.12, 0.6))
	local name = C.Label(row, "PlayerName", "Adventurer", UDim2.fromScale(0.18, 0.12), UDim2.fromScale(0.53, 0.5), true)
	name.TextWrapped = false
	name.TextTruncate = Enum.TextTruncate.AtEnd
	C.Label(row, "Hint", "View profile", UDim2.fromScale(0.18, 0.6), UDim2.fromScale(0.5, 0.25)).TextColor3 = T.Muted
	C.Frame(row, "Divider", UDim2.fromScale(0.735, 0.17), UDim2.fromScale(0.006, 0.66), T.Soft)
	local level = C.Label(row, "Level", "1", UDim2.fromScale(0.76, 0.18), UDim2.fromScale(0.21, 0.64), true)
	level.TextColor3 = T.Gold
	level.TextXAlignment = Enum.TextXAlignment.Center
	return screen
end
