local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen = C.Screen(parent, "Attack", 12)
	local slots = C.Frame(screen, "Slots")
	C.Responsive(slots, UDim2.new(0.5, -116, 1, -88), UDim2.fromOffset(232, 72), UDim2.new(1, -256, 1, -280), UDim2.fromOffset(232, 64))
	C.List(slots, true, 8)
	for index, key in { "Q", "E", "R" } do
		local slot = C.Button(slots, "Slot" .. index, "", UDim2.new(), UDim2.fromOffset(72, 64), T.Paper)
		C.Stroke(slot)
		slot.LayoutOrder = index
		C.Image(slot, "Icon", UDim2.fromOffset(18, 4), UDim2.fromOffset(36, 36))
		local caption = C.Label(slot, "SkillName", "Empty", UDim2.fromOffset(2, 40), UDim2.new(1, -4, 0, 20), true)
		caption.TextSize = 10
		caption.TextXAlignment = Enum.TextXAlignment.Center
		C.Label(slot, "Key", key, UDim2.fromOffset(5, 3), UDim2.fromOffset(16, 18), true).TextSize = 11
		local cooldown = C.Label(slot, "Cooldown", "", UDim2.new(), UDim2.fromScale(1, 1), true)
		cooldown.BackgroundColor3 = T.Paper
		cooldown.BackgroundTransparency = 0.15
		cooldown.TextXAlignment = Enum.TextXAlignment.Center
		cooldown.TextSize = 22
		cooldown.Visible = false
		C.Round(cooldown)
	end
	local attack = C.Button(screen, "AttackButton", "ATTACK", UDim2.new(1, -104, 1, -208), UDim2.fromOffset(88, 72), T.Sand)
	attack.Visible = false
	C.Stroke(attack, T.Gold)
	local buffs = C.Frame(screen, "Buffs", UDim2.new(0.5, -112, 1, -134), UDim2.fromOffset(224, 38))
	C.Responsive(buffs, buffs.Position, buffs.Size, UDim2.new(1, -256, 1, -326), UDim2.fromOffset(232, 38))
	C.List(buffs, true, 6)
	local debuffs = C.Frame(screen, "Debuffs", UDim2.new(0.5, -112, 1, -178), UDim2.fromOffset(224, 38))
	C.Responsive(debuffs, debuffs.Position, debuffs.Size, UDim2.new(1, -256, 1, -370), UDim2.fromOffset(232, 38))
	C.List(debuffs, true, 6)
	return screen
end
