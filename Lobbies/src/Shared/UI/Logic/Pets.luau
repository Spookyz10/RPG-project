local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local PetUI = {}

local Templates = ReplicatedStorage.Resources.UI.Templates

local PetGui: ScreenGui = nil

local BuyOrSee: Frame = nil
local Boxes: Frame = nil
local PetInventory: Frame = nil
local Fusion: Frame = nil

local InventoryList: ScrollingFrame = nil
local InventoryTemplate: GuiObject = nil
local InventoryEntries: { [string]: GuiObject } = {}

local EquippedFrame: Frame = nil

local ConfirmationFrame: Frame = nil
local PendingDelete: string? = nil

local FusionPetsFrame: ScrollingFrame = nil
local FusionTemplate: GuiObject = nil
local FusionEntries: { [string]: GuiObject } = {}
local SelectedCatalyst: string? = nil

local RewardFrames: { [number]: Frame } = {}

local BoxRarities = { "Common", "Uncommon", "Rare" }
local SelectedAmount: { [string]: number } = { Common = 1, Uncommon = 1, Rare = 1 }

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
		Amount.Text = GetPetCount() .. "/" .. tostring(50)
	end

	local ViewAmount = BuyOrSee.View:FindFirstChild("Amount") :: TextLabel?
	if ViewAmount then
		ViewAmount.Text = GetPetCount() .. "/" .. tostring(50)
	end
end

local function SetViewportModel(Viewport: ViewportFrame, petName: string)
	for _, child in Viewport:GetChildren() do
		if child:IsA("Model") or child:IsA("BasePart") then
			child:Destroy()
		end
	end

	local Template = ReplicatedStorage.Resources.Pets:FindFirstChild(petName)
	if not Template then
		return
	end

	local Clone = Template:Clone()
	Clone.Parent = Viewport

	local Camera = Viewport:FindFirstChildOfClass("Camera")
	if not Camera then
		Camera = Instance.new("Camera")
		Camera.Parent = Viewport
	end
	Viewport.CurrentCamera = Camera

	local CFrameTarget = (Clone :: any).PrimaryPart or Clone:FindFirstChildWhichIsA("BasePart")
	if CFrameTarget then
		Camera.CFrame = CFrame.new(CFrameTarget.Position + Vector3.new(0, 0, 5), CFrameTarget.Position)
	end
end

local function UpdateEquippedFrame()
	local EquippedUUID = UIConstants.Data.EquippedPet()
	local VanityUUID = UIConstants.Data.VanityPet()

	local Viewpet = EquippedFrame:FindFirstChild("Viewpet") :: ViewportFrame?
	local PetNameLabel = EquippedFrame:FindFirstChild("PetName") :: TextLabel?
	local UnequipB = EquippedFrame:FindFirstChild("UnequipB") :: TextButton?

	if not EquippedUUID or EquippedUUID == "" then
		if PetNameLabel then
			PetNameLabel.Text = "No pet equipped"
		end
		return
	end

	local PetEntry = UIConstants.Data.Pets[EquippedUUID]()
	if not PetEntry then
		return
	end

	if PetNameLabel then
		PetNameLabel.Text = PetEntry.Name .. " (Lv" .. tostring(PetEntry.Level) .. ")"
	end

	if Viewpet then
		SetViewportModel(Viewpet, PetEntry.Name)

		local Boost = Viewpet:FindFirstChild("Boost") :: TextLabel?
		if Boost then
			local DamagePercent = math.min(PetEntry.Level, 150) / 2.857142857142857
			Boost.Text = "Boost: " .. string.format("%.1f", DamagePercent) .. "%"
		end
	end

	if UnequipB then
		UnequipB.Visible = true
	end

	local VanityViewport = EquippedFrame:FindFirstChild("VanityPet") :: ViewportFrame?
	if VanityViewport then
		local VanityUnequipB = VanityViewport:FindFirstChild("UnequipB") :: TextButton?
		local VanityNameLabel = VanityViewport:FindFirstChild("PetName") :: TextLabel?

		if VanityUUID and VanityUUID ~= "" then
			local VanityEntry = UIConstants.Data.Pets[VanityUUID]()
			if VanityEntry then
				SetViewportModel(VanityViewport, VanityEntry.Name)
				if VanityNameLabel then
					VanityNameLabel.Text = VanityEntry.Name
				end
				if VanityUnequipB then
					VanityUnequipB.Visible = true
				end
			end
		else
			if VanityNameLabel then
				VanityNameLabel.Text = "APPEARANCE"
			end
			if VanityUnequipB then
				VanityUnequipB.Visible = false
			end
		end
	end
