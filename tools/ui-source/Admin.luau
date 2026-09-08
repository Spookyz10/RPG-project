local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local screen, root, body = C.Window(parent, "Main", "Admin", "ITEM SPAWNER", "Developer tools", 460, 460)
	screen.DisplayOrder = 40
	root.Bounds.MaxSize = Vector2.new(500, 590)
	C.Scroll(body, "ItemList", UDim2.new(), UDim2.new(1, 0, 0, 388))
	C.Button(body, "Spawn", "SPAWN ITEM", UDim2.fromOffset(0, 402), UDim2.new(1, 0, 0, 48), T.Mint)
	return screen
end
