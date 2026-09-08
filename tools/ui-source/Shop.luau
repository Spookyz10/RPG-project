local C = require(script.Parent.Parent.Components)

return function(parent)
	local screen, _, body = C.Window(parent, "Shop", "Main", "Village shop", "Choose something for your next adventure.", 470, 470)
	C.Scroll(body, "Container", UDim2.new(), UDim2.fromScale(1, 1))
	return screen
end
