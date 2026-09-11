local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local Zones = require(ReplicatedStorage.Shared.Zones)
local LightingManager = require(ReplicatedStorage.Shared.LightingManager)
local MusicManager = require(ReplicatedStorage.Shared.MusicManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local ZoneSelector = {}
local Toast = require(script.Parent.Parent.Toast)
local Windows = require(script.Parent.Parent.WindowManager)

local Container: Instance = nil
local Template: GuiButton = nil

local function TeleportToZone(zoneName: string)
	local Character = UIConstants.Player.Character
	if not Character then
		return
	end

	local Teleporter = workspace:FindFirstChild("ZoneTeleportes") or workspace:FindFirstChild("ZoneTeleporters")
	local TargetPart = Teleporter and Teleporter:FindFirstChild(zoneName)
	if not TargetPart then
		Toast.Show("This destination is not available from here.")
		return false
	end

	Character:PivotTo(TargetPart.CFrame + Vector3.new(0, 3, 0))
	return true
end

function ZoneSelector.Init()
	local screen = UIConstants.PlayerGui:WaitForChild("ZoneSelector")
	local content = screen:WaitForChild("Main").Body.Content
	Container = content:WaitForChild("Container")
	local detail = content:WaitForChild("Details")
	local templates = screen:WaitForChild("Templates")
	Template = templates.ZoneEntry
	local MobsData = require(ReplicatedStorage.Shared.MobsData)
	local Config = require(ReplicatedStorage.Shared.MobCombatConfig)
	local tooltip = require(ReplicatedStorage.Shared.UI.ItemTooltip).new()
	tooltip.Init(screen)
	local Items = require(ReplicatedStorage.Shared.ItemsDataByName)
	local Preview = require(ReplicatedStorage.Shared.UI.MobPreview)
	local selected = nil
	local busy = false
	local entries = {}

	local function refresh()
		local level = UIConstants.Data.Level()
		for name, button in entries do
			local indicator = button:FindFirstChild("Selected")
			if indicator and indicator:IsA("GuiObject") then
				indicator.Visible = name == selected
			end
		end
		if selected then
			local unlocked = level >= Zones[selected].Level
			detail.Enter.Text = unlocked and ("Enter " .. selected)
				or ("Level " .. Zones[selected].Level .. " to enter")
			detail.Enter.Active = unlocked and not busy
			detail.Enter.AutoButtonColor = unlocked and not busy
			local required = Zones[selected].Level
			detail.Journey.Text = unlocked and "Destination discovered - ready to explore"
				or (tostring(required - level) .. " levels to your next adventure")
			detail.Progress.Fill.Size = UDim2.fromScale(math.clamp(level / math.max(1, required), 0, 1), 1)
		end
	end

	local function selectZone(name)
		tooltip.Hide()
		selected = name
		local info = Zones[name]
		Container.Visible = true
		detail.Visible = true

		for _, child in detail.Mobs:GetChildren() do
			if child:GetAttribute("ZoneMobEntry") then
				child:Destroy()
			end
		end
		for _, child in detail.Roster:GetChildren() do
			if child:IsA("GuiButton") then
				child:Destroy()
			end
		end
		detail.Roster.CanvasPosition = Vector2.zero
		local names = table.clone(info.Mobs or {})
		-- Zones can also inherit their roster from the existing MobsData folders.
		if #names == 0 then
			local folder = ReplicatedStorage.Shared.MobsData:FindFirstChild(name)
			if folder then
				for _, module in folder:GetDescendants() do
					if module:IsA("ModuleScript") and MobsData[module.Name] then
						table.insert(names, module.Name)
					end
				end
			end
		end
		table.sort(names, function(a, b)
			local mobA, mobB = MobsData[a], MobsData[b]
			local la = mobA and mobA.Level or 1
			local lb = mobB and mobB.Level or 1
			return la == lb and a < b or la < lb
		end)
		local count = 0
		for _, mobName in names do
			local mob = MobsData[mobName]
			if not mob then
				continue
			end
			count += 1
			local card = templates.MobEntry:Clone()
			card.Name = mobName
			card.Visible = count == 1
			card:SetAttribute("ZoneMobEntry", true)
			card.LayoutOrder = count
			local level = tostring(mob.Level or 1)
			if mob.MaxLevel and mob.MaxLevel ~= mob.Level then
				level ..= " - " .. mob.MaxLevel
			end
			card.MobName.Text = mobName .. " - Lv. " .. level .. (mobName == "Dire Bear" and " - BOSS" or "")
			local stats = mob.Data and mob.Data.Stats or {}
			local combat = Config[mobName] or {}
			card.Stats.Text = string.format(
				"HP: %s - ATK: %s - DEF: %s\nSpeed: %s - Crit: %s%%\nRespawn: %ss",
				tostring(combat.Health or stats.Health or 0),
				tostring(stats.Attack or 0),
				tostring(stats.Defense or 0),
				tostring(combat.Speed or stats.Speed or 0),
				tostring(stats.Critical or 0),
				tostring(mob.RespawnTime or 5)
			)
			local rewards = { tostring(mob.XP or 0) .. " XP" }
			local currencies = {}
			for currency in mob.Currencies or {} do
				table.insert(currencies, currency)
			end
			table.sort(currencies)
			for _, currency in currencies do
				table.insert(rewards, tostring(mob.Currencies[currency]) .. " " .. currency)
			end
			card.Rewards.Text = table.concat(rewards, " - ")
			card.Drops:GetPropertyChangedSignal("CanvasPosition"):Connect(tooltip.Hide)
			local dropNames = {}
			for item in mob.Drops or {} do
				table.insert(dropNames, item)
			end
			table.sort(dropNames)
			card.NoDrops.Visible = #dropNames == 0
			for order, item in dropNames do
				local drop = mob.Drops[item]
				local info = Items[item]
				local tile = templates.DropEntry:Clone()
				tile.Name = item
				tile.Visible = true
				tile.LayoutOrder = order
				tile.ItemName.Text = info and info.Data.Name or item
				tile.Icon.Image = info and info.Data.Icon or ""
				tile.Chance.Text = tostring(drop.Chance or 0) .. "%"
				tile.Parent = card.Drops
				if info then
					tooltip.Bind(tile, function()
						return { ID = info.Data.ID, Name = info.Data.Name, Amount = drop.Amount or 1 }
					end)
				end
			end
			card.Parent = detail.Mobs
			local loaded = false
			local function inspect()
				tooltip.Hide()
				for _, other in detail.Mobs:GetChildren() do
					if other:GetAttribute("ZoneMobEntry") then
						other.Visible = other == card
					end
				end
				for _, button in detail.Roster:GetChildren() do
					if button:IsA("GuiButton") then
						button.BackgroundColor3 = button.Name == mobName and Color3.fromRGB(35, 138, 228)
							or Color3.fromRGB(61, 63, 76)
					end
				end
				if not loaded then
					Preview.Show(card.Preview, mobName)
					loaded = true
				end
			end
			local button = templates.MobButton:Clone()
			button.Name = mobName
			button.Text = mobName
			button.Visible = true
			button.LayoutOrder = count
			button.Parent = detail.Roster
			button.Activated:Connect(inspect)
			if count == 1 then
				inspect()
			end
		end
		detail.Mobs.Empty.Visible = count == 0
		refresh()
	end

	for name, info in Zones do
		local button = Template:Clone()
		button.Name = name
		button.Visible = true
		button.LayoutOrder = info.Order
		button.AreaName.Text = name
		button.LevelReq.Text = "Lv. " .. info.Level .. " - " .. info.MaxLevel
		button.Activated:Connect(function()
			selectZone(name)
		end)
		button.Parent = Container
		entries[name] = button
	end
	detail.Enter.Activated:Connect(function()
		if busy or not selected then
			return
		end
		local name = selected
		local info = Zones[name]
		if UIConstants.Data.Level() < info.Level then
			Toast.Show("Reach level " .. info.Level .. " to explore this zone.")
			return
		end
		busy = true
		refresh()
		if TeleportToZone(name) then
			LightingManager:Apply(name, info.getLighting())
			MusicManager:PlayZone(name)
			Windows.Close()
		end
		busy = false
		refresh()
	end)
	UIConstants.Data.Level.Changed(refresh)
	local first
	for name, info in Zones do
		if not first or info.Order < Zones[first].Order then
			first = name
		end
	end
	if first then
		selectZone(first)
	end
	refresh()
end

return ZoneSelector
