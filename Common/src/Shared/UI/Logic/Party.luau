local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.Theme)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Abbreviation = require(ReplicatedStorage.Shared.Utils.Abbreviation)

local PartyUI = {}

local INVITE_TIMEOUT_FALLBACK = 10
local PartyPanel: Frame
local Members: ScrollingFrame
local EntryTemplate: Frame
local InviteQueue: Frame
local InviteTemplate: CanvasGroup
local Overlay: Frame
type EntryState = {
	Connections: { RBXScriptConnection },
	CharacterConnections: { RBXScriptConnection },
}

local Entries: { [Frame]: EntryState } = {}
local Invites: { [string]: CanvasGroup } = {}
local inviteOrder = 0

local function disconnect(connections: { RBXScriptConnection })
	for _, connection in connections do connection:Disconnect() end
	table.clear(connections)
end

local function updateOverlayVisibility()
	Overlay.Visible = PartyPanel.Visible or next(Invites) ~= nil
end

local function clearEntries()
	for entry, state in Entries do
		disconnect(state.Connections)
		disconnect(state.CharacterConnections)
		entry:Destroy()
	end
	table.clear(Entries)
end

local function clearInvites()
	for _, prompt in Invites do
		prompt:Destroy()
	end
	table.clear(Invites)
end

local function memberLevel(player: Player): number
	local stats = player:FindFirstChild("PublicStats")
	local level = stats and stats:FindFirstChild("Level")
	return level and level:IsA("NumberValue") and level.Value or 0
end

local function bindMember(entry: Frame, memberName: string)
	local state: EntryState = { Connections = {}, CharacterConnections = {} }
	Entries[entry] = state
	local player = Players:FindFirstChild(memberName)
	if not player then return end

	local function refresh()
		if not entry.Parent then return end
		entry.Level.Text = "LV. " .. Abbreviation:Number(memberLevel(player))
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		local health = humanoid and math.max(0, humanoid.Health) or 0
		local maxHealth = humanoid and math.max(1, humanoid.MaxHealth) or 1
		entry.Health.Main.Amount.Text = Abbreviation:Number(health) .. " / " .. Abbreviation:Number(maxHealth)
		entry.Health.Main.Bar.Size = UDim2.fromScale(math.clamp(health / maxHealth, 0, 1), 1)
	end
	local function bindCharacter(character: Model)
		disconnect(state.CharacterConnections)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			table.insert(state.CharacterConnections, humanoid.HealthChanged:Connect(refresh))
			table.insert(state.CharacterConnections, humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(refresh))
		end
		refresh()
	end

	local function bindLevel(stats: Instance?)
		local level = stats and stats:FindFirstChild("Level")
		if level and level:IsA("NumberValue") then
			table.insert(state.Connections, level.Changed:Connect(refresh))
		end
		refresh()
	end
	bindLevel(player:FindFirstChild("PublicStats"))
	table.insert(state.Connections, player.ChildAdded:Connect(function(child)
		if child.Name == "PublicStats" then bindLevel(child) end
	end))
	table.insert(state.Connections, player.CharacterAdded:Connect(bindCharacter))
	if player.Character then bindCharacter(player.Character) else refresh() end
end

function PartyUI.OnUpdate(members: { [string]: boolean }, leaderName: string)
	clearEntries()
	clearInvites()
	PartyPanel.Visible = true
	updateOverlayVisibility()

	local names = {}
	for memberName in members do table.insert(names, memberName) end
	table.sort(names, function(a, b)
		if a == leaderName then return true end
		if b == leaderName then return false end
		return a < b
	end)

	for index, memberName in names do
		local entry = EntryTemplate:Clone()
		entry.Name = memberName
		entry.LayoutOrder = index
		entry.Visible = true
		entry.Parent = Members
		entry.NameLabel.Text = memberName
		entry.NameLabel.TextColor3 = memberName == leaderName and Theme.Gold or Theme.Ink
		entry.Leader.Visible = memberName == leaderName
		entry.Kick.Visible = leaderName == UIConstants.Player.Name and memberName ~= UIConstants.Player.Name
		if entry.Kick.Visible then
			entry.Kick.Activated:Connect(function()
				RemoteManager.SendServerEvent("KickFromParty", memberName)
			end)
		end
		bindMember(entry, memberName)
	end
end

function PartyUI.OnLeave()
	clearEntries()
	PartyPanel.Visible = false
	updateOverlayVisibility()
end

function PartyUI.OnInvite(inviterName: string, duration: number?)
	local old = Invites[inviterName]
	if old then old:Destroy() end

	inviteOrder += 1
	local prompt = InviteTemplate:Clone()
	prompt.Name = "Invite_" .. inviterName
	prompt.LayoutOrder = -inviteOrder
	prompt.Visible = true
	prompt.GroupTransparency = 1
	prompt.Inviter.Text = inviterName .. " invited you to join their party"
	prompt.Parent = InviteQueue
	Invites[inviterName] = prompt
	updateOverlayVisibility()

	local scale = prompt:FindFirstChild("Pop") :: UIScale
	scale.Scale = 0.88
	TweenService:Create(prompt, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 0 }):Play()
	TweenService:Create(scale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

	local answered = false
	local function cleanup()
		if answered then return end
		answered = true
		if Invites[inviterName] == prompt then Invites[inviterName] = nil end
		if prompt.Parent then
			TweenService:Create(prompt, TweenInfo.new(0.16, Enum.EasingStyle.Quad), { GroupTransparency = 1 }):Play()
			task.delay(0.17, function()
				if prompt.Parent then prompt:Destroy() end
			end)
		end
		updateOverlayVisibility()
	end

	prompt.Accept.Activated:Connect(function()
		RemoteManager.SendServerEvent("AcceptPartyInvite", inviterName)
		cleanup()
	end)
	prompt.Decline.Activated:Connect(function()
		RemoteManager.SendServerEvent("DeclinePartyInvite", inviterName)
		cleanup()
	end)
	local timeout = math.max(duration or INVITE_TIMEOUT_FALLBACK, 0)
	local expiresAt = os.clock() + timeout
	local expiresLabel = prompt:FindFirstChild("Expires") :: TextLabel?

	task.spawn(function()
		while prompt.Parent and not answered do
			local remaining = math.max(0, math.ceil(expiresAt - os.clock()))
			if expiresLabel then
				expiresLabel.Text = "Expires in " .. remaining .. "s"
			end
			if remaining <= 0 then
				cleanup()
				break
			end
			task.wait(math.min(1, expiresAt - os.clock()))
		end
	end)
end

function PartyUI.Init()
	local hud = UIConstants.PlayerGui:WaitForChild("HUD")
	Overlay = hud.Main:WaitForChild("PartyOverlay") :: Frame
	PartyPanel = Overlay:WaitForChild("PartyPanel") :: Frame
	Members = PartyPanel:WaitForChild("Members") :: ScrollingFrame
	EntryTemplate = Members:WaitForChild("EntryTemplate") :: Frame
	InviteQueue = Overlay:WaitForChild("InviteQueue") :: Frame
	InviteTemplate = InviteQueue:WaitForChild("InviteTemplate") :: CanvasGroup

	PartyPanel.Visible = false
	InviteTemplate.Visible = false
	Overlay.Visible = false
	PartyPanel.Leave.Activated:Connect(function()
		RemoteManager.SendServerEvent("LeaveParty")
	end)
end

return PartyUI
