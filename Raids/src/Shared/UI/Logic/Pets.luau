local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Abbreviation = require(ReplicatedStorage.Shared.Utils.Abbreviation)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Talents = require(ReplicatedStorage.Shared.Talents)
local TalentColors = require(ReplicatedStorage.Shared.TalentColors)
local PetsData = require(ReplicatedStorage.Shared.PetsData)

local PetUI = {}

local Templates = ReplicatedStorage.Resources.UI.Templates

local PetGui: ScreenGui = nil

local BuyOrSee: Frame = nil
local Boxes: Frame = nil
local PetInventory: Frame = nil
local Fusion: Frame = nil
local FusionFrame: Frame = nil

local InventoryList: ScrollingFrame = nil
local InventoryTemplate: GuiObject = nil
local InventoryEntries: { [string]: GuiObject } = {}

local EquippedFrame: Frame = nil
local VanityNameLabel: TextLabel = nil

local ConfirmationFrame: Frame = nil
local PendingDelete: string? = nil

local FusionPetsFrame: ScrollingFrame = nil
local FusionTemplate: GuiObject = nil
local FusionEntries: { [string]: GuiObject } = {}
local SelectedCatalyst: string? = nil

local RewardFrames: { [number]: Frame } = {}
local PetObtainedTemplate: GuiObject = nil

local GoldAmountLabel: TextLabel = nil

local BoxRarities = { "Common", "Uncommon", "Rare" }

local BuyLocked = false

local RarityLayoutOrder = {
	Godly = 0,
	Legendary = 1,
	Rare = 2,
	Uncommon = 3,
	Common = 4,
}

local ConfirmRarities = {
	Legendary = true,
	Godly = true,
}

local EQUIPPED_NAME_COLOR = Color3.fromRGB(55, 255, 55)
local DEFAULT_NAME_COLOR = Color3.fromRGB(255, 255, 255)

local CAMERA_ANGLE = CFrame.Angles(0.08726646259971647, math.pi, 0)

local CREATE_BUDGET_PER_FRAME = 6

type QueuedCreate = {
	Kind: "Inventory" | "Fusion",
	UUID: string,
	PetEntry: Types.PetData,
}

local CreateQueue: { QueuedCreate } = {}
local QueueRunning = false

local PetsDirty = false

local function HideAllPetFrames()
	Boxes.Visible = false
	PetInventory.Visible = false
	Fusion.Visible = false
	BuyOrSee.Visible = false
end

local function ShowFrame(frame: Frame)
	HideAllPetFrames()
	frame.Visible = true
end

local function GetPetCount(): number
	local Count = 0
	for _ in UIConstants.Data.Pets() do
		Count += 1
	end
	return Count
end

local function UpdateInventoryAmount()
	local Amount = PetInventory.Inside:FindFirstChild("Amount") :: TextLabel?
	if Amount then
		Amount.Text = GetPetCount() .. "/" .. tostring(PetsData.PetLimit)
	end

	local ViewAmount = BuyOrSee.View:FindFirstChild("Amount") :: TextLabel?
	if ViewAmount then
		ViewAmount.Text = GetPetCount() .. "/" .. tostring(PetsData.PetLimit)
	end
end

local function UpdateGoldAmount()
	if not GoldAmountLabel then
		return
	end

	local Gold = UIConstants.Data.Currencies()["Gold"] or 0
	GoldAmountLabel.Text = "Gold: " .. Abbreviation:Number(Gold)
end

local function SetViewportModel(Viewport: ViewportFrame, petName: string)
	if Viewport:GetAttribute("LoadedPet") == petName then
		return
	end

	for _, child in Viewport:GetChildren() do
		if child:IsA("Model") or child:IsA("BasePart") or child:IsA("Camera") then
			child:Destroy()
		end
	end

	Viewport:SetAttribute("LoadedPet", petName)

	if petName == "" then
		return
	end

	local Template = ReplicatedStorage.Resources.Pets:FindFirstChild(petName)
	if not Template then
		return
	end

	local Clone = Template:Clone()
	Clone.Parent = Viewport

	local Camera = Instance.new("Camera")
	Camera.Parent = Viewport
	Viewport.CurrentCamera = Camera

	local RootPart = Clone:FindFirstChild("HumanoidRootPart") :: BasePart?
	if RootPart then
		Camera.CFrame = RootPart.CFrame * CAMERA_ANGLE * CFrame.new(0, 0, RootPart.Size.Z * 4.5)
		return
	end

	local Base = Clone:FindFirstChild("Base")
	local View = Base and Base:FindFirstChild("View")
	if View and View:IsA("BasePart") then
		Camera.CFrame = View.CFrame * CFrame.new(0, -0.1, 2.5)
	end
