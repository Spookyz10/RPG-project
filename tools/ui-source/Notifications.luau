local C = require(script.Parent.Parent.Components)

return function(parent)
	local screen = C.Screen(parent, "Notifications", 80)
	local container = C.Frame(screen, "Container", UDim2.new(0.5, 0, 0, 12), UDim2.new(1, -24, 0, 200))
	container.AnchorPoint = Vector2.new(0.5, 0)
	C.New("UISizeConstraint", "Bounds", container, { MaxSize = Vector2.new(400, 200) })
	C.List(container)
	return screen
end
