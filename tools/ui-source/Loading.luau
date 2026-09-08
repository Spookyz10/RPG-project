local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen = C.Screen(parent, "LoadingScreen", 100)
	screen.ScreenInsets = Enum.ScreenInsets.None
	local bg = Color3.fromRGB(12, 19, 28)
	local gold = Color3.fromRGB(192, 167, 112)
	local frame = C.Frame(screen, "Frame", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), bg)
	C.New("UIGradient", "Atmosphere", frame, { Rotation = 35, Color = ColorSequence.new(Color3.fromRGB(130, 160, 190), Color3.fromRGB(255, 255, 255)) })
	local art = C.Image(frame, "BackgroundArt", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1))
	art.ScaleType = Enum.ScaleType.Crop
	art.ImageTransparency = 0.7
	C.Frame(frame, "TopRule", UDim2.fromScale(0.07, 0.12), UDim2.fromScale(0.86, 0.002), gold)
	local function text(name, value, x, y, w, h, color, font)
		local label = C.Label(frame, name, value, UDim2.fromScale(x, y), UDim2.fromScale(w, h))
		label.Font = font or Enum.Font.Gotham
		label.TextColor3 = color or Color3.fromRGB(231, 234, 238)
		label.TextStrokeTransparency = 1
		return label
	end
	text("Chapter", "A WORLD BEYOND THE FAMILIAR", 0.08, 0.22, 0.8, 0.035, gold, Enum.Font.GothamMedium)
	text("Title", "RISE BEYOND", 0.075, 0.31, 0.85, 0.13, nil, Enum.Font.GothamBold)
	text("Subtitle", "Every journey leaves its mark.", 0.08, 0.47, 0.75, 0.045)
	text("Edition", "EXPLORE  /  GROW  /  ENDURE", 0.08, 0.56, 0.72, 0.027, gold)
	local progress = C.Frame(frame, "Progress", UDim2.fromScale(0.08, 0.77), UDim2.fromScale(0.84, 0.004), Color3.fromRGB(42, 51, 63))
	C.Frame(progress, "Fill", UDim2.fromScale(0, 0), UDim2.fromScale(0, 1), gold)
	text("Status", "Connecting to the world...", 0.08, 0.8, 0.58, 0.035)
	local play = C.New("TextButton", "Play", frame, { Position = UDim2.fromScale(0.66, 0.84), Size = UDim2.fromScale(0.26, 0.085), Text = "ENTER WORLD", Font = Enum.Font.GothamMedium, TextStrokeTransparency = 1, BackgroundColor3 = bg, TextColor3 = gold, Visible = false })
	local stroke = C.Stroke(play, gold)
	stroke.Thickness = 1
	text("Footer", "YOUR STORY CONTINUES", 0.08, 0.91, 0.5, 0.022, Color3.fromRGB(126, 139, 157))
	return screen
end
