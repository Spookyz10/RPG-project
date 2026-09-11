local C = require(script.Parent.Parent.Components)

return function(parent)
	local screen, _, body = C.Window(parent, "ZoneSelector", "Main", "Explore the world", "Choose a zone to inspect its creatures and rewards.", 460, 460)
	local list = C.Scroll(body, "Container", UDim2.new(), UDim2.fromScale(1, 1))
	local detail = C.Frame(body, "Details")
	detail.Visible = false
	C.Button(detail, "Back", "? Zones", UDim2.fromScale(0, 0), UDim2.fromScale(0.23, 0.09))
	C.Label(detail, "ZoneName", "Grasslands", UDim2.fromScale(0.27, 0), UDim2.fromScale(0.73, 0.09), true)
	C.Label(detail, "LevelRange", "Lv. 1?15", UDim2.fromScale(0, 0.11), UDim2.fromScale(1, 0.07))
	C.Scroll(detail, "Mobs", UDim2.fromScale(0, 0.2), UDim2.fromScale(1, 0.66))
	C.Button(detail, "Enter", "Enter zone", UDim2.fromScale(0, 0.89), UDim2.fromScale(1, 0.11))
	local templates = C.New("Folder", "Templates", screen)
	local zone = C.Button(templates, "ZoneEntry", "", nil, UDim2.fromScale(0.96, 0.22))
	zone.Visible = false
	C.Label(zone, "AreaName", "Zone", UDim2.fromScale(0.04, 0.08), UDim2.fromScale(0.92, 0.35), true)
	C.Label(zone, "LevelReq", "Lv. 1?15", UDim2.fromScale(0.04, 0.48), UDim2.fromScale(0.48, 0.3))
	C.Label(zone, "Status", "View mobs ?", UDim2.fromScale(0.53, 0.48), UDim2.fromScale(0.43, 0.3), true)
	local mob = C.Frame(templates, "MobEntry", nil, UDim2.fromScale(0.96, 1.25), Color3.fromRGB(38, 48, 56))
	mob.Visible = false
	C.Round(mob); C.Stroke(mob)
	C.Label(mob, "MobName", "Bushling ? Lv. 1", UDim2.fromScale(0.04, 0.03), UDim2.fromScale(0.92, 0.09), true)
	C.Label(mob, "Stats", "Stats", UDim2.fromScale(0.04, 0.14), UDim2.fromScale(0.92, 0.2))
	C.Label(mob, "Rewards", "Rewards", UDim2.fromScale(0.04, 0.36), UDim2.fromScale(0.92, 0.1))
	C.Label(mob, "DropsTitle", "ITEM DROPS", UDim2.fromScale(0.04, 0.49), UDim2.fromScale(0.92, 0.07), true)
	local drops = C.Label(mob, "Drops", "No item drops", UDim2.fromScale(0.04, 0.58), UDim2.fromScale(0.92, 0.38))
	drops.TextYAlignment = Enum.TextYAlignment.Top
	C.Label(detail.Mobs, "Empty", "No creatures have been recorded in this zone yet.", UDim2.new(), UDim2.fromScale(0.96, 0.3))
	return screen
end
