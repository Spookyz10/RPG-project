local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

local function notification(button)
	local badge = C.Round(C.Label(button, "Notification", "1", UDim2.new(0.76, 0, -0.16, 0), UDim2.fromScale(0.32, 0.48), true), 10)
	badge.BackgroundTransparency = 0
	badge.BackgroundColor3 = T.Rose
	badge.TextXAlignment = Enum.TextXAlignment.Center
	badge.TextSize = 11
	badge.Visible = false
	badge.ZIndex = button.ZIndex + 3
	C.Stroke(badge, T.Ink).Thickness = 2
	return badge
end

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
		{ "Journal", "Quest journal", "Journal" }, { "Home", "Return to village", "Home" },
		{ "Admin", "Developer tools", "Main" },
	} do
		local button = C.Button(list, entry[1], entry[2])
		button.LayoutOrder = index
		button:SetAttribute("OpenScreen", entry[3])
		if entry[1] == "Admin" or entry[1] == "Raids" then button.Visible = false end
		if entry[1] == "Journal" then notification(button) end
	end
	notification(toggle)
	local bag = C.Button(main, "Backpack", "Bag", UDim2.fromOffset(0, 56), UDim2.fromOffset(80, 48), T.Mint)
	bag:SetAttribute("OpenScreen", "Inventory")
	local amount = C.Label(bag, "Amount", "0 / 100", UDim2.fromOffset(0, 28), UDim2.new(1, 0, 0, 16))
	amount.TextSize = 10
	amount.TextXAlignment = Enum.TextXAlignment.Center
	local journal = C.Button(main, "Journal", "Quests", UDim2.fromOffset(0, 112), UDim2.fromOffset(80, 48), T.Sky)
	journal:SetAttribute("OpenScreen", "Journal")
	notification(journal)
	C.Responsive(drawer, UDim2.new(1, -184, 0, 56), UDim2.fromOffset(184, 408), UDim2.new(1, -184, 0, 56), UDim2.fromOffset(184, 260))
	return screen
end
