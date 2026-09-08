local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Items = require(script.Parent.Parent.ItemsData)
local Theme = require(script.Parent.Theme)
local Tooltip = {}
local target
local root
local screen
local tip
local followed
local inputConnection
local lastInputWasTouch = false

function Tooltip.Hide()
	target = nil
	if tip then tip.Visible = false end
end

local function place()
	if not target or not target.Parent or not root.Visible or not target.Visible or not screen.Enabled then Tooltip.Hide(); return end
	local ancestor = target.Parent
	while ancestor and ancestor ~= screen do
		if ancestor:IsA("GuiObject") and not ancestor.Visible then Tooltip.Hide(); return end
		ancestor = ancestor.Parent
	end
	local origin = screen.AbsolutePosition
	local bounds = screen.AbsoluteSize
	local mouse = UserInputService:GetMouseLocation()
	local point = lastInputWasTouch and (target.AbsolutePosition + target.AbsoluteSize) or mouse
	local x = point.X - origin.X + 16
	local y = point.Y - origin.Y + 14
	if x + tip.AbsoluteSize.X > bounds.X - 8 then x = point.X - origin.X - tip.AbsoluteSize.X - 12 end
	if y + tip.AbsoluteSize.Y > bounds.Y - 8 then y = bounds.Y - tip.AbsoluteSize.Y - 8 end
	tip.Position = UDim2.fromScale(math.clamp(x, 8, math.max(8, bounds.X - tip.AbsoluteSize.X - 8)) / math.max(1, bounds.X), math.max(8, y) / math.max(1, bounds.Y))
end

function Tooltip.Bind(button, getItem)
	local function show()
		if lastInputWasTouch or not root.Visible then return end
		local item = getItem()
		local info = item and Items[item.ID]
		if not info then return end
		target = button
		tip.ItemName.Text = item.Name or info.Data.Name
		tip.Meta.Text = info.Data.Rarity .. " · " .. (info.Data.SubType or info.Kind) .. " · Lv. " .. (info.Data.Level or 1)
		tip.Description.Text = info.Data.Description or ""
		local stats = {}
		for _, entry in { { "Attack", "ATK" }, { "Defense", "DEF" }, { "Health", "HP" }, { "Speed", "SPD" }, { "Critical", "CRIT" } } do
			local value = info.Stats and info.Stats[entry[1]] or 0
			if value ~= 0 then table.insert(stats, entry[2] .. " +" .. value .. (entry[1] == "Critical" and "%" or "")) end
		end
		tip.Stats.Text = #stats > 0 and table.concat(stats, "  ·  ") or (info.Kind == "Consumable" and "Use from your backpack." or "Collect and keep for your adventure.")
		tip.Footer.Text = "x" .. (item.Amount or 1) .. "  ·  Sell: " .. (info.Data.SellsFor or 0) .. " gold each"
		tip.RarityBar.BackgroundColor3 = Theme.Rarities[info.Data.Rarity] or Theme.Soft
		tip.Visible = true
		place()
	end
	button.MouseEnter:Connect(show)
	button.MouseLeave:Connect(function() if target == button then Tooltip.Hide() end end)
	button.SelectionGained:Connect(show)
	button.SelectionLost:Connect(function() if target == button then Tooltip.Hide() end end)
	button.Activated:Connect(Tooltip.Hide)
	button.Destroying:Connect(function() if target == button then Tooltip.Hide() end end)
end

function Tooltip.Init(inventoryScreen)
	screen = inventoryScreen
	root = screen.Main
	tip = screen.ItemTooltip
	tip.Visible = false
	if followed then followed:Disconnect() end
	if inputConnection then inputConnection:Disconnect() end
	inputConnection = UserInputService.InputBegan:Connect(function(input)
		lastInputWasTouch = input.UserInputType == Enum.UserInputType.Touch
		if lastInputWasTouch then Tooltip.Hide() end
	end)
	followed = RunService.RenderStepped:Connect(function() if target then place() end end)
	root:GetPropertyChangedSignal("Visible"):Connect(Tooltip.Hide)
	screen:GetPropertyChangedSignal("Enabled"):Connect(Tooltip.Hide)
	root.Body:GetPropertyChangedSignal("CanvasPosition"):Connect(Tooltip.Hide)
	root.Body.Content.Items.Container:GetPropertyChangedSignal("CanvasPosition"):Connect(Tooltip.Hide)
	screen.Destroying:Connect(function() followed:Disconnect(); inputConnection:Disconnect() end)
end

return Tooltip
