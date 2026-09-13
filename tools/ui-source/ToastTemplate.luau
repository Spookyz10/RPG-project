local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local toast = C.New("CanvasGroup", "ToastTemplate", parent, {
		Size = UDim2.new(1, 0, 0, 66),
		BackgroundColor3 = T.Surface,
		ClipsDescendants = true,
		Visible = false,
	})
	C.Round(toast, 10)
	C.Stroke(toast, T.Gold)

	C.Frame(toast, "Accent", UDim2.fromScale(0, 0), UDim2.fromScale(0.018, 1), T.Gold)
	local message = C.Label(toast, "Message", "", UDim2.fromScale(0.07, 0.08), UDim2.fromScale(0.86, 0.68), true)
	message.TextXAlignment = Enum.TextXAlignment.Center
	message.TextSize = 14

	local shine = C.Frame(toast, "Shine", UDim2.fromScale(-0.35, 0), UDim2.fromScale(0.24, 1), T.Highlight)
	shine:SetAttribute("EndPosition", UDim2.fromScale(1.2, 0))
	shine.BackgroundTransparency = 0.78
	shine.Rotation = 18
	local pop = C.New("UIScale", "Pop", toast, { Scale = 1 })
	pop:SetAttribute("StartScale", 0.82)
	return toast
end
