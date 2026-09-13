local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local effect = C.New("CanvasGroup", "LevelUpFeedback", parent, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.46),
		Size = UDim2.fromScale(0.58, 0.28),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 150,
	})

	local glow = C.Round(C.Frame(effect, "Glow", UDim2.fromScale(0.36, 0.3), UDim2.fromScale(0.28, 0.4), T.Gold), 10)
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.BackgroundTransparency = 0.58
	glow.ZIndex = 151
	glow:SetAttribute("StartSize", UDim2.fromScale(0.12, 0.18))
	glow:SetAttribute("EndSize", UDim2.fromScale(0.78, 0.92))

	for index, rotation in { -35, 0, 35 } do
		local ray = C.Round(C.Frame(effect, "Ray" .. index, UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.5, 0.018), T.Gold), 8)
		ray.AnchorPoint = Vector2.new(0.5, 0.5)
		ray.Rotation = rotation
		ray.BackgroundTransparency = 0.34
		ray.ZIndex = 152
		ray:SetAttribute("EndSize", UDim2.fromScale(1.12, 0.018))
	end

	local ribbon = C.Round(C.Frame(effect, "Ribbon", UDim2.fromScale(0.18, 0.39), UDim2.fromScale(0.64, 0.24), T.Paper), 10)
	ribbon.ZIndex = 154
	C.Stroke(ribbon, T.Gold).Thickness = 3
	local topRule = C.Round(C.Frame(ribbon, "TopRule", UDim2.fromScale(0.16, 0.1), UDim2.fromScale(0.68, 0.04), T.Gold), 6)
	topRule.ZIndex = 155
	local title = C.Label(ribbon, "Title", "LEVEL UP!", UDim2.fromScale(0.04, 0.18), UDim2.fromScale(0.92, 0.43), true)
	title.TextColor3 = T.Gold
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.TextSize = 42
	title.ZIndex = 156
	local subtitle = C.Label(ribbon, "Subtitle", "A NEW CHAPTER BEGINS", UDim2.fromScale(0.04, 0.62), UDim2.fromScale(0.92, 0.2), true)
	subtitle.TextColor3 = T.Muted
	subtitle.TextXAlignment = Enum.TextXAlignment.Center
	subtitle.TextSize = 13
	subtitle.ZIndex = 156

	for index = 1, 14 do
		local angle = math.pi * 2 * index / 14
		local particle = C.Round(C.Frame(effect, "Spark" .. index, UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.018, 0.035), index % 2 == 0 and T.Gold or T.Ink), 8)
		particle.AnchorPoint = Vector2.new(0.5, 0.5)
		particle.Rotation = index * 25
		particle.ZIndex = 157
		particle:SetAttribute("EndPosition", UDim2.fromScale(0.5 + math.cos(angle) * 0.43, 0.5 + math.sin(angle) * 0.34))
		particle:SetAttribute("EndSize", UDim2.fromScale(0.004, 0.008))
	end

	local pop = C.New("UIScale", "Pop", effect, { Scale = 1 })
	pop:SetAttribute("StartScale", 0.52)
	return effect
end
