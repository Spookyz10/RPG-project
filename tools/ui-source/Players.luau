local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen = C.Screen(parent, "Playerlist", 14)
	screen.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	local list = C.Frame(screen, "List", UDim2.fromScale(1, 0.045), UDim2.fromScale(0.22, 0.4), Color3.fromRGB(30, 32, 40))
	list.AnchorPoint = Vector2.new(1, 0)
	list:SetAttribute("SideTab", true)
	C.New("UISizeConstraint", "Bounds", list, { MinSize = Vector2.new(175, 180), MaxSize = Vector2.new(290, 360) })
	local border = C.Stroke(list, Color3.fromRGB(16, 18, 25))
	border.Thickness = 1
	local toggle = C.New("TextButton", "Toggle", list, { Text = "", Position = UDim2.fromScale(-0.12, 0), Size = UDim2.fromScale(0.12, 1), BackgroundColor3 = Color3.fromRGB(39, 40, 59), AutoButtonColor = true })
	local arrow = C.Label(toggle, "Arrow", ">", UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.65, 0.07))
	arrow.AnchorPoint = Vector2.new(0.5, 0.5)
	arrow.TextXAlignment = Enum.TextXAlignment.Center
	arrow.Font = Enum.Font.GothamBold
	C.New("UISizeConstraint", "TouchBounds", toggle, { MinSize = Vector2.new(32, 44) })
	local title = C.Label(list, "Title", "ADVENTURERS", UDim2.fromScale(0.055, 0.03), UDim2.fromScale(0.89, 0.075), true)
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.TextStrokeTransparency = 1
	C.Frame(list, "Divider", UDim2.fromScale(0.06, 0.135), UDim2.fromScale(0.88, 0.003), Color3.fromRGB(58, 61, 76))
	local container = C.Scroll(list, "Container", UDim2.fromScale(0.025, 0.15), UDim2.fromScale(0.95, 0.82))
	container.UIListLayout.Padding = UDim.new(0.025, 0)
	local row = C.New("TextButton", "EntryTemplate", list, { Text = "", Visible = false, Size = UDim2.fromScale(0.97, 0.18), BackgroundColor3 = T.Surface })
	C.Round(row, 4)
	C.Image(row, "Rank", UDim2.fromScale(0.025, 0.17), UDim2.fromScale(0.12, 0.66))
	local name = C.Label(row, "PlayerName", "Adventurer", UDim2.fromScale(0.175, 0.15), UDim2.fromScale(0.59, 0.7))
	name.TextWrapped = false
	C.Label(row, "Level", "1", UDim2.fromScale(0.8, 0.15), UDim2.fromScale(0.17, 0.7), true).TextXAlignment = Enum.TextXAlignment.Center
	return screen
end
