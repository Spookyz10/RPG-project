local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local UI = script.Parent.Parent
local Constants = require(UI.UIConstants)
local Theme = require(UI.Theme)
local Ranks = require(UI.RankIcons)
local Windows = require(UI.WindowManager)
local Remotes = require(UI.Parent.Utils.RemoteManager)
local Cap = require(UI.Parent.getCappedInfo).Level
local Playerlist = {}
local panelTween
local toggleTween
function Playerlist.Toggle()
	local screen = Constants.PlayerGui.Playerlist
	local panel = screen.List
	local toggle = panel:FindFirstChild("Toggle") or screen:FindFirstChild("Toggle")
	local opened = panel:GetAttribute("Collapsed") == true
	panel:SetAttribute("Collapsed", not opened)
	panel.Visible = true
	if panelTween then panelTween:Cancel() end
	panelTween = game:GetService("TweenService"):Create(
		panel,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = UDim2.fromScale(opened and 1 or 1.251, 0) }
	)
	panelTween:Play()
	if toggle then
		if toggleTween then
			toggleTween:Cancel()
		end
		toggleTween = game:GetService("TweenService"):Create(
			toggle.Arrow,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Rotation = opened and 0 or 180 }
		)
		toggleTween:Play()
	end
end

local entries, connections, avatars = {}, {}, {}
local list, container, template, card, body, camera
local viewed, request = nil, 0
local timeReceived, playTime, sessionTime = 0, 0, 0

