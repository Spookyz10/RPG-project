local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

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
