local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)
local Raids = require(ReplicatedStorage.Shared.Raids)
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local RaidsUI = {}

local DEFAULT_CATEGORY = "Standard"

local RaidList: ScrollingFrame = nil
local Clicked: Frame = nil
local RewardsScroll: ScrollingFrame = nil

local RaidTemplate: GuiButton = nil
local LootTemplate: GuiObject = nil

local SelectedButton: GuiButton? = nil
local SelectedDifficultyIndex = 1

local ModeConnection: RBXScriptConnection? = nil
local EnterConnection: RBXScriptConnection? = nil

local ToggledItems: { [string]: boolean } = {}

local function FormatTime(seconds: number?): string
	if not seconds then
		return "TBD"
	end
	return string.format("%02i:%02i", seconds / 60 % 60, seconds % 60)
end

local function UpdateLoot(RaidInfo: Types.RaidInfo, difficulty: string)
	for _, child in RewardsScroll:GetChildren() do
		if child:IsA("ImageButton") then
			child:Destroy()
		end
	end

	local Drops = RaidInfo.Drops[difficulty]
	if not Drops then
		return
	end

	for itemName, chance in Drops do
		local ItemInfo = ItemsData[itemName] :: Types.Item
		if not ItemInfo then
			continue
		end

		local Entry = LootTemplate:Clone()
		Entry.Image = ItemInfo.Data.Icon
		Entry.ImageLabel.ImageColor3 = UIFunctions.RarityColors[ItemInfo.Data.Rarity] or Color3.fromRGB(255, 255, 255)
		Entry.ImageTransparency = 0
		Entry.rate.Text = string.format("%.1f", chance) .. "%"
		Entry.toggled.Visible = ToggledItems[itemName] == true
		Entry.Visible = true
		Entry.Parent = RewardsScroll

		Entry.MouseButton1Click:Connect(function()
			RemoteManager.SendServerEvent("ItemToggle", itemName)
			ToggledItems[itemName] = not ToggledItems[itemName]
			Entry.toggled.Visible = ToggledItems[itemName] == true
		end)
	end
end

local function UpdateModeVisual(RaidInfo: Types.RaidInfo)
	local Count = #RaidInfo.Difficulties
	local Switch = Clicked.Mode.Frame.Switch

	Clicked.Mode.Visible = Count > 1

	if Count > 1 then
		Switch.Position = UDim2.fromScale((SelectedDifficultyIndex - 1) / Count, 0)
	end

	local DifficultyName = RaidInfo.Difficulties[SelectedDifficultyIndex]
	local Color = SelectedDifficultyIndex > 1 and "rgb(255,0,0)" or "rgb(101,255,150)"
	Clicked.Mode.Current.Text = 'Mode: <font color="' .. Color .. '">' .. DifficultyName .. "</font>"
	Clicked.Warning.Visible = RaidInfo.Warning == true and SelectedDifficultyIndex > 1
end

local function RefreshDisplay(raidName: string, RaidInfo: Types.RaidInfo)
	local Difficulty = RaidInfo.Difficulties[SelectedDifficultyIndex]

	UpdateLoot(RaidInfo, Difficulty)

	Clicked.Picture.Warning.Visible = RaidInfo.Warning == true

	local Records = UIConstants.Data.RaidRecords()[raidName]
	Clicked.Info.Time.Time.Text = FormatTime(Records and Records[Difficulty])

	local Runs = UIConstants.Data.RaidRuns()[raidName]
	Clicked.Info.Runs.Runs.Text = tostring(Runs or 0)

	Clicked.Picture.Image = "rbxassetid://" .. RaidInfo.Image
	Clicked.Raid.Text = raidName

	UpdateModeVisual(RaidInfo)
end

