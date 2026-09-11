local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen, root, body = C.Window(parent, "Main", "Admin", "ADMIN PANEL", "Select a player, an item or an action.", 460, 460)
	screen.DisplayOrder = 40
	screen.Enabled = false
	local launcher = C.Button(screen, "AdminLauncher", "ADMIN", UDim2.fromScale(0.015, 0.45), UDim2.fromScale(0.1, 0.055), T.Purple)
	launcher.Visible = false
	C.Button(body, "Target", "Yourself • click to change player", UDim2.new(), UDim2.fromScale(1, 0.1), T.Sky)
	C.Input(body, "Search", "Search items...", UDim2.fromScale(0, 0.12), UDim2.fromScale(0.65, 0.09))
	C.Input(body, "Value", "Amount / level", UDim2.fromScale(0.68, 0.12), UDim2.fromScale(0.32, 0.09)).Text = "1"
	C.Scroll(body, "ItemList", UDim2.fromScale(0, 0.23), UDim2.fromScale(1, 0.37))
	C.Label(body, "Selected", "Select an item", UDim2.fromScale(0, 0.62), UDim2.fromScale(1, 0.06))
	for i, action in {{"GiveItem", "Give item"}, {"GiveGold", "Give gold"}, {"UpdateLevel", "Set level"}, {"Heal", "Heal"}, {"GoTo", "Go to player"}, {"Bring", "Bring player"}} do
		C.Button(body, action[1], action[2], UDim2.fromScale(((i-1)%3)*0.34, 0.7+math.floor((i-1)/3)*0.1), UDim2.fromScale(0.32, 0.09), T.Mint)
	end
	C.Label(body, "Status", "Ready. Actions affect the selected player.", UDim2.fromScale(0, 0.91), UDim2.fromScale(1, 0.08))
	return screen
end
