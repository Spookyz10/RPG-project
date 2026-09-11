local C = require(script.Parent.Parent.Components)
return function(parent)
	local screen = C.Screen(parent, "LootRewards", 24)
	local card = C.New("CanvasGroup", "Card", screen, {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.76), Size = UDim2.fromScale(0.38, 0.15), BackgroundColor3 = Color3.fromRGB(32, 38, 44), Visible = false})
	C.Round(card); C.Stroke(card)
	C.New("UIScale", "Pop", card, {Scale = 1})
	C.New("UISizeConstraint", "Bounds", card, {MaxSize = Vector2.new(480, 130), MinSize = Vector2.new(270, 90)})
	C.Image(card, "Icon", UDim2.fromScale(0.035, 0.13), UDim2.fromScale(0.18, 0.74))
	C.Label(card, "Rarity", "RARE DROP", UDim2.fromScale(0.25, 0.08), UDim2.fromScale(0.7, 0.19), true)
	C.Label(card, "ItemName", "Dire Claw", UDim2.fromScale(0.25, 0.32), UDim2.fromScale(0.7, 0.32), true)
	C.Label(card, "Amount", "+1 • Added to inventory", UDim2.fromScale(0.25, 0.72), UDim2.fromScale(0.7, 0.18))
	local shine = C.Frame(card, "Shine", UDim2.fromScale(-0.3, 0), UDim2.fromScale(0.13, 1), Color3.fromRGB(255, 255, 255))
	shine.BackgroundTransparency = 0.8; shine.Rotation = 18; shine.ZIndex = 4
	local spark = C.Frame(screen, "Spark", UDim2.new(), UDim2.fromScale(0.006, 0.01), Color3.fromRGB(255, 255, 255))
	spark.Visible = false; spark.AnchorPoint = Vector2.new(0.5, 0.5)
	return screen
end
