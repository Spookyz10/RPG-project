local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen = C.Screen(parent, "Buttons", 15)
	local main = C.Frame(screen, "Main", UDim2.new(1, -92, 0, 10), UDim2.fromOffset(80, 280))
	local toggle = C.Button(main, "Menu", "Menu", UDim2.new(), UDim2.fromOffset(80, 48), T.Sand)
	toggle:SetAttribute("ToggleMenu", true)
	local drawer = C.Round(C.Frame(main, "Drawer", UDim2.new(1, -184, 0, 56), UDim2.fromOffset(184, 408), T.Paper), 14)
	drawer.Visible = false
	C.Stroke(drawer)
	local list = C.Scroll(drawer, "Items", UDim2.fromOffset(8, 8), UDim2.new(1, -16, 1, -16))
	for index, entry in {
		{ "Inventory", "Backpack", "Inventory" }, { "Skills", "Skills", "SkillSelector" },
		{ "Zones", "Explore", "ZoneSelector" }, { "Raids", "Boss raids", "RaidsGUI" },
		{ "Party", "My party", "Partylist" },
		{ "Journal", "Quest journal", "Journal" }, { "Home", "Return to village", "Home" },
		{ "Admin", "Developer tools", "Main" },
	} do
		local button = C.Button(list, entry[1], entry[2])
		button.LayoutOrder = index
		button:SetAttribute("OpenScreen", entry[3])
		if entry[1] == "Admin" or entry[1] == "Raids" or entry[1] == "Party" or entry[1] == "Journal" then button.Visible = false end
	end
	-- A small primary shortcut stays visible when the menu is collapsed.
	local bag = C.Button(main, "Backpack", "Bag", UDim2.fromOffset(0, 56), UDim2.fromOffset(80, 48), T.Mint)
	bag:SetAttribute("OpenScreen", "Inventory")
	local amount = C.Label(bag, "Amount", "0 / 100", UDim2.fromOffset(0, 28), UDim2.new(1, 0, 0, 16))
	amount.TextSize = 10
	amount.TextXAlignment = Enum.TextXAlignment.Center
	C.Responsive(drawer, UDim2.new(1, -184, 0, 56), UDim2.fromOffset(184, 408), UDim2.new(1, -184, 0, 56), UDim2.fromOffset(184, 260))
	return screen
end
