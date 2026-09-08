local C = require(script.Parent.Parent.Components)

return function(parent)
	local screen, _, body = C.Window(parent, "ZoneSelector", "Main", "A world worth exploring", "Choose a destination. New places unlock as you level up.", 460, 460)
	C.Scroll(body, "Container", UDim2.new(), UDim2.fromScale(1, 1), 230, 160)
	return screen
end
