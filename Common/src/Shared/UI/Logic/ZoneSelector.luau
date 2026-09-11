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
	local selected = nil
	local busy = false
	local entries = {}

	local function refresh()
		local level = UIConstants.Data.Level()
		for name, button in entries do
			button.Status.Text = level >= Zones[name].Level and "View mobs ?" or "Locked ? View mobs"
		end
		if selected then
			local unlocked = level >= Zones[selected].Level
			detail.Enter.Text = unlocked and ("Enter " .. selected) or ("Requires level " .. Zones[selected].Level)
			detail.Enter.Active = unlocked and not busy
			detail.Enter.AutoButtonColor = unlocked and not busy
		end
	end

	local function selectZone(name)
		selected = name
		local info = Zones[name]
		Container.Visible = false
		detail.Visible = true
		detail.ZoneName.Text = name
		detail.LevelRange.Text = "Lv. " .. info.Level .. "?" .. info.MaxLevel .. "  ?  Creatures & rewards"
		for _, child in detail.Mobs:GetChildren() do
			if child:GetAttribute("ZoneMobEntry") then child:Destroy() end
		end
		detail.Mobs.CanvasPosition = Vector2.zero
		local names = table.clone(info.Mobs or {})
		-- Zones can also inherit their roster from the existing MobsData folders.
		if #names == 0 then
			local folder = ReplicatedStorage.Shared.MobsData:FindFirstChild(name)
			if folder then
				for _, module in folder:GetDescendants() do
					if module:IsA("ModuleScript") and MobsData[module.Name] then table.insert(names, module.Name) end
				end
			end
			table.sort(names, function(a, b)
				local la, lb = MobsData[a].Level or 1, MobsData[b].Level or 1
				return la == lb and a < b or la < lb
			end)
		end
		local count = 0
		for _, mobName in names do
			local mob = MobsData[mobName]
			if not mob then continue end
			count += 1
			local card = templates.MobEntry:Clone()
			card.Name = mobName
			card.Visible = true
			card:SetAttribute("ZoneMobEntry", true)
			card.LayoutOrder = count
			local level = tostring(mob.Level or 1)
			if mob.MaxLevel and mob.MaxLevel ~= mob.Level then level ..= "?" .. mob.MaxLevel end
			card.MobName.Text = mobName .. "  ?  Lv. " .. level .. (mobName == "Dire Bear" and "  ?  BOSS" or "")
			local stats = mob.Data and mob.Data.Stats or {}
			local combat = Config[mobName] or {}
			card.Stats.Text = string.format("HP %s   ?   ATK %s   ?   DEF %s\nSpeed %s   ?   Crit %s%%   ?   Respawn %ss",
				tostring(combat.Health or stats.Health or 0), tostring(stats.Attack or 0), tostring(stats.Defense or 0),
				tostring(combat.Speed or stats.Speed or 0), tostring(stats.Critical or 0), tostring(mob.RespawnTime or 5))
			local rewards = {tostring(mob.XP or 0) .. " XP"}
			local currencies = {}
			for currency in mob.Currencies or {} do table.insert(currencies, currency) end
			table.sort(currencies)
			for _, currency in currencies do table.insert(rewards, tostring(mob.Currencies[currency]) .. " " .. currency) end
			card.Rewards.Text = table.concat(rewards, "  ?  ")
			local dropNames, lines = {}, {}
			for item in mob.Drops or {} do table.insert(dropNames, item) end
			table.sort(dropNames)
			for _, item in dropNames do
				local drop = mob.Drops[item]
				table.insert(lines, item .. "  ?" .. tostring(drop.Amount or 1) .. "  ?  " .. tostring(drop.Chance or 0) .. "%")
			end
			card.Drops.Text = #lines > 0 and table.concat(lines, "\n") or "No item drops"
			card.Parent = detail.Mobs
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
		button.LevelReq.Text = "Lv. " .. info.Level .. "?" .. info.MaxLevel
		button.Activated:Connect(function() selectZone(name) end)
		button.Parent = Container
		entries[name] = button
	end
	detail.Back.Activated:Connect(function()
		detail.Visible = false
		Container.Visible = true
		selected = nil
	end)
	detail.Enter.Activated:Connect(function()
		if busy or not selected then return end
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
	refresh()
end

return ZoneSelector
