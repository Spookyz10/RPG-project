-- Adds hover/focus feedback without overriding Studio colors or gameplay selection colors.
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Hover = {}
local bound = setmetatable({}, { __mode = "k" })

function Hover.Bind(button)
	if bound[button] or not button:IsA("GuiButton") then return end
	bound[button] = true
	local stroke = button:FindFirstChildOfClass("UIStroke")
	if not stroke then return end
	local thickness = stroke.Thickness
	local activeTween
	local function apply(active)
		if activeTween then activeTween:Cancel() end
		activeTween = TweenService:Create(stroke, TweenInfo.new(0.12), {
			Thickness = active and thickness + 1.25 or thickness,
		})
		activeTween:Play()
	end
	button.MouseEnter:Connect(function() if UserInputService.MouseEnabled then apply(true) end end)
	button.MouseLeave:Connect(function() apply(false) end)
	button.SelectionGained:Connect(function() apply(true) end)
	button.SelectionLost:Connect(function() apply(false) end)
	button.Destroying:Connect(function() if activeTween then activeTween:Cancel() end end)
end

function Hover.BindScreen(screen)
	for _, object in screen:GetDescendants() do
		if object:GetAttribute("HoverButton") then Hover.Bind(object) end
	end
	screen.DescendantAdded:Connect(function(object)
		if object:GetAttribute("HoverButton") then Hover.Bind(object) end
	end)
end

return Hover
