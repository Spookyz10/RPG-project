local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Inventory = {}

local Container: ScrollingFrame = nil
local Template: TextButton = nil
local ItemLimit: TextLabel = nil
local EquippedContainer: Instance = nil
local VanitiesContainer: Instance = nil
local SearchBox: TextBox = nil
local ActionFrame: Frame = nil
local GeneralFrame: Frame = nil
local UsableFrame: Frame = nil
local VanityButton: TextButton = nil
local EquippedFrame: Frame = nil
local VanitiesFrame: Frame = nil

local Entries: { [string]: TextButton } = {}
local EntryNames: { [string]: string } = {}

local ActionConnections: { RBXScriptConnection } = {}
local GeneralConnections: { RBXScriptConnection } = {}
local UsableConnections: { RBXScriptConnection } = {}

local StatLabels = { "ATK", "CRT", "SPD", "DEF", "HP" }
local StatKeys = { ATK = "Attack", CRT = "Critical", SPD = "Speed", DEF = "Defense", HP = "Health" }

local EquippedLabelColors: { [string]: Color3 } = {
	Weapon = Color3.fromRGB(255, 255, 255),
	Ring = Color3.fromRGB(38, 219, 255),
	Necklace = Color3.fromRGB(38, 219, 255),
	Armor = Color3.fromRGB(255, 255, 255),
	Aura = Color3.fromRGB(255, 255, 25),
	Rune = Color3.fromRGB(106, 0, 255),
}

local function DisconnectAll(connections: { RBXScriptConnection })
	for _, connection in connections do
		connection:Disconnect()
	end
	table.clear(connections)
end

local function UpdateEntry(Button: TextButton, ItemData: Types.ItemData)
	local ItemInfo = ItemsData[ItemData.Name] :: Types.Item
	if not ItemInfo then
		return
	end

	local Icon = Button:FindFirstChild("Icon") :: ImageLabel?
	local Amount = Button:FindFirstChild("Amount") :: TextLabel?

	if Icon then
		Icon.Image = ItemInfo.Data.Icon
	end

	if Amount then
		Amount.Text = tostring(ItemData.Amount)
	end

	UIFunctions:ApplyRarity(Button, ItemInfo.Data.Rarity)
end

local function UpdateEquippedLabel(UUID: string, Button: TextButton)
	local EquippedLabel = Button:FindFirstChild("EquippedLabel") :: ImageLabel?
	if not EquippedLabel then
		return
	end

	local Equipment = UIConstants.Data.Equipment()

	Button.BorderColor3 = Color3.fromRGB(255, 255, 255)

	for slot, EquippedUUID in Equipment do
		if EquippedUUID == UUID then
			EquippedLabel.Visible = true
			EquippedLabel.ImageColor3 = EquippedLabelColors[slot] or Color3.fromRGB(255, 255, 255)
			Button.BorderSizePixel = 1
			return
		end
	end

	EquippedLabel.Visible = false
	Button.BorderSizePixel = 0
end

local function RefreshAllEquippedLabels()
	for UUID, Button in Entries do
		UpdateEquippedLabel(UUID, Button)
	end
end

local function ApplySearchFilter()
	local Query = string.lower(SearchBox.Text)

	for UUID, Button in Entries do
		if Query == "" then
			Button.Visible = true
		else
			local Name = EntryNames[UUID]
			Button.Visible = Name ~= nil and string.find(string.lower(Name), Query, 1, true) ~= nil
		end
	end
end

local function CloseActionFrame()
	ActionFrame.Visible = false
end

local function CloseGeneralFrame()
	GeneralFrame.Visible = false
end

local function CloseUsableFrame()
	UsableFrame.Visible = false
end

