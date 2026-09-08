local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen, root, body = C.Window(parent, "UIStylePreview", "Main", "RUNE / UI STYLE", "Official component reference · Edit mode only", 620, 620)
	root.Visible = true
	C.Section(body, "ButtonsHeader", "ACTIONS", UDim2.new(), UDim2.new(1, 0, 0, 30))
	for index, entry in { { "Equip", T.Mint }, { "Explore", T.Sky }, { "Remove", T.Rose } } do
		C.Button(body, entry[1], string.upper(entry[1]), UDim2.new((index - 1) / 3, 4, 0, 44), UDim2.new(1 / 3, -12, 0, 48), entry[2])
	end
	C.Input(body, "Search", "Search your items...", UDim2.fromOffset(4, 108), UDim2.new(1, -8, 0, 44))
	C.Section(body, "RaritiesHeader", "ITEM RARITIES", UDim2.fromOffset(0, 174), UDim2.new(1, 0, 0, 30))
	local cards = C.Scroll(body, "Cards", UDim2.fromOffset(4, 216), UDim2.new(1, -8, 0, 268), 106, 116)
	for _, rarity in { "Common", "Uncommon", "Rare", "Legendary", "Godly", "Ascendant" } do
		local card = C.Button(cards, rarity, "", nil, UDim2.fromOffset(106, 116), T.Rarities[rarity])
		card.Rotation = -1.5
		local rune = C.Label(card, "Rune", "◇", UDim2.fromOffset(4, 8), UDim2.new(1, -8, 0, 64), true)
		rune.TextSize = 52
		rune.TextXAlignment = Enum.TextXAlignment.Center
		C.Label(card, "Level", "Lv. 25", UDim2.fromOffset(6, 4), UDim2.new(1, -12, 0, 18), true).TextSize = 10
		local caption = C.Label(card, "Rarity", rarity, UDim2.new(0, 4, 1, -32), UDim2.new(1, -8, 0, 26), true)
		caption.TextSize = 13
		caption.TextXAlignment = Enum.TextXAlignment.Center
	end
	C.Section(body, "StatsHeader", "CHARACTER STATS", UDim2.fromOffset(0, 506), UDim2.new(1, 0, 0, 30))
	local stat = C.Frame(body, "StatRow", UDim2.fromOffset(4, 548), UDim2.new(1, -8, 0, 34), T.Soft)
	C.Label(stat, "Name", "ATTACK", UDim2.fromOffset(12, 0), UDim2.fromScale(0.5, 1), true)
	local amount = C.Label(stat, "Amount", "125", UDim2.fromScale(0.5, 0), UDim2.new(0.5, -12, 1, 0), true)
	amount.TextXAlignment = Enum.TextXAlignment.Right
	amount.TextColor3 = T.Gold
	return screen
end
