local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen, _, body = C.Window(parent, "SkillSelector", "Frame", "Find your fighting style", "Choose a skill, then choose its slot. Q · E · R on keyboard.", 470, 470)
	local sidebar = C.Frame(body, "Sidebar", UDim2.new(), UDim2.new(1, 0, 0, 48))
	C.Button(sidebar, "Attack", "Attack skills", UDim2.new(), UDim2.new(0.5, -4, 1, 0), T.Mint)
	C.Button(sidebar, "Support", "Support skills", UDim2.new(0.5, 4, 0, 0), UDim2.new(0.5, -4, 1, 0), T.Sky)
	local holder = C.Frame(body, "Holder", UDim2.fromOffset(0, 60), UDim2.new(1, 0, 0, 410))
	C.Scroll(holder, "Attack", UDim2.new(), UDim2.fromScale(1, 1))
	C.Scroll(holder, "Support", UDim2.new(), UDim2.fromScale(1, 1)).Visible = false
	return screen
end