local function OpenActionFrame(UUID: string, ItemData: Types.ItemData, ItemInfo: Types.Equipment)
	DisconnectAll(ActionConnections)

	local Inner = ActionFrame.Inner

	Inner.ItemName.Text = ItemData.Name
	Inner.ItemDamage.Text = "Damage: " .. tostring(ItemInfo.Stats.Attack)
	Inner.ItemLevel.Text = "Level Requirement: " .. tostring(ItemInfo.Data.Level) .. "+"

	local ItemDesc = Inner:FindFirstChild("ItemDesc") :: TextLabel?
	if ItemDesc then
		ItemDesc.Text = ItemInfo.Data.Description or ""
	end

	local MeetsLevel = UIConstants.Data.Level() >= ItemInfo.Data.Level
	Inner.ItemLevel.TextColor3 = MeetsLevel and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

	Inner.Action.Text = "Equip"

	table.insert(
		ActionConnections,
		Inner.Action.MouseButton1Click:Connect(function()
			RemoteManager.SendServerEvent("EquipItem", UUID)
			CloseActionFrame()
		end)
	)

	table.insert(ActionConnections, Inner.Cancel.MouseButton1Click:Connect(CloseActionFrame))

	local VanityBtn = Inner:FindFirstChild("Vanity") :: TextButton?
	if VanityBtn then
		table.insert(
			ActionConnections,
			VanityBtn.MouseButton1Click:Connect(function()
				RemoteManager.SendServerEvent("VanityEquip", UUID)
				CloseActionFrame()
			end)
		)
	end

	ActionFrame.Visible = true
end

local function OpenGeneralFrame(UUID: string, ItemData: Types.ItemData, ItemInfo: Types.Equipment)
	DisconnectAll(GeneralConnections)

	local Inner = GeneralFrame.Inner

	Inner.ItemName.Text = ItemData.Name
	Inner.ItemLevel.Text = "Level Requirement: " .. tostring(ItemInfo.Data.Level) .. "+"

	local MeetsLevel = UIConstants.Data.Level() >= ItemInfo.Data.Level
	Inner.ItemLevel.TextColor3 = MeetsLevel and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

	for _, statLabel in StatLabels do
		local StatValue = ItemInfo.Stats[StatKeys[statLabel]] or 0
		Inner.Stats[statLabel].Text = statLabel .. ": " .. tostring(StatValue)
	end

	local SubType = ItemInfo.Data.SubType
	local EquippedUUID = UIConstants.Data.Equipment()[SubType]
	local IsEquipped = EquippedUUID == UUID

	Inner.Action.Visible = not IsEquipped
	Inner.Unequip.Visible = IsEquipped

	table.insert(
		GeneralConnections,
		Inner.Action.MouseButton1Click:Connect(function()
			RemoteManager.SendServerEvent("EquipItem", UUID)
			CloseGeneralFrame()
		end)
	)

	table.insert(
		GeneralConnections,
		Inner.Unequip.MouseButton1Click:Connect(function()
			RemoteManager.SendServerEvent("UnequipItem", UUID)
			CloseGeneralFrame()
		end)
	)

	table.insert(GeneralConnections, Inner.Cancel.MouseButton1Click:Connect(CloseGeneralFrame))

	GeneralFrame.Visible = true
end

local function OpenUsableFrame(UUID: string, ItemData: Types.ItemData, ItemInfo: Types.Consumable)
	DisconnectAll(UsableConnections)

	local Inner = UsableFrame.Inner

	Inner.ItemName.Text = ItemData.Name
	Inner.ItemLevel.Text = "Level Requirement: " .. tostring(ItemInfo.Data.Level) .. "+"

	local ItemDesc = Inner:FindFirstChild("ItemDesc") :: TextLabel?
	if ItemDesc then
		ItemDesc.Text = ItemInfo.Data.Description or ""
	end

	local MeetsLevel = UIConstants.Data.Level() >= ItemInfo.Data.Level
	Inner.ItemLevel.TextColor3 = MeetsLevel and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

	local UnequipButton = Inner:FindFirstChild("Unequip") :: TextButton?
	if UnequipButton then
		UnequipButton.Visible = false
	end

	table.insert(
		UsableConnections,
		Inner.Action.MouseButton1Click:Connect(function()
			RemoteManager.SendServerEvent("UseItem", UUID, false)
			CloseUsableFrame()
		end)
	)

	local UseAllButton = Inner:FindFirstChild("Use All") :: TextButton?
	if UseAllButton then
		table.insert(
			UsableConnections,
			UseAllButton.MouseButton1Click:Connect(function()
				RemoteManager.SendServerEvent("UseItem", UUID, true)
				CloseUsableFrame()
			end)
		)
	end

	table.insert(UsableConnections, Inner.Cancel.MouseButton1Click:Connect(CloseUsableFrame))

	UsableFrame.Visible = true