end

local function ApplyTalentGradient(TalentLabel: TextLabel, talentName: string?)
	if not TalentLabel then
		return
	end

	local Gradient = TalentLabel:FindFirstChildOfClass("UIGradient")

	if not talentName or talentName == "" or talentName == "No Talent" then
		TalentLabel.Text = "No Talent"
		if Gradient then
			Gradient.Color = TalentColors.None
			Gradient.Rotation = 0
		end
		return
	end

	TalentLabel.Text = talentName

	if not Gradient then
		return
	end

	local TalentInfo = Talents[talentName]
	local Rarity = TalentInfo and TalentInfo.Rarity or "Common"

	Gradient.Color = TalentColors[Rarity] or TalentColors.None
	Gradient.Rotation = (Rarity == "Ascendant" or Rarity == "Secret") and -90 or 0
end

local function UpdateEquippedFrame()
	local EquippedUUID = UIConstants.Data.EquippedPet()
	local VanityUUID = UIConstants.Data.VanityPet()

	local Viewpet = EquippedFrame:FindFirstChild("Viewpet") :: ViewportFrame?
	local PetNameLabel = EquippedFrame:FindFirstChild("PetName") :: TextLabel?
	local UnequipB = EquippedFrame:FindFirstChild("UnequipB") :: TextButton?

	if not EquippedUUID or EquippedUUID == "" then
		EquippedFrame.Visible = false
		if PetNameLabel then
			PetNameLabel.Text = "No pet equipped"
		end
	else
		EquippedFrame.Visible = true

		local PetEntry = UIConstants.Data.Pets[EquippedUUID]()
		if PetEntry then
			if PetNameLabel then
				PetNameLabel.Text = PetEntry.Name
			end

			if Viewpet then
				SetViewportModel(Viewpet, PetEntry.Name)

				local Boost = Viewpet:FindFirstChild("Boost") :: TextLabel?
				if Boost then
					local DamagePercent = math.min(PetEntry.Level, PetsData.MaxLevel) / 2.857142857142857
					Boost.Text = "Boost: " .. string.format("%.1f", DamagePercent) .. "%"
				end
			end

			if UnequipB then
				UnequipB.Visible = true
			end
		end
	end

	local VanityViewport = EquippedFrame:FindFirstChild("VanityPet") :: ViewportFrame?
	if not VanityViewport then
		return
	end

	local VanityUnequipB = VanityViewport:FindFirstChild("UnequipB") :: TextButton?

	if VanityUUID and VanityUUID ~= "" then
		local VanityEntry = UIConstants.Data.Pets[VanityUUID]()
		if VanityEntry then
			SetViewportModel(VanityViewport, VanityEntry.Name)
			if VanityUnequipB then
				VanityUnequipB.Visible = true
			end
			return
		end
	end

	SetViewportModel(VanityViewport, "")
	if VanityUnequipB then
		VanityUnequipB.Visible = false
	end
end

local function UpdateEntryStats(Entry: GuiObject, UUID: string, PetEntry: Types.PetData)
	local RarityType = Entry:FindFirstChild("RarityType") :: TextLabel?
	local PetType = Entry:FindFirstChild("PetType") :: TextLabel?
	local TalentLabel = Entry:FindFirstChild("Talent") :: TextLabel?
	local Viewpet = Entry:FindFirstChild("Viewpet") :: ViewportFrame?
	local PetLevel = Viewpet and (Viewpet:FindFirstChild("PetLevel") :: TextLabel?)
	local Lock = Entry:FindFirstChild("Lock") :: ImageButton?

	if RarityType then
		RarityType.Text = PetEntry.Rarity
		RarityType.TextColor3 = UIFunctions.RarityColors[PetEntry.Rarity] or Color3.fromRGB(255, 255, 255)
	end

	local EquippedUUID = UIConstants.Data.EquippedPet()
	local VanityUUID = UIConstants.Data.VanityPet()

	if PetType then
		PetType.Text = PetEntry.Name
		PetType.TextColor3 = (UUID == EquippedUUID) and EQUIPPED_NAME_COLOR or DEFAULT_NAME_COLOR
	end

	if TalentLabel then
		ApplyTalentGradient(TalentLabel, PetEntry.Talent)
	end

	if PetLevel then
		PetLevel.Text = "Lv: " .. tostring(PetEntry.Level)
	end

	if Viewpet then
		local FusionLabel = Viewpet:FindFirstChild("Fusion") :: TextLabel?
		if FusionLabel then
			FusionLabel.Visible = SelectedCatalyst == UUID
		end
	end

	if Lock then
		Lock.ImageTransparency = PetEntry.Locked and 0 or 0.6
	end

	Entry.BackgroundTransparency = (UUID == EquippedUUID or UUID == VanityUUID) and 0.2 or 0.5
	Entry.LayoutOrder = RarityLayoutOrder[PetEntry.Rarity] or 5

	if UUID == EquippedUUID then
		Entry.LayoutOrder = -1
	end
