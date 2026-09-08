local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen, _, body = C.Window(parent, "Partylist", "Panel", "Better together", "Invite adventurers from the player list.", 460, 460)
	screen.DisplayOrder = 50
	C.Label(body, "Empty", "No party yet. Open Adventurers to invite a friend.", UDim2.fromOffset(12, 48), UDim2.new(1, -24, 0, 84)).TextColor3 = T.Muted
	C.Scroll(body, "Frame", UDim2.new(), UDim2.new(1, 0, 0, 380))
	C.Button(body, "Leave", "Leave party", UDim2.fromOffset(0, 396), UDim2.new(1, 0, 0, 48), T.Rose).Visible = false
	return screen
end