local function OpenDisplay(raidName: string, RaidInfo: Types.RaidInfo)
	SelectedDifficultyIndex = 1
	RefreshDisplay(raidName, RaidInfo)

	if ModeConnection then
		ModeConnection:Disconnect()
	end
	if EnterConnection then
		EnterConnection:Disconnect()
	end

	ModeConnection = Clicked.Mode.Frame.Switch.MouseButton1Click:Connect(function()
		local Count = #RaidInfo.Difficulties
		if Count <= 1 then
			return
		end

		SelectedDifficultyIndex = (SelectedDifficultyIndex % Count) + 1
		RefreshDisplay(raidName, RaidInfo)
	end)

	EnterConnection = Clicked.Enter.MouseButton1Click:Connect(function()
		RemoteManager.SendServerEvent("RaidEvent", "Raid", raidName, RaidInfo.Difficulties[SelectedDifficultyIndex])
	end)
end

local function LoadRaids(category: string)
	for _, child in RaidList:GetChildren() do
		if child:IsA("ImageButton") then
			child:Destroy()
		end
	end
	SelectedButton = nil

	local SortedNames = {}
	for raidName, RaidInfo in Raids do
		if (RaidInfo :: Types.RaidInfo).Category == category then
			table.insert(SortedNames, raidName)
		end
	end

	table.sort(SortedNames, function(a, b)
		return (Raids[a] :: Types.RaidInfo).RequiredLevel < (Raids[b] :: Types.RaidInfo).RequiredLevel
	end)

	for _, raidName in SortedNames do
		local RaidInfo = Raids[raidName] :: Types.RaidInfo

		local Entry = RaidTemplate:Clone()
		Entry.Stand.Raid.Text = raidName
		Entry.Stand.Req.Text = "Lv Req: " .. RaidInfo.RequiredLevel
		Entry.Image = "rbxassetid://" .. RaidInfo.Image
		Entry.UIStroke.Transparency = 1
		Entry.LayoutOrder = RaidInfo.RequiredLevel
		Entry.Visible = true
		Entry.Parent = RaidList

		Entry.MouseButton1Click:Connect(function()
			if SelectedButton == Entry then
				return
			end

			if SelectedButton then
				SelectedButton.UIStroke.Transparency = 1
			end

			SelectedButton = Entry
			Entry.UIStroke.Transparency = 0
			OpenDisplay(raidName, RaidInfo)
		end)

		if not SelectedButton then
			SelectedButton = Entry
			Entry.UIStroke.Transparency = 0
			OpenDisplay(raidName, RaidInfo)
		end
	end

	RaidList.CanvasPosition = Vector2.new(0, 0)
end

local function SetupTabs(RaidTypes: Instance)
	local CurrentCategory = DEFAULT_CATEGORY

	for _, Button in RaidTypes:GetChildren() do
		if not Button:IsA("TextButton") then
			continue
		end

		Button.MouseButton1Click:Connect(function()
			if Button.Name == CurrentCategory then
				return
			end

			CurrentCategory = Button.Name
			LoadRaids(CurrentCategory)
		end)
	end
end

function RaidsUI.Init()
	ToggledItems = table.clone(UIConstants.Data.RaidAutoDelete())

	local Main = UIConstants.PlayerGui:WaitForChild("RaidsGUI"):WaitForChild("Main")
	local Containers = Main:WaitForChild("RaidContainers")
	local RaidTypes = Main:WaitForChild("RaidTypes")

	RaidList = Containers:WaitForChild("RaidList") :: ScrollingFrame
	Clicked = Containers:WaitForChild("RaidDisplay"):WaitForChild("Clicked") :: Frame
	RewardsScroll = Clicked.Rewards.ScrollingFrame :: ScrollingFrame

	RaidTemplate = ReplicatedStorage.Resources.UI.Templates:WaitForChild("RaidTemplate") :: GuiButton
	LootTemplate = ReplicatedStorage.Resources.UI.Templates:WaitForChild("RaidLootTemplate") :: GuiObject

	SetupTabs(RaidTypes)
	LoadRaids(DEFAULT_CATEGORY)
end

return RaidsUI