end

local function CreateInventoryEntryImmediate(UUID: string, PetEntry: Types.PetData)
	if InventoryEntries[UUID] or not InventoryTemplate then
		return
	end

	local Entry = InventoryTemplate:Clone()
	Entry.Name = UUID
	Entry.Visible = true
	Entry.Parent = InventoryList

	local Viewpet = Entry:FindFirstChild("Viewpet") :: ViewportFrame?
	if Viewpet then
		SetViewportModel(Viewpet, PetEntry.Name)
	end

	UpdateEntryStats(Entry, UUID, PetEntry)

	Entry.MouseButton1Click:Connect(function()
		RemoteManager.SendServerEvent("EquipPet", UUID)
	end)

	local Vanity = Entry:FindFirstChild("Viewpet") and Entry.Viewpet:FindFirstChild("Vanity") :: TextButton?
	if Vanity then
		Vanity.MouseButton1Click:Connect(function()
			RemoteManager.SendServerEvent("VanityEquipPet", UUID)
		end)
	end

	local Lock = Entry:FindFirstChild("Lock") :: ImageButton?
	if Lock then
		Lock.MouseButton1Click:Connect(function()
			RemoteManager.SendServerEvent("LockPet", UUID)
		end)
	end

	local Delete = Entry:FindFirstChild("Delete") :: ImageButton?
	if Delete then
		Delete.MouseButton1Click:Connect(function()
			local CurrentEntry = UIConstants.Data.Pets[UUID]()
			if not CurrentEntry then
				return
			end

			if ConfirmRarities[CurrentEntry.Rarity] then
				PendingDelete = UUID
				ConfirmationFrame.Visible = true
			else
				RemoteManager.SendServerEvent("RemovePet", UUID)
			end
		end)
	end

	InventoryEntries[UUID] = Entry
end

local function RemoveInventoryEntry(UUID: string)
	local Entry = InventoryEntries[UUID]
	if Entry then
		Entry:Destroy()
		InventoryEntries[UUID] = nil
	end
end

