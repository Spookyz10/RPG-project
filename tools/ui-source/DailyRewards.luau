local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen = C.Screen(parent, "DailyRewards", 65)
	local card = C.New("CanvasGroup", "Card", screen, {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.82, 0.7), BackgroundColor3 = T.Paper, Visible = false,
	})
	C.New("UIAspectRatioConstraint", "Aspect", card, {AspectRatio = 1.35})
	C.New("UIScale", "Pop", card, {Scale = 1})
	C.Round(card); C.Stroke(card, T.Gold)
	C.New("UIGradient", "GoldShade", card, {
		Rotation = 65, Color = ColorSequence.new(Color3.fromRGB(255, 245, 210), Color3.fromRGB(147, 163, 207)),
	})
	local function label(parentObject, name, value, pos, size, color)
		local text = C.Label(parentObject, name, value, pos, size, true)
		text.TextXAlignment = Enum.TextXAlignment.Center
		text.TextColor3 = color or T.Ink
		return text
	end
	local badge = C.Round(C.Frame(card, "Badge", UDim2.fromScale(0.33, 0.045), UDim2.fromScale(0.34, 0.07), T.Soft))
	label(badge, "Text", "DAILY REWARDS", UDim2.fromScale(0.04, 0.1), UDim2.fromScale(0.92, 0.8), T.Gold)
	local emblem = C.Frame(card, "Gift", UDim2.fromScale(0.405, 0.145), UDim2.fromScale(0.19, 0.2))
	C.New("UIAspectRatioConstraint", "Aspect", emblem, {AspectRatio = 1})
	local halo = C.Round(C.Frame(emblem, "Halo", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), T.Sand))
	halo.BackgroundTransparency = 0.78
	C.Round(C.Frame(emblem, "Box", UDim2.fromScale(0.2, 0.38), UDim2.fromScale(0.6, 0.43), T.Gold))
	C.Round(C.Frame(emblem, "Lid", UDim2.fromScale(0.15, 0.3), UDim2.fromScale(0.7, 0.15), T.Sand))
	C.Frame(emblem, "Ribbon", UDim2.fromScale(0.45, 0.3), UDim2.fromScale(0.1, 0.51), T.Paper)
	for _, side in {-1, 1} do
		local bow = C.Round(C.Frame(emblem, "Bow", UDim2.fromScale(0.36 + side * 0.13, 0.12), UDim2.fromScale(0.27, 0.2), T.Gold))
		bow.Rotation = side * 25
	end
	label(card, "Heading", "REWARDS CLAIMED!", UDim2.fromScale(0.06, 0.365), UDim2.fromScale(0.88, 0.095), T.Gold)
	label(card, "Subtitle", "A little treasure for your next adventure.", UDim2.fromScale(0.07, 0.465), UDim2.fromScale(0.86, 0.045), T.Muted)
	for i, entry in {{"Gold", "GOLD", T.Gold}, {"XP", "EXPERIENCE", T.Blue}} do
		local tile = C.Round(C.Frame(card, entry[1], UDim2.fromScale(0.07 + (i - 1) * 0.44, 0.55), UDim2.fromScale(0.42, 0.17), T.Surface))
		C.Stroke(tile, entry[3])
		label(tile, "Caption", entry[2], UDim2.fromScale(0.04, 0.09), UDim2.fromScale(0.92, 0.24), entry[3])
		label(tile, "Amount", "+0", UDim2.fromScale(0.04, 0.39), UDim2.fromScale(0.92, 0.48))
	end
	label(card, "Streak", "1 DAY STREAK", UDim2.fromScale(0.07, 0.755), UDim2.fromScale(0.86, 0.055), T.Gold)
	label(card, "NextClaim", "Come back in 24 hours for your next reward.", UDim2.fromScale(0.07, 0.82), UDim2.fromScale(0.86, 0.045), T.Muted)
	C.Button(card, "Close", "AWESOME!", UDim2.fromScale(0.25, 0.895), UDim2.fromScale(0.5, 0.075), T.Mint)
	return screen
end
