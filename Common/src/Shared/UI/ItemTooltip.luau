local Abbreviation = require(script.Parent.Parent.Utils.Abbreviation)
local Items = require(script.Parent.Parent.ItemsData)
local Theme = require(script.Parent.Theme)
local TooltipFollower = require(script.Parent.TooltipFollower)

local function new()
	local Tooltip = {}
	local root
	local screen
	local tip
	local follower
	local connections = {}

	local function disconnect()
		for _, connection in connections do connection:Disconnect() end
		table.clear(connections)
		if follower then follower:Destroy(); follower = nil end
	end

	function Tooltip.Hide(target)
		if follower then follower:Hide(target) end
	end

	function Tooltip.Bind(button: GuiButton, getItem)
		local function show()
			if not follower or follower:IsTouch() or not root.Visible then return end
			local item = getItem()
			local info = item and Items[item.ID]
			if not info then return end
			tip.ItemName.Text = item.Name or info.Data.Name
			tip.Meta.Text = info.Data.Rarity
				.. " · "
				.. (info.Data.SubType or info.Kind)
				.. " · Lv. "
				.. Abbreviation:Number(info.Data.Level or 1)
			tip.Description.Text = info.Data.Description or ""
			local stats = {}
			for _, entry in {
				{ "Attack", "ATK" },
				{ "Defense", "DEF" },
				{ "Health", "HP" },
				{ "Speed", "SPD" },
				{ "Critical", "CRIT" },
				{ "Critical Power", "CRIT POWER" },
			} do
				local value = info.Stats and info.Stats[entry[1]] or 0
				if value ~= 0 then
					local formatted = (entry[1] == "Critical" or entry[1] == "Critical Power")
						and Abbreviation:Percent(value)
						or Abbreviation:Number(value)
					table.insert(stats, entry[2] .. " +" .. formatted)
				end
			end
			tip.Stats.Text = #stats > 0 and table.concat(stats, "  ·  ")
				or (info.Kind == "Consumable" and "Use from your backpack." or "Collect and keep for your adventure.")
			tip.Footer.Text = "x" .. Abbreviation:Number(item.Amount or 1) .. "  ·  Sell: " .. Abbreviation:Number(info.Data.SellsFor or 0) .. " gold each"
			tip.RarityBar.BackgroundColor3 = Theme.Rarities[info.Data.Rarity] or Theme.Soft
			follower:Show(button)
		end

		button.MouseEnter:Connect(show)
		button.MouseLeave:Connect(function() Tooltip.Hide(button) end)
		button.SelectionGained:Connect(show)
		button.SelectionLost:Connect(function() Tooltip.Hide(button) end)
		button.Activated:Connect(function() Tooltip.Hide() end)
		button.Destroying:Connect(function() Tooltip.Hide(button) end)
	end

	function Tooltip.Init(inventoryScreen: ScreenGui)
		disconnect()
		screen = inventoryScreen
		root = screen:WaitForChild("Main")
		tip = screen:WaitForChild("ItemTooltip")
		follower = TooltipFollower.new(screen, tip)
		follower:Hide()
		table.insert(connections, root:GetPropertyChangedSignal("Visible"):Connect(Tooltip.Hide))
		table.insert(connections, screen:GetPropertyChangedSignal("Enabled"):Connect(Tooltip.Hide))
		for _, child in root:GetDescendants() do
			if child:IsA("ScrollingFrame") then
				table.insert(connections, child:GetPropertyChangedSignal("CanvasPosition"):Connect(Tooltip.Hide))
			end
		end
		table.insert(connections, screen.Destroying:Connect(disconnect))
	end

	return Tooltip
end

local default = new()
default.new = new
return default