local function UpdateFusionPreview()
	if not FusionFrame then
		return
	end

	local FuserViewport = FusionFrame.Fuser.Fuser :: ViewportFrame
	local FuserLevel = FusionFrame.Fuser.Level :: TextLabel
	local BarFill = FusionFrame.Bar.Bar :: Frame
	local BarAmount = FusionFrame.Bar.Amount :: TextLabel
	local BarSecond = FusionFrame.Bar.Second :: Frame
	local CatalystViewport = FusionFrame.Catalyst.Catalyst :: ViewportFrame
	local CatalystLevel = FusionFrame.Catalyst.Level :: TextLabel
	local GoldAmountFusion = FusionFrame.Gold.Amount :: TextLabel
	local HelpLabel = FusionFrame.Help :: TextLabel
	local SLabel = FusionFrame.S :: TextLabel
	local HLabel = FusionFrame.H :: TextLabel

	local TargetUUID = UIConstants.Data.EquippedPet()
	if not TargetUUID or TargetUUID == "" then
		HelpLabel.Text = "Equip a pet first"
		SetViewportModel(FuserViewport, "")
		SetViewportModel(CatalystViewport, "")
		return
	end

	local TargetEntry = UIConstants.Data.Pets[TargetUUID]()
	if not TargetEntry then
		return
	end

	SetViewportModel(FuserViewport, TargetEntry.Name)
	FuserLevel.Text = tostring(TargetEntry.Level)

	local XPNeeded = PetsData:GetXPNeeded(TargetEntry.Level)
	local DamagePercent, HealthPercent = PetsData:GetLevelBonuses(TargetEntry.Level)

	if not SelectedCatalyst then
		HelpLabel.Text = "Choose a catalyst pet"
		CatalystLevel.Text = ""
		SetViewportModel(CatalystViewport, "")

		BarAmount.Text = tostring(math.floor(TargetEntry.XP)) .. "/" .. tostring(math.floor(XPNeeded))
		BarFill.Size = UDim2.fromScale(math.clamp(TargetEntry.XP / XPNeeded, 0, 1), 1)
		BarSecond.Size = BarFill.Size

		SLabel.Text = "Bonus Damage: " .. string.format("%.1f", DamagePercent * 100) .. "%"
		HLabel.Text = "Bonus Health: " .. string.format("%.1f", HealthPercent * 100) .. "%"
		SLabel.TextColor3 = DEFAULT_NAME_COLOR
		HLabel.TextColor3 = DEFAULT_NAME_COLOR

		GoldAmountFusion.Text = "0"
		return
	end

	local CatalystEntry = UIConstants.Data.Pets[SelectedCatalyst]()
	if not CatalystEntry then
		SelectedCatalyst = nil
		UpdateFusionPreview()
		return
	end

	SetViewportModel(CatalystViewport, CatalystEntry.Name)
	CatalystLevel.Text = tostring(CatalystEntry.Level)

	local FusionInfo = PetsData.FusionInfo[CatalystEntry.Rarity]
	if not FusionInfo then
		return
	end

	local GoldCost = CatalystEntry.Level * FusionInfo.Cost + FusionInfo.Cost
	GoldAmountFusion.Text = tostring(GoldCost)

	local XPGiven = FusionInfo.Boost + FusionInfo.Boost * CatalystEntry.Level
	local ProjectedXP = TargetEntry.XP + XPGiven
	local WillLevelUp = ProjectedXP >= XPNeeded

	HelpLabel.Text = "Would you like to fuse these pets?"
	BarAmount.Text = tostring(math.floor(TargetEntry.XP))
		.. "/"
		.. tostring(math.floor(XPNeeded))
		.. " +"
		.. tostring(math.floor(XPGiven))

	BarFill.Size = UDim2.fromScale(math.clamp(TargetEntry.XP / XPNeeded, 0, 1), 1)
	BarSecond.Size = UDim2.fromScale(math.clamp(ProjectedXP / XPNeeded, 0, 1), 1)

	if WillLevelUp then
		local NewLevel = TargetEntry.Level + 1
		local NewDamage, NewHealth = PetsData:GetLevelBonuses(NewLevel)

		FuserLevel.Text = tostring(TargetEntry.Level) .. " +1"
		SLabel.Text = "Bonus Damage: " .. string.format("%.1f", NewDamage * 100) .. "%"
		HLabel.Text = "Bonus Health: " .. string.format("%.1f", NewHealth * 100) .. "%"
		SLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
		HLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	else
		SLabel.Text = "Bonus Damage: " .. string.format("%.1f", DamagePercent * 100) .. "%"
		HLabel.Text = "Bonus Health: " .. string.format("%.1f", HealthPercent * 100) .. "%"
		SLabel.TextColor3 = DEFAULT_NAME_COLOR
		HLabel.TextColor3 = DEFAULT_NAME_COLOR
	end
end

local function SelectCatalyst(UUID: string?)
	if SelectedCatalyst and FusionEntries[SelectedCatalyst] then
		FusionEntries[SelectedCatalyst].Visible = true
	end

	SelectedCatalyst = UUID

	if UUID and FusionEntries[UUID] then
		FusionEntries[UUID].Visible = false
	end

	UpdateFusionPreview()
end

