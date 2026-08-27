local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Abbreviation = require(ReplicatedStorage.Shared.Utils.Abbreviation)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)

local Playerlist = {}

local HonorRankIcons = {
	{ Honor = 100000, Icon = "rbxassetid://3513549243" },
	{ Honor = 50000, Icon = "rbxassetid://3513548831" },
	{ Honor = 10000, Icon = "rbxassetid://3513548371" },
	{ Honor = 1000, Icon = "rbxassetid://3513548115" },
	{ Honor = 100, Icon = "rbxassetid://3513547796" },
}

local EquipmentSlots = {
	{ Frame = "Sword", Slot = "Weapon" },
	{ Frame = "Accessory", Slot = "Ring" },
	{ Frame = "Accessory2", Slot = "Necklace" },
	{ Frame = "Aura", Slot = "Aura" },
	{ Frame = "Armor", Slot = "Armor" },
}

local ListGui: ScreenGui = nil
local List: Frame = nil
local Container: ScrollingFrame = nil
local HiderButton: TextButton = nil
local Template: Frame = nil
local Card: Frame = nil
local CardMain: Frame = nil

local Entries: { [Player]: Frame } = {}
local Expanded = true

local function GetRankIcon(honor: number): string?
	for _, entry in HonorRankIcons do
		if honor >= entry.Honor then
			return entry.Icon
		end
	end
	return nil
end

local function UpdateEntryLevel(Entry: Frame, level: number)
	Entry.Stats.Level.Text = "Lv" .. tostring(level)
end

local function UpdateEntryHonor(Entry: Frame, honor: number)
	local Icon = Entry:FindFirstChild("Icon") :: ImageLabel?
	if not Icon then
		return
	end

	local RankIcon = GetRankIcon(honor)
	Icon.Visible = RankIcon ~= nil

	if RankIcon then
		Icon.Image = RankIcon
	end
end

local function CreateEntry(targetPlayer: Player)
	if Entries[targetPlayer] then
		return
	end

	local Entry = Template:Clone()
	Entry.Name = targetPlayer.Name
	Entry.Visible = true
	Entry.Info.User.Text = targetPlayer.Name
	Entry.LayoutOrder = targetPlayer == UIConstants.Player and 0 or 1
	Entry.Parent = Container

	Entries[targetPlayer] = Entry

	local Stats = targetPlayer:WaitForChild("PublicStats")
	local LevelValue = Stats:WaitForChild("Level") :: NumberValue
	local HonorValue = Stats:WaitForChild("Honor") :: NumberValue

	UpdateEntryLevel(Entry, LevelValue.Value)
	UpdateEntryHonor(Entry, HonorValue.Value)

	LevelValue.Changed:Connect(function(newLevel)
		UpdateEntryLevel(Entry, newLevel)
	end)

	HonorValue.Changed:Connect(function(newHonor)
		UpdateEntryHonor(Entry, newHonor)
	end)

	Entry.View.MouseButton1Click:Connect(function()
		Playerlist.OpenCard(targetPlayer)
	end)
end

local function RemoveEntry(targetPlayer: Player)
	local Entry = Entries[targetPlayer]
	if Entry then
		Entry:Destroy()
		Entries[targetPlayer] = nil
	end
end

local function ToggleList()
	Expanded = not Expanded
	HiderButton.Text = Expanded and "<<" or ">>"

	local Goal = Expanded and UDim2.fromScale(0.78, 0) or UDim2.fromScale(1, 0)
	Container:TweenPosition(Goal, Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.1, false)
end

local function PopulateItems(Equipment: { [string]: { Icon: string, SubType: string, Rarity: string } })
	local ItemsFrame = CardMain.Items

	for _, entry in EquipmentSlots do
		local ItemFrame = ItemsFrame:FindFirstChild(entry.Frame) :: ImageLabel?
		if not ItemFrame then
			continue
		end

		local EquippedItem = Equipment[entry.Slot]
		local RarityTag = ItemFrame:FindFirstChild("Rarity") :: ImageLabel?

		if EquippedItem then
			ItemFrame.Image = EquippedItem.Icon
			if RarityTag then
				RarityTag.ImageColor3 = UIFunctions.RarityColors[EquippedItem.Rarity] or Color3.fromRGB(255, 255, 255)
				RarityTag.ImageTransparency = 0.5
			end
		else
			ItemFrame.Image = ""
			if RarityTag then
				RarityTag.ImageTransparency = 1
			end
		end
	end

	local RuneIcon = CardMain.ImageLabel:FindFirstChild("Rune") :: ImageLabel?
	if RuneIcon then
		local RuneItem = Equipment.Rune
		RuneIcon.Image = RuneItem and RuneItem.Icon or ""
	end
end

function Playerlist.OpenCard(targetPlayer: Player)
	local Info = RemoteManager.InvokeServerFunction("GetPlayerInfo", targetPlayer)
	if not Info then
		return
	end

	local success, thumbnail = pcall(
		Players.GetUserThumbnailAsync,
		Players,
		targetPlayer.UserId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size420x420
	)
	CardMain.ImageLabel.Image = success and thumbnail or ""

	CardMain.PlayerName.Text = Info.Name .. "'s Player Card"

	CardMain.Stats.Gold.Amount.Text = Abbreviation:Number(Info.Gold)
	CardMain.Stats.Kills.Amount.Text = tostring(Info.Kills)
	CardMain.Stats.Honor.Amount.Text = tostring(Info.Honor)

	local Attributes = CardMain.Stats.Attributes
	Attributes.ATK.Text = "ATK: " .. tostring(math.floor(Info.Stats.Attack))
	Attributes.DEF.Text = "DEF: " .. tostring(math.floor(Info.Stats.Defense))
	Attributes.SPD.Text = "SPD: " .. tostring(math.floor(Info.Stats.Speed))
	Attributes.CRT.Text = "CRT: " .. tostring(math.floor(Info.Stats.Critical))
	Attributes.HP.Text = "HP: " .. tostring(math.floor(Info.Stats.Health))

	CardMain.Hours.Text = Functions.FormatTime(Info.PlayTime) .. " Played"

	PopulateItems(Info.Equipment)

	Card.Visible = true
end

local function CloseCard()
	Card.Visible = false
end

function Playerlist.Init()
	ListGui = UIConstants.PlayerGui:WaitForChild("Playerlist") :: ScreenGui
	List = ListGui:WaitForChild("List") :: Frame
	Container = List:WaitForChild("Container") :: ScrollingFrame
	HiderButton = List:WaitForChild("TextButton") :: TextButton
	Template = ReplicatedStorage.Resources.UI.Templates:WaitForChild("ListTemplate") :: Frame
	Template.Visible = false

	Card = ListGui:WaitForChild("Card") :: Frame
	CardMain = Card:WaitForChild("Main") :: Frame
	Card.Visible = false

	CardMain.Trade.Visible = false
	CardMain.Titles.Visible = false
	CardMain.Party.Visible = false
	CardMain.Title.Visible = false
	CardMain.Rep.Visible = false
	CardMain.Items.Pet.Visible = false

	CardMain.Close.MouseButton1Click:Connect(CloseCard)
	HiderButton.MouseButton1Click:Connect(ToggleList)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.Tab then
			ToggleList()
		end
	end)

	for _, existingPlayer in Players:GetPlayers() do
		CreateEntry(existingPlayer)
	end

	Players.PlayerAdded:Connect(CreateEntry)
	Players.PlayerRemoving:Connect(RemoveEntry)
end

return Playerlist
