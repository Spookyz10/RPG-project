local Abbreviation = require(script.Parent.Parent.Utils.Abbreviation)
local Constants = require(script.Parent.UIConstants)
local Remotes = require(script.Parent.Parent.Utils.RemoteManager)
local StatDisplay = require(script.Parent.StatDisplay)
local Theme = require(script.Parent.Theme)
local ItemTooltip = require(script.Parent.ItemTooltip)
local ViewportCache = require(script.Parent.ViewportCache)
local Windows = require(script.Parent.WindowManager)

local PlayerCardController = {}
PlayerCardController.__index = PlayerCardController

local function duration(seconds: number): string
	seconds = math.max(0, math.floor(seconds or 0))
	return string.format("%02d:%02d:%02d", seconds // 3600, seconds // 60 % 60, seconds % 60)
end

function PlayerCardController.new(card: GuiObject)
	local self: any = setmetatable({}, PlayerCardController)
	self.Card = card
	local body = card:WaitForChild("Body") :: GuiObject
	self.Body = body:WaitForChild("Content")
	self.Profile = self.Body.Profile
	self.Details = self.Body.Details
	self.AvatarViewport = self.Profile.Avatar
	self.Gear = self.Profile.Gear
	self.Record = self.Details.Record.Grid
	self.Stats = self.Details.StatsPanel.Rows
	self.Actions = self.Body.Actions
	self.World, self.Camera = ViewportCache.EnsureViewport(self.AvatarViewport, "Camera", 32)
	self.Request = 0
	self.Viewed = nil
	self.Avatar = nil
	self.Idle = nil
	self.DefaultIdle = nil
	self.AvatarBounds = nil
	self.AvatarSize = nil
	self.PlayTime = 0
	self.SessionTime = 0
	self.TimeReceived = 0
	self.Equipment = {}
	self.Connections = {}
	local screen = card:FindFirstAncestorWhichIsA("ScreenGui")
	local inventory = Constants.PlayerGui:FindFirstChild("Inventory")
	local tooltipTemplate = inventory and inventory:FindFirstChild("ItemTooltip")
	if screen and tooltipTemplate and tooltipTemplate:IsA("GuiObject") then
		self.GearTooltipTemplate = tooltipTemplate:Clone()
		self.GearTooltipTemplate.Parent = screen
		self.GearTooltip = ItemTooltip.new()
		self.GearTooltip.Init(screen)
		for _, slot in self.Gear:GetChildren() do
			if slot:IsA("GuiObject") and slot:FindFirstChild("Icon") then
				self.GearTooltip.Bind(slot, function()
					return self.Equipment[slot.Name]
				end)
			end
		end
	end
	table.insert(self.Connections, self.AvatarViewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() self:_fit() end))
	table.insert(self.Connections, card:GetPropertyChangedSignal("Visible"):Connect(function()
		if not card.Visible then self:_stop() end
	end))
	table.insert(self.Connections, self.Actions.Invite.Activated:Connect(function()
		local player = self.Viewed
		if player and player.Parent and player ~= Constants.Player then
			Remotes.SendServerEvent("InviteToParty", player)
		end
	end))
	table.insert(self.Connections, self.Actions.Trade.Activated:Connect(function()
		if self.Viewed and self.Viewed ~= Constants.Player then
			self.Actions.Status.Text = "Trading will be available soon."
		end
	end))
	return self
end

function PlayerCardController:_fit()
	if self.Avatar and self.AvatarBounds and self.AvatarSize then
		ViewportCache.Fit(self.AvatarViewport, self.Avatar, self.Camera, 1, self.AvatarBounds, self.AvatarSize)
	end
end

function PlayerCardController:_clearAvatar()
	if self.Idle then
		self.Idle:Stop(0)
		self.Idle:Destroy()
		self.Idle = nil
	end
	if self.DefaultIdle then
		self.DefaultIdle:Stop(0)
		self.DefaultIdle:Destroy()
		self.DefaultIdle = nil
	end
	if self.Avatar then
		self.Avatar:Destroy()
		self.Avatar = nil
	end
	self.AvatarBounds = nil
	self.AvatarSize = nil
end

function PlayerCardController:_stop()
	self.Request += 1
	self.Viewed = nil
	self:_clearAvatar()
end

function PlayerCardController:_refreshTimes()
	local elapsed = math.max(0, os.clock() - self.TimeReceived)
	self.Record.PlayTime.Value.Text = duration(self.PlayTime + elapsed)
	self.Record.SessionTime.Value.Text = duration(self.SessionTime + elapsed)
end

function PlayerCardController:_startTimer(token: number)
	task.spawn(function()
		while self.Request == token and self.Card.Visible do
			self:_refreshTimes()
			task.wait(1)
		end
	end)
