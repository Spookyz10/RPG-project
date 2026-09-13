local C = require(script.Parent.Parent.ScaleComponents)
local T = require(script.Parent.Parent.Theme)

local function ensureNotification(button: GuiButton)
	local existing = button:FindFirstChild("Notification")
	if existing then return existing end
	local badge = C.Round(C.Label(button, "Notification", "1", UDim2.fromScale(0.76, -0.16), UDim2.fromScale(0.32, 0.48), true), 10)
	badge.BackgroundTransparency = 0
	badge.BackgroundColor3 = T.Rose
	badge.TextXAlignment = Enum.TextXAlignment.Center
	badge.TextSize = 11
	badge.Visible = false
	badge.ZIndex = button.ZIndex + 3
	C.Stroke(badge, T.Ink).Thickness = 2
	return badge
end

return function()
	local screen = StarterGui:FindFirstChild("Buttons")
	assert(screen and screen:IsA("ScreenGui"), "StarterGui.Buttons must exist before installing Journal indicators.")
	local main = screen:FindFirstChild("Main")
	assert(main and main:IsA("GuiObject"), "StarterGui.Buttons.Main must exist before installing Journal indicators.")
	local menu = main:FindFirstChild("Menu")
	local backpack = main:FindFirstChild("Backpack")
	assert(menu and menu:IsA("GuiButton"), "StarterGui.Buttons.Main.Menu must exist.")
	assert(backpack and backpack:IsA("GuiButton"), "StarterGui.Buttons.Main.Backpack must exist.")

	local journal = main:FindFirstChild("Journal")
	if journal then
		assert(journal:IsA("GuiButton"), "StarterGui.Buttons.Main.Journal must be a GuiButton.")
	else
		journal = C.Button(main, "Journal", "Quests", UDim2.fromScale(0, 0.4), backpack.Size, T.Sky)
	end
	journal:SetAttribute("OpenScreen", "Journal")

	local drawer = main:FindFirstChild("Drawer")
	local items = drawer and drawer:FindFirstChild("Items")
	local drawerJournal = items and items:FindFirstChild("Journal")
	if items and not drawerJournal then
		drawerJournal = C.Button(items, "Journal", "Quest journal", UDim2.new(), UDim2.fromScale(1, 0.12), T.Sky)
		drawerJournal.LayoutOrder = 5
		drawerJournal:SetAttribute("OpenScreen", "Journal")
	end
	if drawerJournal and drawerJournal:IsA("GuiButton") then
		drawerJournal.Visible = true
		ensureNotification(drawerJournal)
	end

	ensureNotification(menu)
	ensureNotification(journal)
	Selection:Set({ menu, journal })
	print("Journal shortcut and quest notification badges installed without replacing StarterGui.Buttons.")
end
