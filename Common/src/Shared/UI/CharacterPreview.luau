local Players = game:GetService("Players")
local Functions = require(script.Parent.Parent.Utils.Functions)
local Items = require(script.Parent.Parent.ItemsData)
local StatDisplay = require(script.Parent.StatDisplay)
local ViewportCache = require(script.Parent.ViewportCache)

local Preview = {}

function Preview.Bind(root, data)
	local player = Players.LocalPlayer
	local hero = root.Body.Content.Hero
	local viewport = hero.CharacterPreview
	local world, camera = ViewportCache.EnsureViewport(viewport, "PreviewCamera", 32)
	local model: Model?
	local idle: AnimationTrack?
	local weaponKey = ""
	local idleKey = ""
	local bodyBounds: CFrame?
	local bodySize: Vector3?
	local loading = false
	local queued = false
	local destroyed = false
	local connections: { (() -> ()) | RBXScriptConnection } = {}

	local function disconnectAll()
		for _, connection in connections do
			if typeof(connection) == "function" then
				connection()
			else
				connection:Disconnect()
			end
		end
		table.clear(connections)
	end

	local function fit()
		if model and bodyBounds and bodySize then
			ViewportCache.Fit(viewport, model, camera, 0.94, bodyBounds, bodySize)
		end
	end

	local function updateStats()
		local values = Functions:GetTotalStats(player.Character, data()) or {}
		local extra = data.ExtraStats() or {}
		for _, row in hero.Stats:GetChildren() do
			if row:IsA("Frame") and row:FindFirstChild("Value") then
				local value = values[row.Name] or 0
				StatDisplay.ApplyRow(row, row.Name, value, extra[row.Name] or 0)
			end
		end
	end

	local function updateWeapon()
		if not model then
			return
		end
		local equipped = data.Equipment.Weapon()
		local entry = equipped and data.Inventory[equipped]()
		local vanity = data.Vanity.Weapon()
		local appearance = entry and ((vanity and vanity ~= "" and data.Inventory[vanity]()) or entry)
		local info = entry and Items[entry.ID]
		local weaponType = info and info.WeaponType or ""
		local name = appearance and appearance.Name or ""
		local key = name .. ":" .. weaponType
		if weaponKey ~= key then
			weaponKey = key
			ViewportCache.AttachWeapon(model, name, weaponType)
		end
		if idleKey ~= weaponType then
			idleKey = weaponType
			if idle then
				idle:Stop(0.15)
				idle:Destroy()
			end
			idle = ViewportCache.PlayIdle(model, weaponType)
		end
	end

	local function refresh()
		if destroyed or not root.Visible or not hero.Visible then
			return
		end
		updateStats()
		if loading then
			return
		end
		if not model then
			loading = true
			viewport.Status.Visible = true
			local avatar = ViewportCache.GetPlayerModel(player)
			loading = false
			if destroyed then
				if avatar then
					avatar:Destroy()
				end
				return
			end
			if not avatar then
				viewport.Status.Text = "Hero preview unavailable"
				return
			end
			avatar.Parent = world
			bodyBounds, bodySize = avatar:GetBoundingBox()
			model = avatar
			fit()
		end
		viewport.Status.Visible = false
		updateWeapon()
		if idle then
			idle:AdjustSpeed(1)
		end
	end

	local function schedule()
		if destroyed or queued then
			return
		end
		queued = true
		task.delay(0.15, function()
			queued = false
			if not destroyed then
				refresh()
			end
		end)
	end

	local function visibility()
		if idle then
			idle:AdjustSpeed(root.Visible and hero.Visible and 1 or 0)
		end
		schedule()
	end

	table.insert(connections, root:GetPropertyChangedSignal("Visible"):Connect(visibility))
	table.insert(connections, hero:GetPropertyChangedSignal("Visible"):Connect(visibility))
	table.insert(connections, viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit))
	table.insert(connections, player.CharacterAdded:Connect(function()
		if idle then
			idle:Stop(0)
			idle:Destroy()
			idle = nil
		end
		if model then
			model:Destroy()
			model = nil
		end
		weaponKey, idleKey = "", ""
		bodyBounds, bodySize = nil, nil
		schedule()
	end))
	for _, key in { "Equipment", "Vanity", "ExtraStats", "Level", "Inventory" } do
		local connection = data[key].Changed(schedule)
		if connection then
			table.insert(connections, connection)
		end
	end
	schedule()
	root.Destroying:Connect(function()
		destroyed = true
		disconnectAll()
		if idle then
			idle:Stop()
			idle:Destroy()
		end
		if model then
			model:Destroy()
		end
	end)
end

return Preview
