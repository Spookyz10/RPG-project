local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen = C.Screen(parent, "LoadingScreen", 100)
	screen.ScreenInsets = Enum.ScreenInsets.None
	local bg = T.Paper
	local gold = T.Gold
	local frame = C.Frame(screen, "Frame", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), bg)
	C.New("UIGradient", "Atmosphere", frame, { Rotation = 35, Color = ColorSequence.new(Color3.fromRGB(170, 160, 205), Color3.fromRGB(255, 255, 255)) })
	local art = C.Image(frame, "BackgroundArt", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1))
	art.ScaleType = Enum.ScaleType.Crop
	art.ImageTransparency = 0.7
	C.Frame(frame, "TopRule", UDim2.fromScale(0.07, 0.12), UDim2.fromScale(0.86, 0.002), gold)
	local function text(name, value, x, y, w, h, color, font)
		local label = C.Label(frame, name, value, UDim2.fromScale(x, y), UDim2.fromScale(w, h))
		label.Font = font or T.Font
		label.TextColor3 = color or Color3.fromRGB(231, 234, 238)
		label.TextStrokeTransparency = 1
		return label
	end
	text("Chapter", "YOUR NEXT ADVENTURE AWAITS", 0.08, 0.22, 0.8, 0.035, gold, Enum.Font.GothamMedium)
	text("Title", "BOOTLEG SIM", 0.075, 0.31, 0.85, 0.13, nil, T.Bold)
	text("Subtitle", "Small beginnings. Legendary adventures.", 0.08, 0.47, 0.75, 0.045)
	text("Edition", "EXPLORE  /  GROW  /  ENDURE", 0.08, 0.56, 0.72, 0.027, gold)
	local progress = C.Frame(frame, "Progress", UDim2.fromScale(0.08, 0.77), UDim2.fromScale(0.84, 0.025), T.Soft)
	C.Round(progress)
	progress.ClipsDescendants = true
	local fill = C.Frame(progress, "Fill", UDim2.fromScale(0, 0), UDim2.fromScale(0, 1), T.Mint)
	C.Round(fill)
	C.New("UIGradient", "Gradient", fill, { Color = ColorSequence.new(T.Mint, T.Green) })
	local spark = C.Frame(frame, "Spark", UDim2.fromScale(0.88, 0.32), UDim2.fromScale(0.025, 0.025), T.Gold)
	spark.Rotation = 45
	C.New("UIAspectRatioConstraint", "Aspect", spark, { AspectRatio = 1 })
	text("Tip", "TIP  ?  Watch the red ground markers and dodge before they fill.", 0.08, 0.67, 0.84, 0.045, T.Muted)
	text("Percent", "0%", 0.8, 0.81, 0.12, 0.035, T.Green, T.Bold)
	text("Status", "Connecting to the world...", 0.08, 0.8, 0.58, 0.035)
	local play = C.New("TextButton", "Play", frame, { Position = UDim2.fromScale(0.66, 0.84), Size = UDim2.fromScale(0.26, 0.085), Text = "ENTER WORLD", Font = Enum.Font.GothamMedium, TextStrokeTransparency = 1, BackgroundColor3 = T.Mint, TextColor3 = T.Ink, Visible = false })
	C.Round(play)
	C.Gradient(play)
	local stroke = C.Stroke(play, T.Line)
	stroke.Thickness = 1
	text("Footer", "YOUR STORY CONTINUES", 0.08, 0.91, 0.5, 0.022, Color3.fromRGB(126, 139, 157))
	return screen
end