end

local function OnItemClicked(UUID: string)
	local ItemData = UIConstants.Data.Inventory[UUID]()
	if not ItemData then
		return
	end

	local ItemInfo = ItemsData[ItemData.Name] :: Types.Item
	if not ItemInfo then
		return
	end

	if ItemInfo.Kind == "Equipment" then
		if ItemInfo.Data.SubType == "Weapon" then
			OpenActionFrame(UUID, ItemData, ItemInfo)
		else
			OpenGeneralFrame(UUID, ItemData, ItemInfo)
		end
	elseif ItemInfo.Kind == "Consumable" then
		OpenUsableFrame(UUID, ItemData, ItemInfo)
	end
end

local function CreateEntry(UUID: string, ItemData: Types.ItemData)
	if Entries[UUID] or not Template then
		return
	end

	local Button = Template:Clone()
	Button.Name = UUID
	Button.Parent = Container

	UpdateEntry(Button, ItemData)

	Button.MouseButton1Click:Connect(function()
		OnItemClicked(UUID)
	end)

	Entries[UUID] = Button
	EntryNames[UUID] = ItemData.Name

	UpdateEquippedLabel(UUID, Button)

	UIConstants.Data.Inventory[UUID].Amount.Changed(function()
		local CurrentData = UIConstants.Data.Inventory[UUID]()
		if CurrentData then
			UpdateEntry(Button, CurrentData)
		end
	end)

	ApplySearchFilter()
end

local function RemoveEntry(UUID: string)
	local Button = Entries[UUID]
	if Button then
		Button:Destroy()
		Entries[UUID] = nil
		EntryNames[UUID] = nil
	end
end

local function UpdateItemLimit()
	if not ItemLimit then
		return
	end

	local Current = UIConstants.Data.CurrentInventorySpace()
	local Max = UIConstants.Data.MaxInventorySpace()

	ItemLimit.Text = Current .. "/" .. Max
end

local function UpdateEquippedSlot(slot: string, UUID: string)
	if not EquippedContainer then
		return
	end

	local SlotFrame = EquippedContainer:FindFirstChild(slot)

	if not SlotFrame then
		return
	end

	local Icon = SlotFrame:FindFirstChild("Icon") :: ImageLabel?
	if not Icon then
		return
	end

	if UUID == "" then
		Icon.Image = ""
		return
	end

	local ItemEntry = UIConstants.Data.Inventory[UUID]()
	if not ItemEntry then
		Icon.Image = ""
		return
	end

	local ItemInfo = ItemsData[ItemEntry.Name] :: Types.Item
	if not ItemInfo then
		Icon.Image = ""
		return
	end

	Icon.Image = ItemInfo.Data.Icon
end

local function SetupEquippedUnequip()
	for slot, _ in UIConstants.Data.Equipment() do
		local SlotFrame = EquippedContainer:FindFirstChild(slot)
		if not SlotFrame then
			continue
		end

		local Icon = SlotFrame:FindFirstChild("Icon") :: ImageLabel?
		local Button = Icon and Icon:FindFirstChild("TextButton") :: TextButton?
		if not Button then
			continue
		end

		Button.MouseButton1Click:Connect(function()
			local EquippedUUID = UIConstants.Data.Equipment()[slot]
			if EquippedUUID and EquippedUUID ~= "" then
				RemoteManager.SendServerEvent("UnequipItem", EquippedUUID)
			end
		end)
	end
end

local function UpdateVanitySlot(slot: string, UUID: string)
	if not VanitiesContainer then
		return
	end

	local SlotFrame = VanitiesContainer:FindFirstChild(slot)
	if not SlotFrame then
		return
	end

	local Icon = SlotFrame:FindFirstChild("Icon") :: ImageLabel?
	if not Icon then
		return
	end

	if UUID == "" then
		Icon.Image = ""
		return
	end

	local ItemEntry = UIConstants.Data.Inventory[UUID]()
	if not ItemEntry then
		Icon.Image = ""
		return
	end

	local ItemInfo = ItemsData[ItemEntry.Name] :: Types.Item
	if not ItemInfo then
		Icon.Image = ""
		return
	end

	Icon.Image = ItemInfo.Data.Icon
