local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen, root, body = C.Window(parent, "Playerlist", "List", "Fellow adventurers", "View equipment and invite someone to your party.", 470, 470)
	C.Scroll(body, "Container", UDim2.new(), UDim2.fromScale(1, 1))
	local card = C.Frame(root, "Card", UDim2.fromOffset(8, 72), UDim2.new(1, -16, 1, -80), T.Paper)
	card.Active = true
	card.Visible = false
	card.ZIndex = 4
	local main = C.Scroll(card, "Main", UDim2.fromOffset(12, 8), UDim2.new(1, -24, 1, -16))
	local title = C.Label(main, "PlayerName", "Player card", nil, UDim2.new(1, -8, 0, 36), true)
	title.LayoutOrder = 1
	local avatar = C.Image(main, "ImageLabel", UDim2.new(), UDim2.fromOffset(72, 72))
	avatar.LayoutOrder = 2
	C.Image(avatar, "Rune", UDim2.fromOffset(52, 48), UDim2.fromOffset(28, 28))
	local stats = C.Frame(main, "Stats", UDim2.new(), UDim2.new(1, -8, 0, 224))
	stats.LayoutOrder = 3
	for index, name in { "Gold", "Kills", "Honor" } do
		local cell = C.Frame(stats, name, UDim2.new((index - 1) / 3, 0, 0, 0), UDim2.new(1 / 3, 0, 0, 54))
		C.Label(cell, "Label", name, UDim2.new(), UDim2.new(1, 0, 0, 24)).TextColor3 = T.Muted
		C.Label(cell, "Amount", "0", UDim2.fromOffset(0, 26), UDim2.new(1, 0, 0, 24), true)
	end
	local attributes = C.Frame(stats, "Attributes", UDim2.fromOffset(0, 66), UDim2.new(1, 0, 0, 152))
	C.List(attributes, false, 4)
	for _, name in { "ATK", "DEF", "SPD", "CRT", "HP" } do C.Label(attributes, name, name, nil, UDim2.new(1, 0, 0, 26)) end
	local items = C.Frame(main, "Items", UDim2.new(), UDim2.new(1, -8, 0, 120))
	items.LayoutOrder = 4
	local grid = C.New("UIGridLayout", "UIGridLayout", items, { CellSize = UDim2.fromOffset(48, 48), CellPadding = UDim2.fromOffset(8, 8) })
	grid:SetAttribute("CellMinWidth", 48)
	grid:SetAttribute("CellHeight", 48)
	for _, name in { "Sword", "Accessory", "Accessory2", "Aura", "Armor", "Pet" } do
		local icon = C.Image(items, name, nil, UDim2.fromOffset(48, 48))
		icon.BackgroundTransparency = 0
		icon.BackgroundColor3 = T.Soft
		C.Round(icon, 8)
		C.Image(icon, "Rarity", UDim2.new(0, 0, 1, -3), UDim2.new(1, 0, 0, 3)).BackgroundTransparency = 0
	end
	C.Label(main, "Hours", "", nil, UDim2.new(1, -8, 0, 24)).LayoutOrder = 5
	C.Button(main, "Invite", "Invite to party").LayoutOrder = 6
	C.Button(main, "Close", "Back to adventurers", nil, nil, T.Soft).LayoutOrder = 7
	for _, name in { "Trade", "Titles", "Party", "Title", "Rep" } do
		C.Label(main, name, "").Visible = false
	end
	return screen
end
