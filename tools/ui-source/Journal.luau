local C = require(script.Parent.Parent.Components)

return function(parent)
	local screen, _, body = C.Window(parent, "Journal", "Main", "Your next adventure", "Quests complete automatically when their objectives are met.", 470, 470)
	C.Scroll(body, "Container", UDim2.new(), UDim2.fromScale(1, 1))
	return screen
end
