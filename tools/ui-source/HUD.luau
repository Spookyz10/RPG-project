local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen = C.Screen(parent, "HUD")
	local main = C.Round(C.Frame(screen, "Main", UDim2.fromOffset(12, 10), UDim2.fromOffset(300, 182), T.Paper), 16)
	C.Stroke(main)
	C.Responsive(main, UDim2.fromOffset(12, 10), UDim2.fromOffset(300, 182), UDim2.fromOffset(8, 8), UDim2.fromOffset(228, 164))
	C.Label(main, "PlayerName", "Adventurer", UDim2.fromOffset(14, 10), UDim2.new(1, -100, 0, 24), true)
	local level = C.Label(main, "Level", "Lv. 1", UDim2.new(1, -88, 0, 10), UDim2.fromOffset(74, 24), true)
	level.TextColor3 = T.Green
	level.TextXAlignment = Enum.TextXAlignment.Right
	for index, name in { "HP", "XP" } do
		local bar = C.Frame(main, name, UDim2.new(0, 14, 0, 40 + (index - 1) * 30), UDim2.new(1, -28, 0, 24))
		local track = C.Round(C.Frame(bar, "Main", UDim2.new(), UDim2.fromScale(1, 1), T.Soft), 8)
		track.ClipsDescendants = true
		C.Round(C.Frame(track, "Bar", UDim2.new(), UDim2.fromScale(1, 1), name == "HP" and T.Mint or T.Sky), 8)
		local amount = C.Label(track, "Amount", name .. "  -- / --", UDim2.fromOffset(8, 0), UDim2.new(1, -16, 1, 0), true)
		amount.TextSize = 13
	end
	local currencies = C.Frame(main, "Currencies", UDim2.fromOffset(14, 104), UDim2.new(1, -28, 0, 68))
	for index, name in { "Gold", "Raid Coins", "Tokens", "Rune Crystals" } do
		local col, row = (index - 1) % 2, math.floor((index - 1) / 2)
		local cell = C.Frame(currencies, name, UDim2.new(col * 0.5, 0, 0, row * 29), UDim2.new(0.5, -4, 0, 26))
		C.Label(cell, "Label", name == "Rune Crystals" and "Crystals" or name, UDim2.new(), UDim2.new(0.63, 0, 1, 0)).TextSize = 11
		local amount = C.Label(cell, "Amount", "0", UDim2.fromScale(0.63, 0), UDim2.fromScale(0.37, 1), true)
		amount.TextSize = 13
		amount.TextXAlignment = Enum.TextXAlignment.Right
		amount.TextColor3 = index == 1 and T.Gold or T.Blue
	end
	return screen
end
