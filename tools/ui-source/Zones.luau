local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen, main, body = C.Window(parent, "ZoneSelector", "Main", "Explore the world", "Choose a zone to inspect its creatures and rewards.", 460, 460)
	screen.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	main.Size = UDim2.fromScale(0.6, 0.85)
	main.Bounds:Destroy()
	main.Heading.Text = "Adventure atlas"
	main.Subtitle.Text = "Pick a destination. Meet its creatures. Plan your next hunt."
	main.Body.AutomaticCanvasSize = Enum.AutomaticSize.None
	body:SetAttribute("WideSize", nil); body:SetAttribute("NarrowSize", nil)
	body.Size = UDim2.fromScale(1, 1)
	local list = C.Scroll(body, "Container", UDim2.new(), UDim2.fromScale(1, 0.14))
	list.ScrollingDirection = Enum.ScrollingDirection.X
	list.AutomaticCanvasSize = Enum.AutomaticSize.X
	list.UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	local detail = C.Frame(body, "Details", UDim2.fromScale(0, 0.17), UDim2.fromScale(1, 0.83))
	detail.Visible = false
	local roster = C.Scroll(detail, "Roster", UDim2.fromScale(0, 0.13), UDim2.fromScale(1, 0.1))
	roster.ScrollingDirection = Enum.ScrollingDirection.X; roster.AutomaticCanvasSize = Enum.AutomaticSize.X
	roster.UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	C.Label(detail, "ZoneName", "Grasslands", UDim2.fromScale(0, 0), UDim2.fromScale(0.55, 0.09), true)
	C.Label(detail, "LevelRange", "Lv. 1 - 15", UDim2.fromScale(0.58, 0.015), UDim2.fromScale(0.42, 0.06))
	C.Frame(detail, "Mobs", UDim2.fromScale(0, 0.26), UDim2.fromScale(1, 0.58))
	C.Button(detail, "Enter", "Enter zone", UDim2.fromScale(0.6, 0.88), UDim2.fromScale(0.4, 0.12))
	C.Label(detail, "Journey", "Ready to explore", UDim2.fromScale(0, 0.86), UDim2.fromScale(0.56, 0.065))
	local progress = C.Frame(detail, "Progress", UDim2.fromScale(0, 0.945), UDim2.fromScale(0.55, 0.025), T.Soft)
	C.Round(progress)
	C.Round(C.Frame(progress, "Fill", UDim2.new(), UDim2.fromScale(1, 1), T.Mint))
	local templates = C.New("Folder", "Templates", screen)
	local zone = C.Button(templates, "ZoneEntry", "", nil, UDim2.fromScale(0.24, 0.86))
	zone.Visible = false
	C.Label(zone, "AreaName", "Zone", UDim2.fromScale(0.04, 0.08), UDim2.fromScale(0.92, 0.35), true)
	C.Label(zone, "LevelReq", "Lv. 1 - 15", UDim2.fromScale(0.04, 0.48), UDim2.fromScale(0.92, 0.3))
	C.Frame(zone, "Selected", UDim2.fromScale(0.04, 0.92), UDim2.fromScale(0.92, 0.04), T.Gold).Visible = false
	local mobButton = C.Button(templates, "MobButton", "Creature", nil, UDim2.fromScale(0.23, 0.85), T.Soft)
	mobButton.Visible = false
	local mob = C.Frame(templates, "MobEntry", nil, UDim2.fromScale(1, 1), Color3.fromRGB(38, 48, 56))
	mob.Visible = false
	C.Round(mob); C.Stroke(mob)
	C.Label(mob, "MobName", "Bushling - Lv. 1", UDim2.fromScale(0.04, 0.03), UDim2.fromScale(0.4, 0.09), true)
	C.Label(mob, "Stats", "Stats", UDim2.fromScale(0.04, 0.66), UDim2.fromScale(0.4, 0.2))
	C.Label(mob, "Rewards", "Rewards", UDim2.fromScale(0.04, 0.89), UDim2.fromScale(0.4, 0.07))
	C.Label(mob, "DropsTitle", "ITEM DROPS", UDim2.fromScale(0.48, 0.035), UDim2.fromScale(0.48, 0.07), true)
	C.New("ViewportFrame", "Preview", mob, {Position = UDim2.fromScale(0.04, 0.13), Size = UDim2.fromScale(0.4, 0.5), BackgroundTransparency = 1, Ambient = Color3.fromRGB(190, 190, 190), LightColor = Color3.fromRGB(255, 240, 216)})
	C.Label(mob.Preview, "Missing", "Model unavailable", UDim2.new(), UDim2.fromScale(1, 1)).Visible = false
	local drops = C.Scroll(mob, "Drops", UDim2.fromScale(0.48, 0.14), UDim2.fromScale(0.49, 0.82))
	drops.UIListLayout:Destroy()
	C.Label(mob, "NoDrops", "No item drops", UDim2.fromScale(0.5, 0.2), UDim2.fromScale(0.45, 0.1)).Visible = false
	C.New("UIGridLayout", "Grid", drops, {CellSize = UDim2.fromScale(0.3, 0.34), CellPadding = UDim2.fromScale(0.025, 0.035), SortOrder = Enum.SortOrder.LayoutOrder})
	local drop = C.Button(templates, "DropEntry", "", nil, UDim2.fromScale(0.3, 0.34), T.Surface)
	drop.Visible = false
	C.New("UIAspectRatioConstraint", "Square", drop, {AspectRatio = 1})
	C.Image(drop, "Icon", UDim2.fromScale(0.22, 0.03), UDim2.fromScale(0.56, 0.5))
	C.Label(drop, "ItemName", "Item", UDim2.fromScale(0.04, 0.54), UDim2.fromScale(0.92, 0.25), true)
	C.Label(drop, "Chance", "50%", UDim2.fromScale(0.04, 0.81), UDim2.fromScale(0.92, 0.16))
	C.Label(detail.Mobs, "Empty", "No creatures have been recorded in this zone yet.", UDim2.new(), UDim2.fromScale(0.96, 0.3))
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
	for _, label in screen:GetDescendants() do
		if label:IsA("TextLabel") or label:IsA("TextButton") then
			local maximum = label.Name == "MobName" and 22 or label.Name == "ItemName" and 14 or label.Name == "Chance" and 13 or 18
			if not label:FindFirstChildOfClass("UITextSizeConstraint") then
				C.New("UITextSizeConstraint", "TextLimit", label, {MinTextSize = 8, MaxTextSize = maximum})
			end
		end
	end
	return screen
end
