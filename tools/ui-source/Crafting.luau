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
	return screen
end