local function duration(seconds)
	seconds = math.max(0, math.floor(seconds or 0))
	return string.format("%02d:%02d:%02d", seconds // 3600, seconds // 60 % 60, seconds % 60)
end
local function refreshTimes()
	local elapsed = math.max(0, os.clock() - timeReceived)
	body.Record.PlayTime.Value.Text = duration(playTime + elapsed)
	body.Record.SessionTime.Value.Text = duration(sessionTime + elapsed)
end
local function level(player)
	local stats = player:FindFirstChild("PublicStats")
	local value = stats and stats:FindFirstChild("Level")
	return value and value.Value or 0
end
local function sort()
	local players = {}
	for player in entries do
		table.insert(players, player)
	end
	table.sort(players, function(a, b)
		if a == b then
			return false
		end
		if a == Constants.Player then
			return true
		end
		if b == Constants.Player then
			return false
		end
		if level(a) ~= level(b) then
			return level(a) > level(b)
		end
		return a.UserId < b.UserId
	end)
	for index, player in players do
		local row = entries[player]
		row.LayoutOrder = index
		row.Level.Text = "Lvl " .. tostring(level(player))
		row.PlayerName.TextColor3 = player == Constants.Player and Theme.Blue
			or level(player) >= Cap and Theme.Gold
			or Color3.fromRGB(255, 255, 255)
	end
end
local function fit()
	body.Avatar.CurrentCamera = camera
	body.Avatar.ImageTransparency = 0
	body.Avatar.Visible = true
	local model = body.Avatar.World:FindFirstChildOfClass("Model")
	if not model then
		return
	end
	local bounds, size = model:GetBoundingBox()
	local aspect = math.max(0.25, body.Avatar.AbsoluteSize.X / math.max(1, body.Avatar.AbsoluteSize.Y))
	local tangent = math.tan(math.rad(camera.FieldOfView / 2))
	local distance = math.max(size.Y / 2 / tangent, size.X / 2 / tangent / aspect) + size.Z / 2
	camera.CFrame = CFrame.lookAt(bounds.Position + Vector3.new(0, 0, distance), bounds.Position)
end
local function hideAvatar()
	for _, model in body.Avatar.World:GetChildren() do
		model.Parent = nil
	end
end
function Playerlist.OpenCard(player)
	request += 1
	local token = request
	viewed = player
	Windows.Open("PlayerCard")
	hideAvatar()
	body.PlayerName.Text = player.DisplayName .. "  @" .. player.Name
	body.Status.Text = "Loading profile..."
	body.Stats.Text = "Loading stats..."
	body.Level.Text = "Level " .. level(player)
	body.Avatar.Status.Text = "Loading avatar..."
	body.Avatar.Status.Visible = true
	body.Invite.Visible = false
	for _, row in body.Record:GetChildren() do
		row.Value.Text = "--"
	end
	for _, slot in body.Gear:GetChildren() do
		if slot:IsA("ImageLabel") then
			slot.Image = ""
		end
	end
	local ok, info = pcall(function()
		return Remotes.InvokeServerFunction("GetPlayerInfo", player)
	end)
	if request ~= token or not player.Parent or not card.Visible then
		return
	end
	if not ok or not info then
		body.Status.Text = "Profile unavailable. Try again."
		return
	end
	body.Status.Text = ""
	body.Level.Text = "Level " .. tostring(info.Level)
	for _, key in { "Gold", "Kills", "Deaths" } do
		body.Record[key].Value.Text = tostring(info[key] or 0)
	end
	playTime, sessionTime, timeReceived = info.PlayTime or 0, info.SessionTime or 0, os.clock()
	refreshTimes()
	local stats = info.Stats or {}
	body.Stats.Text = string.format(
		"ATK %s   DEF %s   HP %s   SPD %s   CRIT %s%%",
		tostring(stats.Attack or 0),
		tostring(stats.Defense or 0),
		tostring(stats.Health or 0),
		tostring(stats.Speed or 0),
		tostring(stats.Critical or 0)
	)
	for _, slot in body.Gear:GetChildren() do
		if slot:IsA("ImageLabel") then
			local item = (info.Equipment or {})[slot.Name]
			slot.Image = item and item.Icon or ""
			slot.BackgroundColor3 = item and Theme.Rarities[item.Rarity] or Theme.Surface
		end
	end
	body.Invite.Visible = player ~= Constants.Player
	local avatar = avatars[player]
	if not avatar then
		local loaded, result = pcall(function()
			local character = player.Character
			if character and character:FindFirstChild("HumanoidRootPart") then
				local archivable = character.Archivable
				character.Archivable = true
				local success, clone = pcall(function() return character:Clone() end)
				character.Archivable = archivable
				if success and clone then return clone end
			end
			return Players:CreateHumanoidModelFromUserIdAsync(player.UserId)
		end)
		if not loaded then
			if request == token then
				body.Avatar.Status.Text = "Avatar unavailable"
			end
			return
		end
		avatar = result
		for _, object in avatar:GetDescendants() do
			if
				object:IsA("LuaSourceContainer") or object:IsA("LayerCollector") or object.Name == "Hitbox"
				or object:IsA("ParticleEmitter")
				or object:IsA("Trail")
				or object:IsA("Beam")
				or object:IsA("Sound")
			then
				object:Destroy()
			elseif object:IsA("BasePart") then
				object.Anchored = true
				object.LocalTransparencyModifier = 0
				object.CanTouch = false
				object.CanQuery = false
				object.CanCollide = false
			end
		end
		avatar:PivotTo(CFrame.Angles(0, math.pi, 0))
		if not player.Parent then
			avatar:Destroy()
			return
		end
		if avatars[player] then
			avatar:Destroy()
			avatar = avatars[player]
		else
			avatars[player] = avatar
		end
	end
	if request ~= token or not card.Visible then
		return
	end
	avatar.Parent = body.Avatar.World
	fit()
	body.Avatar.Status.Visible = false
end
local function add(player)
	if entries[player] then
		return
	end
	local row = template:Clone()
	row.Name = player.Name
	row.PlayerName.Text = player.Name
	row.Visible = true
	row.Parent = container
	entries[player] = row
	connections[player] = {}
	local function connect(signal, callback)
		table.insert(connections[player], signal:Connect(callback))
	end
	connect(row.Activated, function()
		Playerlist.OpenCard(player)
	end)
	local function rank()
		row.Rank.Image = Ranks[player:GetAttribute("Rank")] or ""
	end
	connect(player:GetAttributeChangedSignal("Rank"), rank)
	rank()
	sort()
	task.spawn(function()
		local stats = player:WaitForChild("PublicStats", 15)
		local value = stats and stats:WaitForChild("Level", 15)
		if not entries[player] then
			return
		end
		if value then
			connect(value.Changed, sort)
			sort()
		end
	end)
end
local function remove(player)
	if connections[player] then
		for _, connection in connections[player] do
			connection:Disconnect()
		end
	end
	connections[player] = nil
	if entries[player] then
		entries[player]:Destroy()
		entries[player] = nil
	end
	if avatars[player] then
		avatars[player]:Destroy()
		avatars[player] = nil
	end
	if viewed == player then
		request += 1
		viewed = nil
		Windows.CloseScreen("PlayerCard")
	end
	sort()
end
function Playerlist.Init()
	list = Constants.PlayerGui.Playerlist.List
	local toggle = list:FindFirstChild("Toggle") or Constants.PlayerGui.Playerlist:FindFirstChild("Toggle")
	if toggle then
		toggle.Arrow.Rotation = list.Visible and 0 or -90
		toggle.Activated:Connect(Playerlist.Toggle)
	end
	container, template = list.Container, list.EntryTemplate
	card = Constants.PlayerGui.PlayerCard.Main
	body = card.Body.Content
	camera = body.Avatar:FindFirstChildOfClass("Camera") or Instance.new("Camera")
	camera.Parent = body.Avatar
	camera.FieldOfView = 32
	body.Avatar.CurrentCamera = camera
	body.Avatar:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	card:GetPropertyChangedSignal("Visible"):Connect(function()
		if not card.Visible then
			request += 1
			hideAvatar()
		end
	end)
	body.Invite.Activated:Connect(function()
		if viewed and viewed.Parent and viewed ~= Constants.Player then
			Remotes.SendServerEvent("InviteToParty", viewed)
		end
	end)
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == Enum.KeyCode.Tab then
			Playerlist.Toggle()
		end
	end)
	Players.PlayerAdded:Connect(add)
	Players.PlayerRemoving:Connect(remove)
	for _, player in Players:GetPlayers() do
		add(player)
	end
	task.spawn(function()
		while card.Parent do
			task.wait(1)
			if card.Visible and body.Status.Text == "" then
				refreshTimes()
			end
		end
	end)
end
return Playerlist
