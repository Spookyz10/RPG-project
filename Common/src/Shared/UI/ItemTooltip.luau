local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
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
	-- GetMouseLocation includes the top bar; GuiObject.AbsolutePosition does not.
	local inset = screen.IgnoreGuiInset and Vector2.new() or GuiService:GetGuiInset()
	local rawMouse = UserInputService:GetMouseLocation()
	local mouse = Vector2.new(rawMouse.X - inset.X, rawMouse.Y - inset.Y)
	local bounds = screen.AbsoluteSize
	local origin = screen.AbsolutePosition
	local x, y = mouse.X + 12, mouse.Y + 12
	if x + tip.AbsoluteSize.X > origin.X + bounds.X - 8 then x = mouse.X - tip.AbsoluteSize.X - 12 end
	if y + tip.AbsoluteSize.Y > origin.Y + bounds.Y - 8 then y = mouse.Y - tip.AbsoluteSize.Y - 12 end
	x = math.clamp(x, origin.X + 8, math.max(origin.X + 8, origin.X + bounds.X - tip.AbsoluteSize.X - 8))
	y = math.clamp(y, origin.Y + 8, math.max(origin.Y + 8, origin.Y + bounds.Y - tip.AbsoluteSize.Y - 8))
	-- Move by the rendered delta: respects custom AnchorPoint, parent and UIScale.
	local parentSize = tip.Parent.AbsoluteSize
	tip.Position = UDim2.fromScale(
		tip.Position.X.Scale + (tip.Position.X.Offset + x - tip.AbsolutePosition.X) / math.max(1, parentSize.X),
		tip.Position.Y.Scale + (tip.Position.Y.Offset + y - tip.AbsolutePosition.Y) / math.max(1, parentSize.Y)
	)

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
