local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)
return function(parent)
	local screen = C.Screen(parent, "Leaderboards", 1)
	for _, id in { "Gold", "Kills", "Donations", "PlayTime" } do
		local surface = C.New("SurfaceGui", id, screen, {
			Face = Enum.NormalId.Front, SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
			CanvasSize = Vector2.new(700, 900), LightInfluence = 0, AlwaysOnTop = false,
		})
		local models = workspace:FindFirstChild("Leaderboards")
		local model = models and models:FindFirstChild(id)
		local img = model and model:FindFirstChild("IMG", true)
		if img and img:IsA("BasePart") then surface.Adornee = img end
		local main = C.Frame(surface, "Main", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1))
		C.Label(main, "Status", "Loading rankings...", UDim2.fromScale(0.04, 0.02), UDim2.fromScale(0.92, 0.045)).TextScaled = true
		C.Scroll(main, "Rows", UDim2.fromScale(0.04, 0.085), UDim2.fromScale(0.92, 0.895))
		local row = C.Frame(main, "RowTemplate", UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.1), T.Surface)
		row.Visible = false
		C.New("UICorner", "UICorner", row, { CornerRadius = UDim.new(0.16, 0) })
		C.Stroke(row)
		C.Gradient(row)
		local accent = ({ Gold = T.Gold, Kills = T.Rose, Donations = T.Purple, PlayTime = T.Sky })[id]
		local badge = C.Frame(row, "RankBadge", UDim2.fromScale(0.018, 0.15), UDim2.fromScale(0.12, 0.7), T.Paper)
		C.New("UICorner", "UICorner", badge, { CornerRadius = UDim.new(0.22, 0) })
		C.Stroke(badge, T.Line)
		C.Gradient(badge)
		local valueBox = C.Frame(row, "ValueBadge", UDim2.fromScale(0.685, 0.16), UDim2.fromScale(0.295, 0.68), T.Paper)
		C.New("UICorner", "UICorner", valueBox, { CornerRadius = UDim.new(0.2, 0) })
		C.Stroke(valueBox, T.Line)
		local line = C.Frame(row, "Accent", UDim2.fromScale(0.16, 0.73), UDim2.fromScale(0.075, 0.055), accent)
		C.New("UICorner", "UICorner", line, { CornerRadius = UDim.new(0.5, 0) })
		for _, entry in { { "Rank", "#1", 0.025, 0.105 }, { "Username", "Adventurer", 0.16, 0.50 }, { "Value", "0", 0.705, 0.255 } } do
			local text = C.Label(row, entry[1], entry[2], UDim2.fromScale(entry[3], 0.24), UDim2.fromScale(entry[4], 0.48), true)
			text.TextScaled = true
			text.TextWrapped = false
			text.TextTruncate = Enum.TextTruncate.AtEnd
			text.ZIndex = 2
			if entry[1] ~= "Username" then text.TextXAlignment = Enum.TextXAlignment.Center end
			if entry[1] == "Value" then text.TextColor3 = accent end
		end
	end
	return screen
end
