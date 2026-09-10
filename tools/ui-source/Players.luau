local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

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