end

local function UpdateEntry(Entry: GuiObject, UUID: string, PetEntry: Types.PetData)
	local RarityType = Entry:FindFirstChild("RarityType") :: TextLabel?
	local PetType = Entry:FindFirstChild("PetType") :: TextLabel?
	local TalentLabel = Entry:FindFirstChild("Talent") :: TextLabel?
	local Line1 = Entry:FindFirstChild("Line1") :: TextLabel?
	local Line2 = Entry:FindFirstChild("Line2") :: TextLabel?
	local Viewpet = Entry:FindFirstChild("Viewpet") :: ViewportFrame?
	local Lock = Entry:FindFirstChild("Lock") :: ImageButton?

	if RarityType then
		RarityType.Text = PetEntry.Rarity
		RarityType.TextColor3 = UIFunctions.RarityColors[PetEntry.Rarity] or Color3.fromRGB(255, 255, 255)
	end

	if PetType then
		PetType.Text = PetEntry.Name
	end

	if TalentLabel then
		TalentLabel.Text = PetEntry.Talent
	end

	if Line1 then
		Line1.Text = "Lv: " .. tostring(PetEntry.Level)
	end

	if Line2 then
		Line2.Text = "XP: " .. tostring(math.floor(PetEntry.XP))
	end

	if Viewpet then
		SetViewportModel(Viewpet, PetEntry.Name)

		local Fusion = Viewpet:FindFirstChild("Fusion") :: TextLabel?
		if Fusion then
			Fusion.Visible = SelectedCatalyst == UUID
		end
	end

	if Lock then
		Lock.ImageTransparency = PetEntry.Locked and 0 or 0.6
	end

	local EquippedUUID = UIConstants.Data.EquippedPet()
	local VanityUUID = UIConstants.Data.VanityPet()
	Entry.BackgroundTransparency = (UUID == EquippedUUID or UUID == VanityUUID) and 0.2 or 0.5
end

local function CreateInventoryEntry(UUID: string, PetEntry: Types.PetData)
	if InventoryEntries[UUID] or not InventoryTemplate then
		return
	end

	local Entry = InventoryTemplate:Clone()
	Entry.Name = UUID
	Entry.Visible = true
	Entry.Parent = InventoryList

	UpdateEntry(Entry, UUID, PetEntry)

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
			PendingDelete = UUID
			ConfirmationFrame.Visible = true
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

local function CreateFusionEntry(UUID: string, PetEntry: Types.PetData)
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
			if PetEntry.Locked or UUID == UIConstants.Data.VanityPet() then
				return
			end

			SelectedCatalyst = UUID
			local TargetUUID = UIConstants.Data.EquippedPet()
			if TargetUUID and TargetUUID ~= "" then
				local Success, Message = RemoteManager.InvokeServerFunction("FusePet", TargetUUID, UUID)
				if Success then
					SelectedCatalyst = nil
				end
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
end

local function SetupBoxTile(BoxFrame: Frame, rarity: string)
	local Purchase = BoxFrame:FindFirstChild("Purchase") :: TextButton?
	if not Purchase then
		return
	end

	for _, amountName in { "1", "5", "10" } do
		local AmountButton = Purchase:FindFirstChild(amountName) :: TextButton?
		if AmountButton then
			AmountButton.MouseButton1Click:Connect(function()
				SelectedAmount[rarity] = tonumber(amountName) or 1
			end)
		end
	end

	Purchase.MouseButton1Click:Connect(function()
		local Amount = SelectedAmount[rarity] or 1
		local Success, Message, Results = RemoteManager.InvokeServerFunction("BuyPetBox", rarity, Amount)

		if not Success then
			return
		end

		PetUI.ShowRewards(Results)
	end)
end

