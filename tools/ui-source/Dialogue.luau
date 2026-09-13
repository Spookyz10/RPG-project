local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen = C.Screen(parent, "Dialogue", 60)
	local root = C.Round(C.New("CanvasGroup", "Main", screen, {
		Position = UDim2.new(0.5, 0, 1, -16),
		Size = UDim2.new(1, -24, 0, 286),
		BackgroundColor3 = T.Paper,
		GroupTransparency = 0,
	}), 18)
	root.AnchorPoint = Vector2.new(0.5, 1)
	root.Visible = false
	root.Active = true
	root:SetAttribute("Window", true)
	C.New("UISizeConstraint", "Bounds", root, { MaxSize = Vector2.new(760, 286) })
	C.New("UIScale", "DialogScale", root, { Scale = 1 })
	C.Stroke(root, T.Line).Thickness = 4
	C.Frame(root, "Accent", UDim2.fromOffset(14, 0), UDim2.new(1, -28, 0, 5), T.Gold)

	local header = C.Frame(root, "Header", UDim2.fromOffset(16, 12), UDim2.new(1, -82, 0, 38))
	local speaker = C.Label(header, "Speaker", "A friendly face", UDim2.new(), UDim2.fromScale(1, 1), true)
	speaker.TextSize = 22
	speaker.TextColor3 = T.Gold
	local close = C.Button(root, "Close", "X", UDim2.new(1, -56, 0, 10), UDim2.fromOffset(42, 42), T.Rose)
	close:SetAttribute("CloseDialogue", true)

	local body = C.Frame(root, "Body", UDim2.fromOffset(16, 56), UDim2.new(1, -32, 1, -70))
	local content = C.Frame(body, "Content")
	local textPanel = C.Round(C.Frame(content, "TextPanel", UDim2.new(), UDim2.new(1, 0, 0, 104), T.Surface), 10)
	C.Stroke(textPanel, T.Soft).Thickness = 2
	local text = C.Label(textPanel, "Text", "", UDim2.fromOffset(14, 10), UDim2.new(1, -28, 1, -20))
	text.RichText = true
	text.TextSize = 16
	text.TextYAlignment = Enum.TextYAlignment.Top
	C.New("UITextSizeConstraint", "TextBounds", text, { MinTextSize = 13, MaxTextSize = 16 })
	local skip = C.New("TextButton", "SkipTyping", content, {
		Text = "",
		Position = UDim2.new(),
		Size = UDim2.new(1, 0, 0, 104),
		BackgroundTransparency = 1,
		ZIndex = textPanel.ZIndex + 2,
	})
	skip:SetAttribute("SkipDialogueTyping", true)

	local options = C.Scroll(content, "Options", UDim2.fromOffset(0, 112), UDim2.new(1, 0, 1, -112))
	local layout = options:FindFirstChildOfClass("UIListLayout")
	if layout then layout.Padding = UDim.new(0, 7) end

	local choice = C.Button(root, "ChoiceTemplate", "Continue", UDim2.new(), UDim2.new(1, -8, 0, 48), T.Sky)
	choice.Visible = false
	choice.TextSize = 15
	choice.AutoButtonColor = false
	C.New("UIScale", "ChoiceScale", choice, { Scale = 1 })
	local marker = C.Frame(choice, "Marker", UDim2.fromOffset(0, 7), UDim2.fromOffset(4, 34), T.Gold)
	marker.ZIndex = choice.ZIndex + 1
	return screen
end