local function CreateFusionEntryImmediate(UUID: string, PetEntry: Types.PetData)
	if FusionEntries[UUID] or not FusionTemplate then
		return
	end

	if UUID == UIConstants.Data.EquippedPet() then
		return
	end

	local Entry = FusionTemplate:Clone()
	Entry.Name = UUID
	Entry.Visible = true
	Entry.Parent = FusionPetsFrame

	local Viewport = Entry:FindFirstChild("ViewportFrame") :: ViewportFrame?
	local Level = Entry:FindFirstChild("Level") :: TextLabel?
	local PetName = Entry:FindFirstChild("PetName") :: TextLabel?
	local Locked = Entry:FindFirstChild("Locked") :: ImageLabel?
	local Select = Entry:FindFirstChild("Select") :: TextButton?

	if Viewport then
		SetViewportModel(Viewport, PetEntry.Name)
	end

	if Level then
		Level.Text = tostring(PetEntry.Level)
	end

	if PetName then
		PetName.Text = PetEntry.Name
	end

	if Locked then
		Locked.Visible = PetEntry.Locked
	end

	if Select then
		Select.MouseButton1Click:Connect(function()
			local CurrentEntry = UIConstants.Data.Pets[UUID]()
			if not CurrentEntry or CurrentEntry.Locked then
				return
			end

			if UUID == UIConstants.Data.VanityPet() then
				return
			end

			if SelectedCatalyst == UUID then
				SelectCatalyst(nil)
			else
				SelectCatalyst(UUID)
			end
		end)
	end

	FusionEntries[UUID] = Entry
end

local function RemoveFusionEntry(UUID: string)
	local Entry = FusionEntries[UUID]
	if Entry then
		Entry:Destroy()
		FusionEntries[UUID] = nil
	end

	if SelectedCatalyst == UUID then
		SelectedCatalyst = nil
		UpdateFusionPreview()
	end
end

local function ProcessCreateQueue()
	if QueueRunning then
		return
	end
	QueueRunning = true

	task.spawn(function()
		while #CreateQueue > 0 do
			for _ = 1, CREATE_BUDGET_PER_FRAME do
				local Item = table.remove(CreateQueue, 1)
				if not Item then
					break
				end

				if Item.Kind == "Inventory" then
					CreateInventoryEntryImmediate(Item.UUID, Item.PetEntry)
				else
					CreateFusionEntryImmediate(Item.UUID, Item.PetEntry)
				end
			end

			task.wait()
		end

		QueueRunning = false
	end)
end

local function QueueInventoryEntry(UUID: string, PetEntry: Types.PetData)
	table.insert(CreateQueue, { Kind = "Inventory", UUID = UUID, PetEntry = PetEntry })
	ProcessCreateQueue()
end

local function QueueFusionEntry(UUID: string, PetEntry: Types.PetData)
	table.insert(CreateQueue, { Kind = "Fusion", UUID = UUID, PetEntry = PetEntry })
	ProcessCreateQueue()
end

local function RefreshFusionList()
	local EquippedUUID = UIConstants.Data.EquippedPet()

	for UUID in FusionEntries do
		if UUID == EquippedUUID then
			RemoveFusionEntry(UUID)
		end
	end

	for UUID, PetEntry in UIConstants.Data.Pets() do
		if UUID == EquippedUUID then
			continue
		end

		if not FusionEntries[UUID] then
			QueueFusionEntry(UUID, PetEntry)
		end
	end
end

local function RefreshAllEntryStats()
	for UUID, Entry in InventoryEntries do
		local PetEntry = UIConstants.Data.Pets[UUID]()
		if PetEntry then
			UpdateEntryStats(Entry, UUID, PetEntry)
		end
	end
end

local function MarkPetsDirty()
	if PetsDirty then
		return
	end
	PetsDirty = true

	task.defer(function()
		PetsDirty = false
		RefreshAllEntryStats()
		UpdateFusionPreview()
	end)
end

local function GetRewardFrameCount(count: number): number?
	if count <= 0 then
		return nil
	elseif count == 1 then
		return 1
	elseif count <= 5 then
		return 5
	elseif count <= 10 then
		return 10
	end
	return nil
end

