local Bootstrap = require(script.Parent.Bootstrap)
local Toast = {}
local TweenService = game:GetService("TweenService")

local function fadeBorders(card: GuiObject, transparency: number, duration: number)
	for _, object in card:GetDescendants() do
		if object:IsA("UIStroke") then
			local original = object:GetAttribute("ToastOriginalTransparency")
			if original == nil then
				original = object.Transparency
				object:SetAttribute("ToastOriginalTransparency", original)
			end
			TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
				Transparency = transparency == 1 and 1 or original,
			}):Play()
		end
	end
end

function Toast.Show(message)
	local container = Bootstrap.Ensure().Notifications.Container
	local entries = {}
	for _, child in container:GetChildren() do
		if child:IsA("GuiObject") then table.insert(entries, child) end
	end
	if #entries >= 3 then entries[1]:Destroy() end
	local card = Bootstrap.GetTemplates().ToastTemplate:Clone()
	card.Name = "Message"
	card.Message.Text = tostring(message)
	card.Visible = true
	card.GroupTransparency = 1
	local popTarget = card.Pop.Scale
	card.Pop.Scale = card.Pop:GetAttribute("StartScale") or card.Pop.Scale
	local shineStart = card.Shine.Position
	local shineEnd = card.Shine:GetAttribute("EndPosition") or shineStart
	card.Parent = container
	TweenService:Create(card, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { GroupTransparency = 0 }):Play()
	fadeBorders(card, 0, 0.18)
	TweenService:Create(card.Pop, TweenInfo.new(0.32, Enum.EasingStyle.Back), { Scale = popTarget }):Play()
	TweenService:Create(card.Shine, TweenInfo.new(0.6, Enum.EasingStyle.Quad), { Position = shineEnd }):Play()
	task.delay(4.2, function()
		if not card.Parent then return end
		TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quad), { GroupTransparency = 1 }):Play()
		fadeBorders(card, 1, 0.22)
		task.wait(0.24)
		if card.Parent then card:Destroy() end
	end)
end

return Toast
