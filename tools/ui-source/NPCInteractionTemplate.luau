local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local prompt = C.New("BillboardGui", "NPCInteractionTemplate", parent, {
		Size = UDim2.fromScale(4.6, 1.18),
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
	local accent = C.Round(C.Frame(main, "Accent", UDim2.fromScale(0.027, 0.145), UDim2.fromScale(0.017, 0.711), T.Gold), 3)
	accent.ZIndex = main.ZIndex + 1
	local name = C.Label(main, "NPCName", "Friendly face", UDim2.fromScale(0.08, 0.118), UDim2.fromScale(0.64, 0.355), true)
	name.TextColor3 = T.Gold
	name.TextSize = 16
	local action = C.Label(main, "Action", "Talk", UDim2.fromScale(0.08, 0.5), UDim2.fromScale(0.64, 0.316))
	action.TextColor3 = T.Muted
	action.TextSize = 12
	local key = C.Round(C.Label(main, "Key", "F", UDim2.fromScale(0.773, 0.197), UDim2.fromScale(0.173, 0.605), true), 10)
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
