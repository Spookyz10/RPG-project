local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local prompt = C.New("BillboardGui", "NPCInteractionTemplate", parent, {
		Size = UDim2.fromOffset(300, 76),
		StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0),
		AlwaysOnTop = true,
		ResetOnSpawn = false,
		LightInfluence = 0,
		Enabled = false,
	})
	local main = C.Round(C.New("CanvasGroup", "Main", prompt, {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = T.Paper,
		GroupTransparency = 0,
	}), 14)
	C.Stroke(main, T.Line).Thickness = 3
	C.New("UIScale", "PromptScale", main, { Scale = 1 })
	local accent = C.Round(C.Frame(main, "Accent", UDim2.fromOffset(8, 11), UDim2.fromOffset(5, 54), T.Gold), 3)
	accent.ZIndex = main.ZIndex + 1
	local name = C.Label(main, "NPCName", "Friendly face", UDim2.fromOffset(24, 9), UDim2.new(1, -108, 0, 27), true)
	name.TextColor3 = T.Gold
	name.TextSize = 16
	local action = C.Label(main, "Action", "Talk", UDim2.fromOffset(24, 38), UDim2.new(1, -108, 0, 24))
	action.TextColor3 = T.Muted
	action.TextSize = 12
	local key = C.Round(C.Label(main, "Key", "F", UDim2.new(1, -68, 0.5, -23), UDim2.fromOffset(52, 46), true), 10)
	key.BackgroundColor3 = T.Sky
	key.BackgroundTransparency = 0
	key.TextXAlignment = Enum.TextXAlignment.Center
	key.TextSize = 19
	C.Stroke(key, T.Ink).Thickness = 2
	local tap = C.New("TextButton", "Tap", main, {
		Text = "",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		ZIndex = key.ZIndex + 2,
	})
	return prompt
end
