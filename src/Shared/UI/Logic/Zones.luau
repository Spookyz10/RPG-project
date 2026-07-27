local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ZonesData = require(ReplicatedStorage.Shared.Zones)
local MobsData = require(ReplicatedStorage.Shared.MobsData)
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local ItemDisplay = require(ReplicatedStorage.Shared.UI.ItemDisplay)

local UI = {}

function UI.Init()
	local Data = UIConstants.Data
	local PlayerGui = UIConstants.PlayerGui

	local ZonesGui = PlayerGui:WaitForChild("Zones")
	local Selector = ZonesGui.Selector
	local SelectorContainer = Selector.Container

	local Info = ZonesGui.Info
	local Tabs = Info.Tabs

	local OverviewFrame = Info.Overview
	local MobsFrame = Info.Mobs
	local EnviromentFrame = Info.Enviroment

	local MobsSelector = MobsFrame.MobsSelector
	local MobsContainer = MobsSelector.Container
	local MobsAmount = MobsSelector.Amount
	local MobInfo = MobsFrame.MobInfo

	local ZoneTemplate = ReplicatedStorage.Assets.UI.ItemTemplate.Zone
	local MobTemplate = ReplicatedStorage.Assets.UI.ItemTemplate.Mob
	local DropTemplate = ReplicatedStorage.Assets.UI.ItemTemplate.Drop

	local ContentFrames = {
		Overview = OverviewFrame,
		Mobs = MobsFrame,
		Enviroment = EnviromentFrame,
	}

	local function SelectTab(tabName: string)
		for name, frame in ContentFrames do
			frame.Visible = (name == tabName)
		end
	end

	local function SetupTabs()
		for _, TabButton in Tabs:GetChildren() do
			if TabButton:IsA("ImageButton") then
				TabButton.MouseButton1Click:Connect(function()
					SelectTab(TabButton.Name)
				end)
			end
		end
	end

	local function UpdateOverview(ZoneName: string, ZoneInfo: Types.Zone)
		OverviewFrame.Icon.Image = ZoneInfo.Icon
		OverviewFrame.ZoneName.Text = ZoneName
		OverviewFrame.Level.Text = "Level: " .. ZoneInfo.Level
		OverviewFrame.MaxLevel.Text = "Max Level: " .. ZoneInfo.MaxLevel
		OverviewFrame.Description.Text = ZoneInfo.Description
	end

	local function SetupViewport(Viewport: ViewportFrame, MobName: string)
		Viewport:ClearAllChildren()

		local MobModel = Functions:getMob(MobName)
		if not MobModel then
			return
		end

		local Clone = MobModel:Clone()
		Clone.Parent = Viewport

		local Camera = Instance.new("Camera")
		Camera.Parent = Viewport
		Viewport.CurrentCamera = Camera

		local Center, Size = Clone:GetBoundingBox()
		local Distance = Size.Magnitude
		Camera.CFrame = CFrame.lookAt(
			Center.Position + Vector3.new(0, Size.Y * 0.15, Distance),
			Center.Position + Vector3.new(0, Size.Y * 0.15, 0)
		)
	end

	local function UpdateDrops(Drops: Types.Drop)
		local Container = MobInfo.Drops.Container

		for _, child in Container:GetChildren() do
			if child:IsA("ImageButton") or child:IsA("Frame") then
				child:Destroy()
			end
		end

		for itemName, dropInfo in Drops do
			local ItemInfo = ItemsData[itemName] :: Types.Item
			if not ItemInfo then
				continue
			end

			local DropFrame = DropTemplate:Clone()
			DropFrame.Name = itemName
			DropFrame.Icon.Image = ItemInfo.Data.Icon
			DropFrame.Chance.Text = dropInfo.Chance .. "%"
			UIFunctions:ApplyRarityGradient(DropFrame.Rarity, ItemInfo.Data.Rarity)

			DropFrame.MouseEnter:Connect(function()
				ItemDisplay:Hover(DropFrame, { Name = itemName })
			end)

			DropFrame.Parent = Container
		end
	end

	local function OpenMobInfo(MobName: string)
		local MobData = MobsData[MobName] :: Types.MobInfo
		if not MobData then
			return
		end

		local Header = MobInfo.Header
		SetupViewport(Header.Icon.ViewportFrame, MobName)

		Header.MobName.Text = MobName
		Header.MobLevel.Text = "Level: " .. MobData.Level
		Header.MobMaxLevel.Text = "Max Level: " .. MobData.MaxLevel

		UIFunctions:UpdateStatsContainer(MobInfo.Stats.Info, MobData.Data.Stats)
		UpdateDrops(MobData.Drops)

		MobInfo.Visible = true
	end

	local ItemFrames: { [string]: { Frame: ImageButton, Disconnectors: { () -> () } } } = {}

	local function UpdateMobFrame(MobFrame: ImageButton, Killed: number?)
		if not Killed or Killed <= 0 then
			MobFrame.Locked.Visible = true
		else
			MobFrame.Locked.Visible = false
		end
	end

	local function CreateMobFrame(MobName: string, OnUnlockChanged: (delta: number) -> ())
		local MobFrame = MobTemplate:Clone()
		MobFrame.Name = MobName
		MobFrame.MobName.Text = MobName

		local Killed = Data.MobIndex[MobName]()
		local WasUnlocked = Killed and Killed > 0

		UpdateMobFrame(MobFrame, Killed)

		MobFrame.MouseButton1Click:Connect(function()
			local CurrentKilled = Data.MobIndex[MobName]()
			if not CurrentKilled or CurrentKilled <= 0 then
				return
			end
			OpenMobInfo(MobName)
		end)

		local ChangedDisconnect = Data.MobIndex[MobName].Changed(function(NewKilled)
			UpdateMobFrame(MobFrame, NewKilled)

			local IsUnlocked = NewKilled and NewKilled > 0
			if IsUnlocked ~= WasUnlocked then
				OnUnlockChanged(IsUnlocked and 1 or -1)
				WasUnlocked = IsUnlocked
			end
		end)

		MobFrame.Parent = MobsContainer

		ItemFrames[MobName] = { Frame = MobFrame, Disconnectors = { ChangedDisconnect } }
	end

	local function LoadMobs(ZoneInfo: Types.Zone)
		for _, Entry in ItemFrames do
			for _, Disconnect in Entry.Disconnectors do
				Disconnect()
			end
			Entry.Frame:Destroy()
		end
		table.clear(ItemFrames)

		MobInfo.Visible = false

		local UnlockedCount = 0
		local function OnUnlockChanged(delta: number)
			UnlockedCount += delta
			MobsAmount.Text = UnlockedCount .. "/" .. #ZoneInfo.Mobs
		end

		for _, MobName in ZoneInfo.Mobs do
			CreateMobFrame(MobName, OnUnlockChanged)
			local Killed = Data.MobIndex[MobName]()
			if Killed and Killed > 0 then
				UnlockedCount += 1
			end
		end

		MobsAmount.Text = UnlockedCount .. "/" .. #ZoneInfo.Mobs
	end

	local function OpenZone(ZoneName: string, ZoneInfo: Types.Zone)
		Info.Visible = true
		SelectTab("Overview")
		UpdateOverview(ZoneName, ZoneInfo)
		LoadMobs(ZoneInfo)
	end

	local function CreateZoneFrame(ZoneName: string, ZoneInfo: Types.Zone)
		local Frame = ZoneTemplate:Clone()
		Frame.Name = ZoneName
		Frame.ZoneName.Text = ZoneName
		Frame.Image = ZoneInfo.Icon

		Frame.MouseButton1Click:Connect(function()
			OpenZone(ZoneName, ZoneInfo)
		end)

		Frame.Parent = SelectorContainer
	end

	OverviewFrame.Enter.MouseButton1Click:Connect(function()
		print("Clicked")
	end)

	SetupTabs()

	for ZoneName, ZoneInfo in ZonesData do
		CreateZoneFrame(ZoneName, ZoneInfo)
	end
end

return UI
