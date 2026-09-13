local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen, _, body = C.Window(parent, "Crafting", "Main", "Blacksmith crafting", "Turn trophies from the wild into equipment. Craft one at a time.", 600, 560)
	local container = C.Scroll(body, "Container", UDim2.new(), UDim2.fromScale(1, 1))
	local row = C.Frame(screen, "RecipeTemplate", UDim2.new(), UDim2.new(1, -12, 0, 210), T.Paper)
	row.Visible = false
	C.Stroke(row)
	C.Label(row, "Title", "Recipe", UDim2.fromOffset(12, 8), UDim2.new(1, -24, 0, 24), true)
	local description = C.Label(row, "Description", "", UDim2.fromOffset(12, 36), UDim2.new(1, -24, 0, 68))
	description.TextWrapped = true
	description.TextSize = 13
	local cost = C.Label(row, "Cost", "", UDim2.fromOffset(12, 106), UDim2.new(1, -24, 0, 52))
	cost.TextWrapped = true
	cost.TextSize = 13
	C.Button(row, "Craft", "CRAFT", UDim2.new(0, 12, 1, -42), UDim2.new(1, -24, 0, 32), T.Mint)
	local tip = C.Round(C.Frame(screen, "ItemTooltip", UDim2.new(), UDim2.fromOffset(252, 286), T.Paper), 8)
	tip.Visible = false
	tip.ZIndex = 50
	C.Stroke(tip)
	C.Frame(tip, "RarityBar", UDim2.fromOffset(4, 4), UDim2.new(1, -8, 0, 4), T.Sky)
	C.Label(tip, "ItemName", "", UDim2.fromOffset(12, 14), UDim2.new(1, -24, 0, 46), true).TextSize = 18
	C.Label(tip, "Meta", "", UDim2.fromOffset(12, 62), UDim2.new(1, -24, 0, 26)).TextSize = 12
	C.Label(tip, "Description", "", UDim2.fromOffset(12, 94), UDim2.new(1, -24, 0, 78)).TextSize = 13
	C.Label(tip, "Stats", "", UDim2.fromOffset(12, 180), UDim2.new(1, -24, 0, 68)).TextSize = 13
	C.Label(tip, "Footer", "", UDim2.new(0, 12, 1, -30), UDim2.new(1, -24, 0, 22)).TextColor3 = T.Gold
	return screen
end
