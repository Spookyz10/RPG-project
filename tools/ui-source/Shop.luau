local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen = C.Screen(parent, "Shop", 30)

	local backdrop = C.New("TextButton", "Backdrop", screen, {
		Text = "",
		Position = UDim2.new(),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = T.Line,
		BackgroundTransparency = 0.28,
		AutoButtonColor = false,
		Active = true,
		Modal = true,
		Visible = false,
	})

	local shadow = C.Round(C.Frame(screen, "Shadow", UDim2.fromScale(0.507, 0.51), UDim2.fromScale(0.94, 0.84), T.Line), 18)
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.BackgroundTransparency = 0.35
	shadow.Visible = false
	C.New("UISizeConstraint", "Bounds", shadow, {
		MinSize = Vector2.new(300, 400),
		MaxSize = Vector2.new(980, 640),
	})

	local root = C.Round(C.Frame(screen, "Main", UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.94, 0.84), T.Paper), 18)
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Visible = false
	root.Active = true
	root.ClipsDescendants = true
	root:SetAttribute("Window", true)
	C.Stroke(root, T.Line).Thickness = 4
	C.New("UISizeConstraint", "Bounds", root, {
		MinSize = Vector2.new(300, 400),
		MaxSize = Vector2.new(980, 640),
	})

	local header = C.Frame(root, "Header", UDim2.new(), UDim2.fromScale(1, 0.19), Color3.fromRGB(38, 43, 55))
	local headerGradient = C.New("UIGradient", "HeaderGradient", header, { Rotation = 18 })
	headerGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 114, 92)),
		ColorSequenceKeypoint.new(0.55, Color3.fromRGB(37, 67, 83)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(37, 40, 51)),
	})

	local crest = C.Round(C.Frame(root, "Crest", UDim2.fromScale(0.03, 0.045), UDim2.fromScale(0.075, 0.1), T.Gold), 12)
	C.Stroke(crest, T.Line).Thickness = 2
	local crestText = C.Label(crest, "Mark", "$", UDim2.fromScale(0.18, 0.08), UDim2.fromScale(0.64, 0.84), true)
	crestText.TextColor3 = T.Line
	crestText.TextStrokeTransparency = 1
	crestText.TextXAlignment = Enum.TextXAlignment.Center
	crestText.TextSize = 24

	local eyebrow = C.Label(root, "Eyebrow", "TRAVELER'S SUPPLY", UDim2.fromScale(0.125, 0.04), UDim2.fromScale(0.34, 0.035), true)
	eyebrow.TextColor3 = T.Gold
	eyebrow.TextSize = 11
	eyebrow.TextWrapped = false

	local heading = C.Label(root, "Heading", "Village Shop", UDim2.fromScale(0.125, 0.073), UDim2.fromScale(0.62, 0.055), true)
	heading.TextSize = 30
	heading.TextWrapped = false
	heading.TextTruncate = Enum.TextTruncate.AtEnd
	C.New("UITextSizeConstraint", "TextBounds", heading, { MinTextSize = 17, MaxTextSize = 30 })

	local subtitle = C.Label(root, "Subtitle", "Stock up before your next adventure.", UDim2.fromScale(0.125, 0.128), UDim2.fromScale(0.7, 0.035))
	subtitle.TextColor3 = T.Muted
	subtitle.TextSize = 13
	subtitle.TextWrapped = false
	subtitle.TextTruncate = Enum.TextTruncate.AtEnd

	local close = C.Button(root, "Close", "X", UDim2.fromScale(0.92, 0.055), UDim2.fromScale(0.055, 0.085), T.Rose)
	close:SetAttribute("CloseWindow", true)
	close.TextSize = 18
	close.ZIndex = 3

	local body = C.Frame(root, "Body", UDim2.fromScale(0.025, 0.215), UDim2.fromScale(0.95, 0.75))
	local content = C.Frame(body, "Content", UDim2.new(), UDim2.fromScale(1, 1))

	local sectionTitle = C.Label(content, "SectionTitle", "AVAILABLE STOCK", UDim2.fromScale(0.008, 0), UDim2.fromScale(0.45, 0.06), true)
	sectionTitle.TextColor3 = T.Muted
	sectionTitle.TextSize = 12
	sectionTitle.TextWrapped = false

	local stockCount = C.Round(C.Label(content, "StockCount", "0 ITEMS", UDim2.fromScale(0.84, 0.005), UDim2.fromScale(0.145, 0.05), true), 8)
	stockCount.BackgroundTransparency = 0
	stockCount.BackgroundColor3 = T.Soft
	stockCount.TextColor3 = T.Muted
	stockCount.TextStrokeTransparency = 1
	stockCount.TextXAlignment = Enum.TextXAlignment.Center
	stockCount.TextSize = 11

	local rule = C.Frame(content, "Rule", UDim2.fromScale(0.008, 0.065), UDim2.fromScale(0.977, 0.005), T.Soft)
	rule.BackgroundTransparency = 0.35

	local container = C.New("ScrollingFrame", "Container", content, {
		Position = UDim2.fromScale(0, 0.09),
		Size = UDim2.fromScale(1, 0.91),
		BackgroundTransparency = 1,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = T.Mint,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	})
	C.New("UIPadding", "Padding", container, {
		PaddingTop = UDim.new(0.012, 0),
		PaddingLeft = UDim.new(0.008, 0),
		PaddingRight = UDim.new(0.018, 0),
		PaddingBottom = UDim.new(0.025, 0),
	})
	C.New("UIListLayout", "UIListLayout", container, {
		Padding = UDim.new(0.025, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	return screen
end