function PetUI.ShowRewards(uuids: { string })
	local Count = #uuids
	local FrameGroup = RewardFrames[Count]
	if not FrameGroup then
		return
	end

	HideAllPetFrames()
	FrameGroup.Visible = true

	local Slots = FrameGroup.Frame:GetChildren()
	local SlotIndex = 0

	for _, uuid in uuids do
		local PetEntry = UIConstants.Data.Pets[uuid]()
		if not PetEntry then
			continue
		end

		SlotIndex += 1
		local SlotFrame = FrameGroup.Frame:FindFirstChild(tostring(SlotIndex))
		if not SlotFrame then
			continue
		end

		local PetNameLabel = SlotFrame:FindFirstChild("PetName") :: TextLabel?
		if PetNameLabel then
			PetNameLabel.Text = PetEntry.Name
		end

		local Viewport = SlotFrame:FindFirstChild("ViewportFrame") :: ViewportFrame?
		if Viewport then
			SetViewportModel(Viewport, PetEntry.Name)
		end

		local TalentLabel = SlotFrame:FindFirstChild("Line") :: TextLabel?
		if TalentLabel then
			TalentLabel.Text = PetEntry.Talent
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

function PetUI.Init()
	PetGui = UIConstants.PlayerGui:WaitForChild("PetUI") :: ScreenGui

	BuyOrSee = PetGui:WaitForChild("BuyOrSee") :: Frame
	Boxes = PetGui:WaitForChild("Boxes") :: Frame
	PetInventory = PetGui:WaitForChild("PetInventory") :: Frame
	Fusion = PetGui:WaitForChild("Fusion") :: Frame

	RewardFrames[1] = PetGui:WaitForChild("1") :: Frame
	RewardFrames[5] = PetGui:WaitForChild("5") :: Frame
	RewardFrames[10] = PetGui:WaitForChild("10") :: Frame

	HideAllPetFrames()

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
		end)
	end

	local VanityViewport = EquippedFrame:FindFirstChild("VanityPet") :: ViewportFrame?
	if VanityViewport then
		local VanityUnequipB = VanityViewport:FindFirstChild("UnequipB") :: TextButton?
		if VanityUnequipB then
			VanityUnequipB.MouseButton1Click:Connect(function()
				RemoteManager.SendServerEvent("VanityUnequipPet")
			end)
		end
	end

	for UUID, PetEntry in UIConstants.Data.Pets() do
		CreateInventoryEntry(UUID, PetEntry)
	end

	UIConstants.Data.Pets.OnKeyAdded(function(UUID: string, PetEntry: Types.PetData)
		CreateInventoryEntry(UUID, PetEntry)
		UpdateInventoryAmount()
	end)

	UIConstants.Data.Pets.OnKeyRemoved(function(UUID: string)
		RemoveInventoryEntry(UUID)
		RemoveFusionEntry(UUID)
		UpdateInventoryAmount()
	end)

	UIConstants.Data.EquippedPet.Changed(function()
		UpdateEquippedFrame()
		for UUID, Entry in InventoryEntries do
			local PetEntry = UIConstants.Data.Pets[UUID]()
			if PetEntry then
				UpdateEntry(Entry, UUID, PetEntry)
			end
		end
	end)

	UIConstants.Data.VanityPet.Changed(function()
		UpdateEquippedFrame()
		for UUID, Entry in InventoryEntries do
			local PetEntry = UIConstants.Data.Pets[UUID]()
			if PetEntry then
				UpdateEntry(Entry, UUID, PetEntry)
			end
		end
	end)

	UpdateEquippedFrame()
	UpdateInventoryAmount()

	FusionPetsFrame = Fusion.Inside.FusionFrame:WaitForChild("Pets") :: ScrollingFrame
	FusionTemplate = FusionPetsFrame:FindFirstChild("Frame") :: GuiObject
	FusionTemplate.Visible = false

	Fusion.Back.MouseButton1Click:Connect(function()
		SelectedCatalyst = nil
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
		CreateFusionEntry(UUID, PetEntry)
	end

	UIConstants.Data.Pets.OnKeyAdded(function(UUID: string, PetEntry: Types.PetData)
		CreateFusionEntry(UUID, PetEntry)
	end)
end

return PetUI
