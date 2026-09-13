local Bootstrap = require(script.Parent.Bootstrap)
local Toast = {}
local TweenService = game:GetService("TweenService")
local activeMessages: { [string]: CanvasGroup } = {}

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

local function scheduleDismissal(card: CanvasGroup, message: string, token: number)
	task.delay(4.2, function()
		if not card.Parent or card:GetAttribute("LifetimeToken") ~= token then return end
		TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quad), { GroupTransparency = 1 }):Play()
		fadeBorders(card, 1, 0.22)
		task.wait(0.24)
		if card.Parent and card:GetAttribute("LifetimeToken") == token then
			if activeMessages[message] == card then activeMessages[message] = nil end
			card:Destroy()
		end
	end)
end

function Toast.Show(message)
	message = tostring(message)
	local container = Bootstrap.Ensure().Notifications.Container
	local existing = activeMessages[message]
	if existing and existing.Parent then
		local count = (existing:GetAttribute("MessageCount") or 1) + 1
		existing:SetAttribute("MessageCount", count)
		existing.Message.Text = message .. "  x" .. count
		local token = (existing:GetAttribute("LifetimeToken") or 0) + 1
		existing:SetAttribute("LifetimeToken", token)
		scheduleDismissal(existing, message, token)
		TweenService:Create(existing.Pop, TweenInfo.new(0.16, Enum.EasingStyle.Back), { Scale = 1.08 }):Play()
		task.delay(0.16, function()
			if existing.Parent then
				TweenService:Create(existing.Pop, TweenInfo.new(0.14, Enum.EasingStyle.Quad), { Scale = 1 }):Play()
			end
		end)
		return
	end
	local entries = {}
	for _, child in container:GetChildren() do
		if child:IsA("GuiObject") then table.insert(entries, child) end
	end
	if #entries >= 3 then entries[1]:Destroy() end
	local card = Bootstrap.GetTemplates().ToastTemplate:Clone()
	card.Name = "Message"
	card.Message.Text = message
	card:SetAttribute("MessageCount", 1)
	card:SetAttribute("LifetimeToken", 1)
	card.Visible = true
	card.GroupTransparency = 1
	local popTarget = card.Pop.Scale
	card.Pop.Scale = card.Pop:GetAttribute("StartScale") or card.Pop.Scale
	local shineStart = card.Shine.Position
	local shineEnd = card.Shine:GetAttribute("EndPosition") or shineStart
	card.Parent = container
	activeMessages[message] = card
	TweenService:Create(card, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { GroupTransparency = 0 }):Play()
	fadeBorders(card, 0, 0.18)
	TweenService:Create(card.Pop, TweenInfo.new(0.32, Enum.EasingStyle.Back), { Scale = popTarget }):Play()
	TweenService:Create(card.Shine, TweenInfo.new(0.6, Enum.EasingStyle.Quad), { Position = shineEnd }):Play()
	scheduleDismissal(card, message, 1)
end

return Toast
