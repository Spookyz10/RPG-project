local C = require(script.Parent.Parent.Components)

return function(parent)
	local screen, _, body = C.Window(parent, "Dialogue", "Main", "A friendly face", "", 540, 540)
	C.Label(body, "Speaker", "", UDim2.new(), UDim2.new(1, 0, 0, 30), true).TextSize = 21
	C.Label(body, "Text", "", UDim2.fromOffset(0, 40), UDim2.new(1, 0, 0, 160))
	local options = C.Frame(body, "Options", UDim2.fromOffset(0, 216), UDim2.new(1, 0, 0, 316))
	C.List(options)
	return screen
end