end

local function SetupVanityUnequip()
	for slot, _ in UIConstants.Data.Vanity() do
		local SlotFrame = VanitiesContainer:FindFirstChild(slot)
		if not SlotFrame then
			continue
		end

		local Icon = SlotFrame:FindFirstChild("Icon") :: ImageLabel?
		local Button = Icon and Icon:FindFirstChild("TextButton") :: TextButton?
		if not Button then
			continue
		end

		Button.MouseButton1Click:Connect(function()
			local VanityUUID = UIConstants.Data.Vanity()[slot]
			if VanityUUID and VanityUUID ~= "" then
				RemoteManager.SendServerEvent("VanityUnequip", slot)
			end
		end)
	end
end

local function SetupVanityToggle()
	VanityButton.MouseButton1Click:Connect(function()
		EquippedFrame.Visible = not EquippedFrame.Visible
		VanitiesFrame.Visible = not VanitiesFrame.Visible
	end)
end

local function SetupDrinkAll(DrinkButton: TextButton)
	DrinkButton.MouseButton1Click:Connect(function()
		RemoteManager.SendServerEvent("DrinkAllPotions")
	end)
end

function Inventory.Init()
	local Main = UIConstants.PlayerGui:WaitForChild("Inventory"):WaitForChild("Main")

	Container = Main:WaitForChild("Container") :: ScrollingFrame
	Template = ReplicatedStorage.Resources.UI.Templates:WaitForChild("InvTemplate") :: TextButton
	ItemLimit = Main:WaitForChild("ItemLimit") :: TextLabel
	EquippedContainer = Main:WaitForChild("Equipped")
	VanitiesContainer = Main:WaitForChild("Vanities")
	SearchBox = Main:WaitForChild("Search") :: TextBox
	ActionFrame = Main:WaitForChild("ActionFrame") :: Frame
	GeneralFrame = Main:WaitForChild("GeneralFrame") :: Frame
	UsableFrame = Main:WaitForChild("UsableFrame") :: Frame
	VanityButton = Main:WaitForChild("Vanity") :: TextButton
	EquippedFrame = EquippedContainer :: Frame
	VanitiesFrame = VanitiesContainer :: Frame

	ActionFrame.Visible = false
	GeneralFrame.Visible = false
	UsableFrame.Visible = false
	VanitiesFrame.Visible = false

	for UUID, ItemData in UIConstants.Data.Inventory() do
		CreateEntry(UUID, ItemData)
	end

	UIConstants.Data.Inventory.OnKeyAdded(function(UUID: string, ItemData: Types.ItemData)
		CreateEntry(UUID, ItemData)
		UpdateItemLimit()
	end)

	UIConstants.Data.Inventory.OnKeyRemoved(function(UUID: string)
		RemoveEntry(UUID)
		UpdateItemLimit()
	end)

	UpdateItemLimit()

	for slot, UUID in UIConstants.Data.Equipment() do
		UpdateEquippedSlot(slot, UUID)
	end

	UIConstants.Data.Equipment.Changed(function(NewEquipment)
		for slot, UUID in NewEquipment do
			UpdateEquippedSlot(slot, UUID)
		end
		RefreshAllEquippedLabels()
	end)

	SetupEquippedUnequip()

	for slot, UUID in UIConstants.Data.Vanity() do
		UpdateVanitySlot(slot, UUID)
	end

	UIConstants.Data.Vanity.Changed(function(NewVanity)
		for slot, UUID in NewVanity do
			UpdateVanitySlot(slot, UUID)
		end
	end)

	SetupVanityUnequip()
	SetupVanityToggle()

	local DrinkButton = Main:WaitForChild("Bottom"):WaitForChild("Advanced"):WaitForChild("Drink") :: TextButton
	SetupDrinkAll(DrinkButton)

	SearchBox:GetPropertyChangedSignal("Text"):Connect(ApplySearchFilter)
end

return Inventory
