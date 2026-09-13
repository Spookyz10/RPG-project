local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen = C.Screen(parent, "DeathScreen", 96)
	screen.Enabled = false
	local veil = C.Frame(screen, "Veil", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Color3.fromRGB(13, 8, 13))
	veil.BackgroundTransparency = 0.2
	local panel = C.Round(C.Frame(veil, "Panel", UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.44, 0.26), T.Paper), 18)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	C.Stroke(panel, T.Rose)
	local title = C.Label(panel, "Title", "YOU DIED", UDim2.fromScale(0.08, 0.12), UDim2.fromScale(0.84, 0.25), true)
	title.TextColor3 = T.Rose; title.TextXAlignment = Enum.TextXAlignment.Center; title.TextSize = 30
	local timer = C.Label(panel, "Timer", "You will respawn in 6 seconds", UDim2.fromScale(0.08, 0.42), UDim2.fromScale(0.84, 0.18), true)
	timer.TextXAlignment = Enum.TextXAlignment.Center
	local button = C.Button(panel, "RespawnNow", "RESPAWN NOW", UDim2.fromScale(0.22, 0.68), UDim2.fromScale(0.56, 0.20), T.Mint)
	return screen
end
