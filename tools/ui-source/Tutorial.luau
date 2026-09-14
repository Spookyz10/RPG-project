local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen = C.Screen(parent, "Tutorial", 200)
	screen.Enabled = false

	local overlay = C.Frame(screen, "Overlay", UDim2.new(), UDim2.fromScale(1, 1))
	overlay.ZIndex = 80

	C.New("TextButton", "Scrim", overlay, {
		Text = "",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(10, 12, 19),
		BackgroundTransparency = 0.28,
		AutoButtonColor = false,
		Active = true,
		Modal = true,
		ZIndex = 80,
	})

	local focus = C.Frame(overlay, "FocusRing", UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.12, 0.1))
	focus.AnchorPoint = Vector2.new(0.5, 0.5)
	focus.BackgroundTransparency = 1
	focus.Visible = false
	focus.ZIndex = 84
	C.Round(focus, 14)
	local focusStroke = C.Stroke(focus, T.Gold)
	focusStroke.Name = "Glow"
	focusStroke.Thickness = 5
	C.New("UIScale", "Pulse", focus, { Scale = 1 })
	local marker = C.Round(C.Label(focus, "Marker", "NEXT", UDim2.fromScale(0.5, -0.28), UDim2.fromScale(0.56, 0.28), true), 10)
	marker.AnchorPoint = Vector2.new(0.5, 0)
	marker.BackgroundTransparency = 0
	marker.BackgroundColor3 = T.Gold
	marker.TextColor3 = T.Line
	marker.TextStrokeTransparency = 1
	marker.TextXAlignment = Enum.TextXAlignment.Center
	marker.TextSize = 11
	marker.ZIndex = 85
	C.Stroke(marker, T.Line).Thickness = 2

	local coach = C.New("Frame", "Coach", overlay, {
		Position = UDim2.new(0.5, 0, 1, -16),
		Size = UDim2.fromScale(0.9, 0.245),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = T.Paper,
		ZIndex = 90,
	})
	C.Round(coach, 18)
	C.Stroke(coach, T.Line).Thickness = 4
	C.New("UISizeConstraint", "Bounds", coach, { MaxSize = Vector2.new(650, 176) })
	C.New("UIScale", "MotionScale", coach, { Scale = 1 })
	local accent = C.Frame(coach, "Accent", UDim2.new(), UDim2.new(0.018, 0, 1, 0), T.Sky)
	accent.ZIndex = 91
	C.Round(accent, 18)

	local step = C.Round(C.Label(coach, "Step", "WELCOME", UDim2.fromOffset(24, 15), UDim2.fromOffset(108, 26), true), 10)
	step.BackgroundTransparency = 0
	step.BackgroundColor3 = T.Sky
	step.TextXAlignment = Enum.TextXAlignment.Center
	step.TextSize = 11
	step.ZIndex = 92

	local title = C.Label(coach, "Title", "Ready for your first adventure?", UDim2.fromOffset(144, 11), UDim2.new(1, -280, 0, 34), true)
	title.TextSize = 24
	title.TextWrapped = false
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.ZIndex = 92
	local prompt = C.Label(coach, "Prompt", "We will prepare your first weapon and complete your first contract together.", UDim2.fromOffset(24, 52), UDim2.new(1, -48, 0, 42))
	prompt.TextSize = 15
	prompt.TextColor3 = T.Ink
	prompt.ZIndex = 92

	local objective = C.Round(C.Frame(coach, "Objective", UDim2.fromOffset(24, 100), UDim2.new(1, -48, 0, 40), T.Surface), 10)
	objective.Visible = false
	objective.ZIndex = 92
	C.Stroke(objective, T.Gold).Thickness = 2
	local objectiveIcon = C.Round(C.Label(objective, "Icon", "!", UDim2.fromOffset(4, 4), UDim2.fromOffset(32, 32), true), 8)
	objectiveIcon.BackgroundTransparency = 0
	objectiveIcon.BackgroundColor3 = T.Gold
	objectiveIcon.TextColor3 = T.Line
	objectiveIcon.TextStrokeTransparency = 1
	objectiveIcon.TextXAlignment = Enum.TextXAlignment.Center
	objectiveIcon.ZIndex = 93
	local objectiveText = C.Label(objective, "Text", "Open your Backpack", UDim2.fromOffset(46, 4), UDim2.new(1, -142, 0, 32), true)
	objectiveText.TextSize = 13
	objectiveText.ZIndex = 93
	local counter = C.Label(objective, "Counter", "", UDim2.new(1, -92, 0, 4), UDim2.fromOffset(82, 32), true)
	counter.TextXAlignment = Enum.TextXAlignment.Right
	counter.TextColor3 = T.Gold
	counter.TextSize = 13
	counter.ZIndex = 93

	local progress = C.Round(C.Frame(coach, "Progress", UDim2.fromOffset(24, 149), UDim2.new(1, -48, 0, 10), T.Soft), 5)
	progress.ClipsDescendants = true
	progress.ZIndex = 92
	local fill = C.Round(C.Frame(progress, "Fill", UDim2.new(), UDim2.fromScale(0, 1), T.Green), 5)
	fill:SetAttribute("DynamicProgress", true)
	fill.ZIndex = 93

	local continue = C.Button(coach, "Continue", "LET'S GO", UDim2.fromOffset(325, 100), UDim2.fromOffset(190, 40), T.Mint)
	continue.AnchorPoint = Vector2.new(0.5, 0)
	continue.Visible = true
	continue.ZIndex = 94
	local status = C.Round(C.Label(coach, "Status", "DONE!", UDim2.new(1, -112, 0, 14), UDim2.fromOffset(88, 28), true), 10)
	status.BackgroundTransparency = 0
	status.BackgroundColor3 = T.Green
	status.TextColor3 = T.Line
	status.TextStrokeTransparency = 1
	status.TextXAlignment = Enum.TextXAlignment.Center
	status.TextSize = 12
	status.Visible = false
	status.ZIndex = 94

	local celebration = C.Frame(overlay, "Celebration", UDim2.new(), UDim2.fromScale(1, 1))
	celebration.ZIndex = 100
	local colors = { T.Green, T.Gold, T.Sky, T.Rose, T.Purple }
	for index = 1, 14 do
		local particle = C.Round(C.Frame(celebration, "Confetti" .. index, UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(10 + index % 3 * 3, 10 + (index + 1) % 3 * 3), colors[(index - 1) % #colors + 1]), 3)
		particle.AnchorPoint = Vector2.new(0.5, 0.5)
		particle.Visible = false
		particle.ZIndex = 101
	end

	return screen
end
