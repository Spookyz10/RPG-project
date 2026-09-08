local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen, root, body = C.Window(parent, "PlayerCard", "Main", "PLAYER PROFILE", "Equipment, progress and combat record", 490, 490)
	root.Bounds.MaxSize = Vector2.new(720, 620)
	C.Label(body, "PlayerName", "Adventurer", UDim2.fromScale(0.02, 0), UDim2.fromScale(0.96, 0.065), true)
	C.Label(body, "Level", "Level 1", UDim2.fromScale(0.02, 0.075), UDim2.fromScale(0.96, 0.045))
	local preview = C.New("ViewportFrame", "Avatar", body, { Position = UDim2.fromScale(0.02, 0.15), Size = UDim2.fromScale(0.4, 0.51), BackgroundColor3 = T.Surface, Ambient = Color3.fromRGB(200, 205, 220), LightColor = Color3.fromRGB(255, 241, 220), LightDirection = Vector3.new(-1, -1, -2) })
	C.Round(preview)
	C.New("WorldModel", "World", preview)
	C.New("Camera", "Camera", preview, { FieldOfView = 32 })
	C.Label(preview, "Status", "Loading avatar...", UDim2.fromScale(0.05, 0.4), UDim2.fromScale(0.9, 0.2))
	local record = C.Frame(body, "Record", UDim2.fromScale(0.46, 0.15), UDim2.fromScale(0.52, 0.51))
	for index, key in { "Gold", "Kills", "Deaths", "PlayTime", "SessionTime" } do
		local row = C.Frame(record, key, UDim2.fromScale(0, (index - 1) * 0.2), UDim2.fromScale(1, 0.17), T.Surface)
		C.Label(row, "Label", key, UDim2.fromScale(0.04, 0.12), UDim2.fromScale(0.48, 0.76))
		C.Label(row, "Value", "--", UDim2.fromScale(0.54, 0.12), UDim2.fromScale(0.42, 0.76), true).TextXAlignment = Enum.TextXAlignment.Right
	end
	local gear = C.Frame(body, "Gear", UDim2.fromScale(0.02, 0.69), UDim2.fromScale(0.96, 0.14))
	for index, key in { "Weapon", "Armor", "Ring", "Necklace", "Aura", "Rune" } do
		local slot = C.Image(gear, key, UDim2.fromScale((index - 1) / 6, 0), UDim2.fromScale(0.15, 0.72))
		slot.BackgroundTransparency = 0
		slot.BackgroundColor3 = T.Surface
		C.Label(slot, "Slot", key, UDim2.fromScale(0, 1.04), UDim2.fromScale(1, 0.32))
	end
	C.Label(body, "Stats", "ATK --   DEF --   HP --   SPD --   CRIT --", UDim2.fromScale(0.02, 0.85), UDim2.fromScale(0.96, 0.055), true)
	C.Button(body, "Invite", "INVITE TO PARTY", UDim2.fromScale(0.52, 0.93), UDim2.fromScale(0.46, 0.07), T.Sky)
	C.Label(body, "Status", "", UDim2.fromScale(0.02, 0.93), UDim2.fromScale(0.47, 0.07))
	return screen
end
