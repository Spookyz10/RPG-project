local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen = C.Screen(parent, "ZoneTransition", 95)
	screen.Enabled = false
	local veil = C.Frame(screen, "Veil", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Color3.fromRGB(8, 10, 17))
	local panel = C.Round(C.Frame(veil, "Panel", UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.52, 0.18), T.Paper), 18)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	C.Stroke(panel, T.Gold)
	C.Label(panel, "Eyebrow", "TRAVELING", UDim2.fromScale(0.08, 0.12), UDim2.fromScale(0.84, 0.18), true).TextColor3 = T.Gold
	local title = C.Label(panel, "Title", "GRASSLANDS", UDim2.fromScale(0.08, 0.30), UDim2.fromScale(0.84, 0.34), true)
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.TextSize = 28
	local rule = C.Round(C.Frame(panel, "Rule", UDim2.fromScale(0.17, 0.73), UDim2.fromScale(0.66, 0.05), T.Gold), 8)
	return screen
end
