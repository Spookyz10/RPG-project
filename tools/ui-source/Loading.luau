local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen = C.Screen(parent, "LoadingScreen", 100)
	local frame = C.Frame(screen, "Frame", UDim2.new(), UDim2.fromScale(1, 1), T.Paper)
	local title = C.Label(frame, "Title", "RISE BEYOND", UDim2.fromScale(0.08, 0.22), UDim2.fromScale(0.84, 0.15), true)
	title.TextSize = 36
	title.TextColor3 = T.Green
	title.TextXAlignment = Enum.TextXAlignment.Center
	local subtitle = C.Label(frame, "Subtitle", "A little courage. A whole world to explore.", UDim2.fromScale(0.08, 0.38), UDim2.fromScale(0.84, 0.1))
	subtitle.TextXAlignment = Enum.TextXAlignment.Center
	subtitle.TextColor3 = T.Muted
	local track = C.Round(C.Frame(frame, "Progress", UDim2.fromScale(0.18, 0.55), UDim2.new(0.64, 0, 0, 12), T.Soft), 6)
	C.Round(C.Frame(track, "Fill", UDim2.new(), UDim2.fromScale(0, 1), T.Green), 6)
	local status = C.Label(frame, "Status", "Preparing your adventure...", UDim2.fromScale(0.08, 0.61), UDim2.fromScale(0.84, 0.08))
	status.TextXAlignment = Enum.TextXAlignment.Center
	local play = C.Button(frame, "Play", "Let's explore", UDim2.new(0.5, -108, 0.76, 0), UDim2.fromOffset(216, 52), T.Mint)
	play.Visible = false
	return screen
end