end

function PlayerCardController:_reset(player: Player, publicLevel: number)
	self:_clearAvatar()
	table.clear(self.Equipment)
	self.Profile.PlayerName.Text = player.DisplayName .. "  @" .. player.Name
	self.Profile.LevelBadge.Level.Text = "LEVEL " .. Abbreviation:Number(publicLevel)
	self.Actions.Status.Text = "Loading profile..."
	self.AvatarViewport.Status.Text = "Loading avatar..."
	self.AvatarViewport.Status.Visible = true
	self.Actions.Invite.Visible = false
	self.Actions.Trade.Visible = false
	for _, row in self.Stats:GetChildren() do
		if row:IsA("Frame") and row:FindFirstChild("Value") then
			row.Value.Text = "--"
			StatDisplay.ApplyPotion(row, row.Name, 0)
		end
	end
	for _, row in self.Record:GetChildren() do
		if row:IsA("Frame") and row:FindFirstChild("Value") then
			row.Value.Text = "--"
		end
	end
	for _, slot in self.Gear:GetChildren() do
		if slot:IsA("Frame") and slot:FindFirstChild("Icon") then
			slot.Icon.Image = ""
			slot.UIStroke.Color = Theme.Line
		end
	end
end

function PlayerCardController:_populate(player: Player, info)
	self.Actions.Status.Text = ""
	self.Profile.LevelBadge.Level.Text = "LEVEL " .. Abbreviation:Number(info.Level)
	for _, key in { "Gold", "Kills", "Deaths" } do
		self.Record[key].Value.Text = Abbreviation:Number(info[key] or 0)
	end
	self.PlayTime = info.PlayTime or 0
	self.SessionTime = info.SessionTime or 0
	self.TimeReceived = os.clock()
	for _, row in self.Stats:GetChildren() do
		if row:IsA("Frame") and row:FindFirstChild("Value") then
			StatDisplay.ApplyRow(row, row.Name, (info.Stats or {})[row.Name] or 0, (info.ExtraStats or {})[row.Name] or 0)
		end
	end
	for _, slot in self.Gear:GetChildren() do
		if slot:IsA("Frame") and slot:FindFirstChild("Icon") then
			local item = (info.Equipment or {})[slot.Name]
			self.Equipment[slot.Name] = item
			slot.Icon.Image = item and item.Icon or ""
			slot.UIStroke.Color = item and (Theme.Rarities[item.Rarity] or Theme.Muted) or Theme.Line
		end
	end
	self.Actions.Invite.Visible = player ~= Constants.Player
	self.Actions.Trade.Visible = player ~= Constants.Player
end

function PlayerCardController:Open(player: Player, publicLevel: number)
	self.Request += 1
	local token = self.Request
	self.Viewed = player
	Windows.Open("PlayerCard")
	self:_reset(player, publicLevel)
	local ok, info = pcall(function()
		return Remotes.InvokeServerFunction("GetPlayerInfo", player)
	end)
	if self.Request ~= token or not player.Parent or not self.Card.Visible then
		return
	end
	if not ok or not info then
		self.Actions.Status.Text = "Profile unavailable. Try again."
		return
	end
	self:_populate(player, info)
	self:_startTimer(token)
	local avatar = ViewportCache.GetPlayerModel(player)
	if not avatar then
		if self.Request == token then
			self.AvatarViewport.Status.Text = "Avatar unavailable"
		end
		return
	end
	if self.Request ~= token or not self.Card.Visible then
		avatar:Destroy()
		return
	end
	self.Avatar = avatar
	self.Avatar.Parent = self.World
	self.AvatarBounds, self.AvatarSize = self.Avatar:GetBoundingBox()
	local weapon = info.PreviewWeapon or (info.Equipment or {}).Weapon
	if weapon then
		ViewportCache.AttachWeapon(self.Avatar, weapon.Name, weapon.WeaponType)
	end
	self.Idle = ViewportCache.PlayIdle(self.Avatar, weapon and weapon.WeaponType, false)
	self.DefaultIdle = ViewportCache.PlayDefaultIdle(self.Avatar)
	self:_fit()
	self.AvatarViewport.Status.Visible = false
end

function PlayerCardController:OnPlayerRemoving(player: Player)
	if self.Viewed ~= player then
		return
	end
	self:_stop()
	Windows.CloseScreen("PlayerCard")
end

function PlayerCardController:Destroy()
	self:_stop()
	if self.GearTooltipTemplate then
		self.GearTooltipTemplate:Destroy()
	end
	for _, connection in self.Connections do
		connection:Disconnect()
	end
	table.clear(self.Connections)
end

return PlayerCardController