function PetUI.ShowRewards(results: { { UUID: string, Pet: Types.PetData } })
	local Count = #results
	local FrameCount = GetRewardFrameCount(Count)
	local FrameGroup = FrameCount and RewardFrames[FrameCount]
	if not FrameGroup or not PetObtainedTemplate then
		return
	end

	local MainFrame = FrameGroup:FindFirstChild("Main") :: Frame?
	if not MainFrame then
		return
	end

	for _, child in MainFrame:GetChildren() do
		if child:IsA("Frame") and child ~= MainFrame then
			child:Destroy()
		end
	end

	HideAllPetFrames()
	FrameGroup.Visible = true

	for _, result in results do
		local PetEntry = result.Pet
		if not PetEntry then
			continue
		end

		local Entry = PetObtainedTemplate:Clone()
		Entry.Visible = true
		Entry.Parent = MainFrame

		local PetNameLabel = Entry:FindFirstChild("PetName") :: TextLabel?
		if PetNameLabel then
			PetNameLabel.Text = PetEntry.Name
		end

		local Viewport = Entry:FindFirstChild("ViewportFrame") :: ViewportFrame?
		if Viewport then
			SetViewportModel(Viewport, PetEntry.Name)
		end

		local TalentLabel = Entry:FindFirstChild("Talent") :: TextLabel?
		if TalentLabel then
			ApplyTalentGradient(TalentLabel, PetEntry.Talent)
		end
	end

	local Confirm = FrameGroup:FindFirstChild("Confirm") :: TextButton?
	if Confirm then
		local Connection: RBXScriptConnection
		Connection = Confirm.MouseButton1Click:Connect(function()
			FrameGroup.Visible = false
			ShowFrame(Boxes)
			Connection:Disconnect()
		end)
	end
end

local function SetupBoxTile(BoxFrame: Frame, rarity: string)
	local Purchase = BoxFrame:FindFirstChild("Purchase") :: TextButton?
	if not Purchase then
		return
	end

	for _, amountName in { "1", "5", "10" } do
		local AmountButton = Purchase:FindFirstChild(amountName) :: TextButton?
		if not AmountButton then
			continue
		end

		AmountButton.MouseButton1Click:Connect(function()
			if BuyLocked then
				return
			end
			BuyLocked = true

			local Amount = tonumber(amountName) or 1
			local Success, _, Results = RemoteManager.InvokeServerFunction("BuyPetBox", rarity, Amount)

			if Success then
				PetUI.ShowRewards(Results)
			end

			BuyLocked = false
		end)
	end
end

local function SetupFusionUI()
	FusionPetsFrame = Fusion.Inside:WaitForChild("Pets") :: ScrollingFrame
	FusionFrame = Fusion.Inside:WaitForChild("FusionFrame") :: Frame
	FusionTemplate = Templates:WaitForChild("PetFusion") :: GuiObject
	FusionTemplate.Visible = false

	local FusionCatalystSelect = FusionFrame.Catalyst:FindFirstChild("Select") :: TextButton?
	if FusionCatalystSelect then
		FusionCatalystSelect.MouseButton1Click:Connect(function()
			SelectCatalyst(nil)
		end)
	end

	FusionFrame.FuseB.MouseButton1Click:Connect(function()
		local TargetUUID = UIConstants.Data.EquippedPet()
		if not TargetUUID or TargetUUID == "" or not SelectedCatalyst then
			return
		end

		local Success = RemoteManager.InvokeServerFunction("FusePet", TargetUUID, SelectedCatalyst)
		if Success then
			SelectedCatalyst = nil
			UpdateFusionPreview()
		end
	end)

	Fusion.Back.MouseButton1Click:Connect(function()
		SelectCatalyst(nil)
		ShowFrame(PetInventory)
	end)

	local FuseAll = Fusion.Inside:FindFirstChild("FuseAll") :: TextButton?
	if FuseAll then
		FuseAll.MouseButton1Click:Connect(function()
			local TargetUUID = UIConstants.Data.EquippedPet()
			if TargetUUID and TargetUUID ~= "" then
				RemoteManager.InvokeServerFunction("FusePet", TargetUUID, "All")
			end
		end)
	end

	for UUID, PetEntry in UIConstants.Data.Pets() do
		QueueFusionEntry(UUID, PetEntry)
	end
end

