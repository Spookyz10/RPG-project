local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

local function skillTemplate(parent)
	local root = C.New("CanvasGroup", "Skill", parent, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(2.8, 3.15),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 200,
	})
	local pulse = C.Round(C.Frame(root, "Pulse", UDim2.fromScale(0.39, 0.4), UDim2.fromScale(0.22, 0.2), T.Sky), 10)
	pulse.BackgroundTransparency = 0.72
	pulse.ZIndex = 201
	pulse:SetAttribute("EndSize", UDim2.fromScale(0.72, 0.64))
	pulse:SetAttribute("EndPosition", UDim2.fromScale(0.14, 0.18))
	local border = C.Stroke(pulse, T.Ink)
	border.Thickness = 3
	local echo = C.Image(root, "Echo", UDim2.fromScale(0.4, 0.4), UDim2.fromScale(0.2, 0.2))
	echo.ZIndex = 202
	echo:SetAttribute("EndPosition", UDim2.fromScale(0.325, 0.14))
	echo:SetAttribute("EndSize", UDim2.fromScale(0.35, 0.35))
	local title = C.Label(root, "Title", "SKILL", UDim2.fromScale(0.05, 0.22), UDim2.fromScale(0.9, 0.13), true)
	title.ZIndex = 203
	title.TextColor3 = T.Sky
	title.TextXAlignment = Enum.TextXAlignment.Center
	title:SetAttribute("EndPosition", UDim2.fromScale(0.05, 0.08))
	for index = 1, 8 do
		local angle = math.pi * 2 * index / 8
		local particle = C.Round(C.Frame(root, "Particle" .. index, UDim2.fromScale(0.48, 0.47), UDim2.fromScale(0.04, 0.04), index % 2 == 0 and T.Sky or T.Ink), 10)
		particle.AnchorPoint = Vector2.new(0.5, 0.5)
		particle.Rotation = 45
		particle.ZIndex = 204
		particle:SetAttribute("EndPosition", UDim2.fromScale(0.5 + math.cos(angle) * 0.3, 0.49 + math.sin(angle) * 0.27))
		particle:SetAttribute("EndSize", UDim2.fromScale(0.012, 0.012))
	end
	return root
end

local function banner(parent, name, color, detail)
	local card = C.New("CanvasGroup", name, parent, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.62),
		Size = UDim2.fromScale(0.24, 0.085),
		BackgroundColor3 = T.Paper,
		BackgroundTransparency = 0.08,
		Visible = false,
		ZIndex = 201,
	})
	card:SetAttribute("BasePosition", card.Position)
	card:SetAttribute("EntryOffset", UDim2.fromScale(0, 0.08))
	card:SetAttribute("ExitOffset", UDim2.fromScale(0, -0.04))
	card:SetAttribute("StackSpacing", 0.095)
	C.New("UISizeConstraint", "Bounds", card, { MinSize = Vector2.new(250, 56), MaxSize = Vector2.new(310, 64) })
	C.Round(card, 10)
	C.Stroke(card, color)
	local accent = C.Round(C.Frame(card, "Accent", UDim2.fromScale(0.022, 0.1), UDim2.fromScale(0.022, 0.8), color), 10)
	accent.ZIndex = 202
	local title = C.Label(card, "Title", name, UDim2.fromScale(0.09, 0.08), UDim2.fromScale(0.87, 0.43), true)
	title.ZIndex = 203
	title.TextColor3 = color
	local subtitle = C.Label(card, "Detail", detail, UDim2.fromScale(0.09, 0.52), UDim2.fromScale(0.87, 0.3))
	subtitle.ZIndex = 203
	subtitle.TextColor3 = T.Muted
	local pop = C.New("UIScale", "Pop", card, { Scale = 1 })
	pop:SetAttribute("StartScale", 0.72)
	return card
end

return function(parent)
	local folder = C.New("Folder", "FeedbackTemplates", parent)
	skillTemplate(folder)
	banner(folder, "Passive", T.Gold, "PASSIVE TRIGGERED")
	banner(folder, "Buff", T.Green, "BUFF ACTIVE")
	banner(folder, "Debuff", T.Red, "NEGATIVE EFFECT APPLIED")
	return folder
end
