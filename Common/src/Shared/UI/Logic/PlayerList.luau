local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local UI = script.Parent.Parent
local Abbreviation = require(UI.Parent.Utils.Abbreviation)
local Constants = require(UI.UIConstants)
local PlayerCardController = require(UI.PlayerCardController)
local Ranks = require(UI.RankIcons)
local Theme = require(UI.Theme)

local PlayerList = {}
local entries = {}
local connections = {}
local list
local container
local template
local cardController
local panelTween
local toggleTween
local expandedPosition
local collapsedPosition
local expandedRotation
local collapsedRotation
local MAX_LEVEL = require(UI.Parent.getCappedInfo).Level

local function level(player: Player): number
	local stats = player:FindFirstChild("PublicStats")
	local value = stats and stats:FindFirstChild("Level")
	return value and value.Value or 0
end

local function sortEntries()
	local players = {}
	for player in entries do table.insert(players, player) end
	table.sort(players, function(a, b)
		if a == b then return false end
		if a == Constants.Player then return true end
		if b == Constants.Player then return false end
		local aLevel = level(a)
		local bLevel = level(b)
		return aLevel == bLevel and a.UserId < b.UserId or aLevel > bLevel
	end)
	for index, player in players do
		local row = entries[player]
		local playerLevel = level(player)
		row.LayoutOrder = index
		row.Level.Text = "Lvl " .. Abbreviation:Number(playerLevel)
		row.PlayerName.TextColor3 = player == Constants.Player and Theme.Blue
			or playerLevel >= MAX_LEVEL and Theme.Gold
			or Color3.fromRGB(255, 255, 255)
	end
end

function PlayerList.Toggle()
	local screen = Constants.PlayerGui.Playerlist
	local panel = screen.List
	local toggle = panel:FindFirstChild("Toggle") or screen:FindFirstChild("Toggle")
	local opened = panel:GetAttribute("Collapsed") == true
	panel:SetAttribute("Collapsed", not opened)
	panel.Visible = true
	if panelTween then panelTween:Cancel() end
	panelTween = TweenService:Create(panel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = opened and expandedPosition or collapsedPosition,
	})
	panelTween:Play()
	if toggle then
		if toggleTween then toggleTween:Cancel() end
		toggleTween = TweenService:Create(toggle.Arrow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Rotation = opened and expandedRotation or collapsedRotation,
		})
		toggleTween:Play()
	end
end

local function add(player: Player)
	if entries[player] then return end
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
	connect(row.Activated, function() cardController:Open(player, level(player)) end)
	local function updateRank()
		row.Rank.Image = Ranks[player:GetAttribute("Rank")] or ""
	end
	connect(player:GetAttributeChangedSignal("Rank"), updateRank)
	updateRank()
	sortEntries()
	task.spawn(function()
		local stats = player:WaitForChild("PublicStats", 15)
		local value = stats and stats:WaitForChild("Level", 15)
		if not entries[player] then return end
		if value then connect(value.Changed, sortEntries); sortEntries() end
	end)
end

local function remove(player: Player)
	local playerConnections = connections[player]
	if playerConnections then
		for _, connection in playerConnections do connection:Disconnect() end
	end
	connections[player] = nil
	if entries[player] then entries[player]:Destroy(); entries[player] = nil end
	cardController:OnPlayerRemoving(player)
	sortEntries()
end

function PlayerList.Init()
	list = Constants.PlayerGui.Playerlist.List
	container = list.Container
	template = list.EntryTemplate
	cardController = PlayerCardController.new(Constants.PlayerGui.PlayerCard.Main)
	local toggle = list:FindFirstChild("Toggle") or Constants.PlayerGui.Playerlist:FindFirstChild("Toggle")
	expandedPosition = list:GetAttribute("ExpandedPosition") or list.Position
	local hiddenFraction = toggle and math.clamp(1 + toggle.Position.X.Scale, 0, 1) or 1
	collapsedPosition = list:GetAttribute("CollapsedPosition") or UDim2.new(
		expandedPosition.X.Scale + list.Size.X.Scale * hiddenFraction,
		expandedPosition.X.Offset + list.Size.X.Offset * hiddenFraction,
		expandedPosition.Y.Scale,
		expandedPosition.Y.Offset
	)
	local arrow = toggle and toggle:FindFirstChild("Arrow")
	expandedRotation = arrow and (arrow:GetAttribute("ExpandedRotation") or arrow.Rotation) or 0
	collapsedRotation = arrow and (arrow:GetAttribute("CollapsedRotation") or expandedRotation + 180) or 180
	if toggle then toggle.Activated:Connect(PlayerList.Toggle) end
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == Enum.KeyCode.Tab then PlayerList.Toggle() end
	end)
	Players.PlayerAdded:Connect(add)
	Players.PlayerRemoving:Connect(remove)
	for _, player in Players:GetPlayers() do add(player) end
end

return PlayerList