function PetUI.Init()
	PetGui = UIConstants.PlayerGui:WaitForChild("PetUI") :: ScreenGui

	BuyOrSee = PetGui:WaitForChild("BuyOrSee") :: Frame
	Boxes = PetGui:WaitForChild("Boxes") :: Frame
	PetInventory = PetGui:WaitForChild("PetInventory") :: Frame
	Fusion = PetGui:WaitForChild("Fusion") :: Frame

	RewardFrames[1] = PetGui:WaitForChild("1") :: Frame
	RewardFrames[5] = PetGui:WaitForChild("5") :: Frame
	RewardFrames[10] = PetGui:WaitForChild("10") :: Frame

	PetObtainedTemplate = Templates:WaitForChild("PetObtained") :: GuiObject
	PetObtainedTemplate.Visible = false

	HideAllPetFrames()

	GoldAmountLabel = Boxes:FindFirstChild("GoldAmount") :: TextLabel?
	UpdateGoldAmount()

	UIConstants.Data.Currencies.Gold.Changed(function()
		UpdateGoldAmount()
	end)

	BuyOrSee.Buy.Buy.MouseButton1Click:Connect(function()
		ShowFrame(Boxes)
	end)

	BuyOrSee.View.View.MouseButton1Click:Connect(function()
		ShowFrame(PetInventory)
	end)

	Boxes.Back.MouseButton1Click:Connect(function()
		ShowFrame(BuyOrSee)
	end)

	for _, rarity in BoxRarities do
		local BoxFrame = Boxes:FindFirstChild(rarity) :: Frame?
		if BoxFrame then
			SetupBoxTile(BoxFrame, rarity)
		end
	end

	InventoryList = PetInventory.Inside:WaitForChild("List") :: ScrollingFrame
	InventoryTemplate = Templates:WaitForChild("EquipPet") :: GuiObject
	InventoryTemplate.Visible = false

	EquippedFrame = PetInventory.Inside:WaitForChild("EquippedFrame") :: Frame

	local VanityViewport = EquippedFrame:FindFirstChild("VanityPet") :: ViewportFrame?
	if VanityViewport then
		VanityNameLabel = VanityViewport:FindFirstChild("PetName") :: TextLabel?
		if VanityNameLabel then
			VanityNameLabel.Text = "APPEARANCE"
		end
	end

	ConfirmationFrame = PetInventory:WaitForChild("Confirmation") :: Frame
	ConfirmationFrame.Visible = false

	ConfirmationFrame.Yay.MouseButton1Click:Connect(function()
		if PendingDelete then
			RemoteManager.SendServerEvent("RemovePet", PendingDelete)
		end
		PendingDelete = nil
		ConfirmationFrame.Visible = false
	end)

	ConfirmationFrame.Nay.MouseButton1Click:Connect(function()
		PendingDelete = nil
		ConfirmationFrame.Visible = false
	end)

	PetInventory.Back.MouseButton1Click:Connect(function()
		ShowFrame(BuyOrSee)
	end)

	PetInventory.Clear.MouseButton1Click:Connect(function()
		RemoteManager.SendServerEvent("ClearPets")
	end)

	local EquippedUnequipB = EquippedFrame:FindFirstChild("UnequipB") :: TextButton?
	if EquippedUnequipB then
		EquippedUnequipB.MouseButton1Click:Connect(function()
			RemoteManager.SendServerEvent("UnequipPet")
		end)
	end

	local FuseB = EquippedFrame.Viewpet:FindFirstChild("FuseB") :: TextButton?
	if FuseB then
		FuseB.MouseButton1Click:Connect(function()
			ShowFrame(Fusion)
			SelectCatalyst(nil)
			UpdateFusionPreview()
		end)
	end

	if VanityViewport then
		local VanityUnequipB = VanityViewport:FindFirstChild("UnequipB") :: TextButton?
		if VanityUnequipB then
			VanityUnequipB.MouseButton1Click:Connect(function()
				RemoteManager.SendServerEvent("VanityUnequipPet")
			end)
		end
	end

	for UUID, PetEntry in UIConstants.Data.Pets() do
		QueueInventoryEntry(UUID, PetEntry)
	end

	UIConstants.Data.Pets.OnKeyAdded(function(UUID: string, PetEntry: Types.PetData)
		QueueInventoryEntry(UUID, PetEntry)
		UpdateInventoryAmount()
		if UUID ~= UIConstants.Data.EquippedPet() then
			QueueFusionEntry(UUID, PetEntry)
		end
	end)

	UIConstants.Data.Pets.OnKeyRemoved(function(UUID: string)
		RemoveInventoryEntry(UUID)
		RemoveFusionEntry(UUID)
		UpdateInventoryAmount()
	end)

	UIConstants.Data.EquippedPet.Changed(function()
		UpdateEquippedFrame()
		UpdateFusionPreview()
		RefreshFusionList()
		RefreshAllEntryStats()
	end)

	UIConstants.Data.VanityPet.Changed(function()
		UpdateEquippedFrame()
		RefreshAllEntryStats()
	end)

	UIConstants.Data.Pets.Changed(MarkPetsDirty)

	SetupFusionUI()

	UpdateEquippedFrame()
	UpdateInventoryAmount()
end

return PetUI
