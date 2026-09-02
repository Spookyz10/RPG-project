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

local Bank: Frame = nil
local BankContainer: ScrollingFrame = nil
local BankItemLimit: TextLabel = nil
local BankStackMove: TextBox = nil
local MainStackMove: TextBox = nil
local MainStackSell: TextBox = nil
local BottomFrame: Frame = nil
local AdvancedFrame: Frame = nil
local SellFrame: Frame = nil
local StorageFrame: Frame = nil

local Entries: { [string]: TextButton } = {}
local EntryNames: { [string]: string } = {}
local DefaultColors: { [string]: Color3 } = {}
local BankEntries: { [string]: TextButton } = {}

local ActionConnections: { RBXScriptConnection } = {}
local GeneralConnections: { RBXScriptConnection } = {}
local UsableConnections: { RBXScriptConnection } = {}

local StatLabels = { "ATK", "CRT", "SPD", "DEF", "HP" }
local StatKeys = { ATK = "Attack", CRT = "Critical", SPD = "Speed", DEF = "Defense", HP = "Health" }
local PercentStats = { CRT = true }

local SELECTED_COLOR = Color3.fromRGB(171, 0, 0)
local SELL_LIMIT = 25

local SellMode = false
local StorageOpen = false
local SellList: { [string]: number } = {}
local SellTotal = 0

local EquippedLabelColors: { [string]: Color3 } = {
	Weapon = Color3.fromRGB(255, 255, 255),
	Ring = Color3.fromRGB(38, 219, 255),
	Necklace = Color3.fromRGB(38, 219, 255),
	Armor = Color3.fromRGB(255, 255, 255),
	Aura = Color3.fromRGB(255, 255, 25),
	Rune = Color3.fromRGB(106, 0, 255),
	["Pet Gem"] = Color3.fromRGB(0, 255, 170),
	WeaponVanity = Color3.fromRGB(255, 255, 255),
	AuraVanity = Color3.fromRGB(255, 255, 25),
}

local GOLD_COLOR_HEX = "#FFD500"

local SlotOrder: { [string]: number } = {
	Weapon = 1,
	Ring = 2,
	Necklace = 3,
	Armor = 4,
	Aura = 5,
	Rune = 6,
	["Pet Gem"] = 7,
	WeaponVanity = 8,
	AuraVanity = 9,
}

local VanitySlotKeys: { [string]: string } = {
	Weapon = "WeaponVanity",
	Aura = "AuraVanity",
}

local DEFAULT_LAYOUT_ORDER = 100

local function DisconnectAll(connections: { RBXScriptConnection })
	for _, connection in connections do
		connection:Disconnect()
	end
	table.clear(connections)
end

local function UpdateEntry(Button: TextButton, ItemData: Types.ItemData)
	local ItemInfo = ItemsData[ItemData.ID] :: Types.Item
	if not ItemInfo then
		return
	end

	local Icon = Button:FindFirstChild("Icon") :: ImageLabel?
	local Amount = Button:FindFirstChild("Amount") :: TextLabel?

	if Icon then
		Icon.Image = ItemInfo.Data.Icon
	end

	if Amount then
		Amount.Visible = ItemInfo.Data.Stackable == true
		Amount.Text = tostring(ItemData.Amount)
	end

	UIFunctions:ApplyRarity(Button, ItemInfo.Data.Rarity)
end

local function FindEquippedKey(UUID: string): string?
	local Equipment = UIConstants.Data.Equipment()
	for slot, EquippedUUID in Equipment do
		if EquippedUUID == UUID then
			return slot
		end
	end

	local Vanity = UIConstants.Data.Vanity()
	for slot, VanityUUID in Vanity do
		if VanityUUID == UUID then
			return VanitySlotKeys[slot] or slot
		end
	end

	return nil
end

local function UpdateEquippedLabel(UUID: string, Button: TextButton)
	local EquippedLabel = Button:FindFirstChild("EquippedLabel") :: ImageLabel?

	Button.BorderColor3 = Color3.fromRGB(255, 255, 255)

	local Key = FindEquippedKey(UUID)

	if Key then
		if EquippedLabel then
			EquippedLabel.Visible = true
			EquippedLabel.ImageColor3 = EquippedLabelColors[Key] or Color3.fromRGB(255, 255, 255)
		end
		Button.BorderSizePixel = 1
		Button.LayoutOrder = SlotOrder[Key] or DEFAULT_LAYOUT_ORDER
	else
		if EquippedLabel then
			EquippedLabel.Visible = false
		end
		Button.BorderSizePixel = 0
		Button.LayoutOrder = DEFAULT_LAYOUT_ORDER
	end
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

		if PercentStats[statLabel] then
			Inner.Stats[statLabel].Text = statLabel .. ": " .. string.format("%.1f", StatValue) .. "%"
		else
			Inner.Stats[statLabel].Text = statLabel .. ": " .. tostring(StatValue)
		end
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

	local ItemInfo = ItemsData[ItemData.ID] :: Types.Item
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

local function CountSelected(): number
	local Count = 0
	for _ in SellList do
		Count += 1
	end
	return Count
end

local function GetSellValue(ItemInfo: Types.Item, Amount: number): number
	return (ItemInfo.Data.SellsFor or 0) * Amount
end

local function UpdateSellLabel()
	ItemLimit.Text = "Selling: "
		.. CountSelected()
		.. "/"
		.. SELL_LIMIT
		.. '  <font color="'
		.. GOLD_COLOR_HEX
		.. '">Gold: '
		.. SellTotal
		.. "</font>"
end
local function OpenStackSell(UUID: string, Button: TextButton, ItemData: Types.ItemData, ItemInfo: Types.Item)
	MainStackSell.Visible = true
	MainStackSell.Text = tostring(ItemData.Amount)

	local Connection: RBXScriptConnection
	Connection = MainStackSell.TextButton.MouseButton1Click:Connect(function()
		local Wanted = tonumber(MainStackSell.Text)
		if Wanted and Wanted >= 1 and Wanted <= ItemData.Amount then
			SellList[UUID] = math.floor(Wanted)
			SellTotal += GetSellValue(ItemInfo, SellList[UUID])
			Button.BackgroundColor3 = SELECTED_COLOR
			UpdateSellLabel()
		end

		MainStackSell.Visible = false
		Connection:Disconnect()
	end)
end

local function ToggleSellSelection(UUID: string, Button: TextButton, ItemData: Types.ItemData, ItemInfo: Types.Item)
	if FindEquippedKey(UUID) then
		return
	end

	if SellList[UUID] then
		SellTotal -= GetSellValue(ItemInfo, SellList[UUID])
		SellList[UUID] = nil
		Button.BackgroundColor3 = DefaultColors[UUID] or Button.BackgroundColor3
		UpdateSellLabel()
		return
	end

	if CountSelected() >= SELL_LIMIT then
		return
	end

	if ItemInfo.Data.Stackable and ItemData.Amount > 1 then
		OpenStackSell(UUID, Button, ItemData, ItemInfo)
		return
	end

	SellList[UUID] = ItemData.Amount
	SellTotal += GetSellValue(ItemInfo, ItemData.Amount)
	Button.BackgroundColor3 = SELECTED_COLOR
	UpdateSellLabel()
end

local function UpdateItemLimit()
	if not ItemLimit or SellMode then
		return
	end

	local Current = UIConstants.Data.CurrentInventorySpace()
	local Max = UIConstants.Data.MaxInventorySpace()

	ItemLimit.Text = Current .. "/" .. Max
end

local function ExitSellMode()
	SellMode = false

	for UUID, Button in Entries do
		Button.BackgroundColor3 = DefaultColors[UUID] or Button.BackgroundColor3
	end

	SellList = {}
	SellTotal = 0

	SellFrame.Sell.Visible = true
	SellFrame.Cancel.Visible = false
	AdvancedFrame.Confirm.Visible = false
	AdvancedFrame.Drink.Visible = true
	SearchBox.Visible = true

	UpdateItemLimit()
end

local function EnterSellMode()
	if StorageOpen then
		return
	end

	SellMode = true
	SellList = {}
	SellTotal = 0

	SellFrame.Sell.Visible = false
	SellFrame.Cancel.Visible = true
	AdvancedFrame.Confirm.Visible = true
	AdvancedFrame.Drink.Visible = false
	SearchBox.Visible = false

	UpdateSellLabel()
end

local function ConfirmSell()
	if next(SellList) then
		RemoteManager.SendServerEvent("SellItem", SellList)
	end

	ExitSellMode()
end

local function RequestDeposit(UUID: string, ItemData: Types.ItemData, ItemInfo: Types.Item)
	if ItemInfo.Data.Stackable and ItemData.Amount > 1 then
		MainStackMove.Visible = true
		MainStackMove.Text = tostring(ItemData.Amount)

		local Connection: RBXScriptConnection
		Connection = MainStackMove.TextButton.MouseButton1Click:Connect(function()
			local Wanted = tonumber(MainStackMove.Text)
			if Wanted and Wanted >= 1 and Wanted <= ItemData.Amount then
				RemoteManager.SendServerEvent("StorageDeposit", UUID, math.floor(Wanted))
			end

			MainStackMove.Visible = false
			Connection:Disconnect()
		end)
		return
	end

	RemoteManager.SendServerEvent("StorageDeposit", UUID, 1)
end

local function RequestWithdraw(UUID: string, ItemData: Types.ItemData, ItemInfo: Types.Item)
	if ItemInfo.Data.Stackable and ItemData.Amount > 1 then
		BankStackMove.Visible = true
		BankStackMove.Text = tostring(ItemData.Amount)

		local Connection: RBXScriptConnection
		Connection = BankStackMove.TextButton.MouseButton1Click:Connect(function()
			local Wanted = tonumber(BankStackMove.Text)
			if Wanted and Wanted >= 1 and Wanted <= ItemData.Amount then
				RemoteManager.SendServerEvent("StorageWithdraw", UUID, math.floor(Wanted))
			end

			BankStackMove.Visible = false
			Connection:Disconnect()
		end)
		return
	end

	RemoteManager.SendServerEvent("StorageWithdraw", UUID, 1)
end

local function CloseStorage()
	StorageOpen = false
	Bank.Visible = false
	StorageFrame.Storage.Visible = true
	StorageFrame.Cancel.Visible = false
end

local function OpenStorage()
	if SellMode then
		return
	end

	StorageOpen = true
	Bank.Visible = true
	StorageFrame.Storage.Visible = false
	StorageFrame.Cancel.Visible = true
end

local function HandleEntryClick(UUID: string)
	local ItemData = UIConstants.Data.Inventory[UUID]()
	if not ItemData then
		return
	end

	local ItemInfo = ItemsData[ItemData.ID] :: Types.Item
	if not ItemInfo then
		return
	end

	if SellMode then
		ToggleSellSelection(UUID, Entries[UUID], ItemData, ItemInfo)
		return
	end

	if StorageOpen then
		if ItemData.Equipped then
			return
		end
		RequestDeposit(UUID, ItemData, ItemInfo)
		return
	end

	OnItemClicked(UUID)
end

local function CreateEntry(UUID: string, ItemData: Types.ItemData)
	if Entries[UUID] or not Template then
		return
	end

	local Button = Template:Clone()
	Button.Name = UUID
	Button.LayoutOrder = DEFAULT_LAYOUT_ORDER
	Button.Parent = Container

	UpdateEntry(Button, ItemData)

	DefaultColors[UUID] = Button.BackgroundColor3

	Button.MouseButton1Click:Connect(function()
		HandleEntryClick(UUID)
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
		DefaultColors[UUID] = nil
	end

	if SellList[UUID] then
		SellTotal -= 0
		SellList[UUID] = nil
		if SellMode then
			UpdateSellLabel()
		end
	end
end

local function CreateBankEntry(UUID: string, ItemData: Types.ItemData)
	if BankEntries[UUID] or not Template then
		return
	end

	local Button = Template:Clone()
	Button.Name = UUID
	Button.LayoutOrder = DEFAULT_LAYOUT_ORDER
	Button.Parent = BankContainer

	UpdateEntry(Button, ItemData)

	Button.MouseButton1Click:Connect(function()
		local CurrentData = UIConstants.Data.Storage[UUID]()
		if not CurrentData then
			return
		end

		local ItemInfo = ItemsData[CurrentData.ID] :: Types.Item
		if not ItemInfo then
			return
		end

		RequestWithdraw(UUID, CurrentData, ItemInfo)
	end)

	BankEntries[UUID] = Button

	UIConstants.Data.Storage[UUID].Amount.Changed(function()
		local CurrentData = UIConstants.Data.Storage[UUID]()
		if CurrentData then
			UpdateEntry(Button, CurrentData)
		end
	end)
end

local function RemoveBankEntry(UUID: string)
	local Button = BankEntries[UUID]
	if Button then
		Button:Destroy()
		BankEntries[UUID] = nil
	end
end

local function UpdateBankLimit()
	if not BankItemLimit then
		return
	end

	local Current = UIConstants.Data.CurrentStorageSpace()
	local Max = UIConstants.Data.MaxStorageSpace()

	BankItemLimit.Text = Current .. "/" .. Max
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

	local ItemInfo = ItemsData[ItemEntry.ID] :: Types.Item
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

	local ItemInfo = ItemsData[ItemEntry.ID] :: Types.Item
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

	Bank = Main:WaitForChild("Bank") :: Frame
	BankContainer = Bank:WaitForChild("ScrollingFrame") :: ScrollingFrame
	BankItemLimit = Bank:WaitForChild("ItemLimit") :: TextLabel
	BankStackMove = Bank:WaitForChild("StackMove") :: TextBox

	MainStackMove = Main:WaitForChild("StackMove") :: TextBox
	MainStackSell = Main:WaitForChild("StackSell") :: TextBox

	BottomFrame = Main:WaitForChild("Bottom") :: Frame
	AdvancedFrame = BottomFrame:WaitForChild("Advanced") :: Frame
	SellFrame = BottomFrame:WaitForChild("Sell") :: Frame
	StorageFrame = BottomFrame:WaitForChild("Storage") :: Frame

	ActionFrame.Visible = false
	GeneralFrame.Visible = false
	UsableFrame.Visible = false
	VanitiesFrame.Visible = false
	Bank.Visible = false
	MainStackMove.Visible = false
	MainStackSell.Visible = false
	BankStackMove.Visible = false

	SellFrame.Cancel.Visible = false
	AdvancedFrame.Confirm.Visible = false
	StorageFrame.Cancel.Visible = false

	local GridLayout = Container:FindFirstChildOfClass("UIGridLayout")
	if GridLayout then
		GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	end

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

	UIConstants.Data.CurrentInventorySpace.Changed(function()
		UpdateItemLimit()
	end)

	UIConstants.Data.MaxInventorySpace.Changed(function()
		UpdateItemLimit()
	end)

	UIConstants.Data.CurrentStorageSpace.Changed(function()
		UpdateBankLimit()
	end)

	UIConstants.Data.MaxStorageSpace.Changed(function()
		UpdateBankLimit()
	end)

	UpdateItemLimit()

	for UUID, ItemData in UIConstants.Data.Storage() do
		CreateBankEntry(UUID, ItemData)
	end

	UIConstants.Data.Storage.OnKeyAdded(function(UUID: string, ItemData: Types.ItemData)
		CreateBankEntry(UUID, ItemData)
		UpdateBankLimit()
	end)

	UIConstants.Data.Storage.OnKeyRemoved(function(UUID: string)
		RemoveBankEntry(UUID)
		UpdateBankLimit()
	end)

	UpdateBankLimit()

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
		RefreshAllEquippedLabels()
	end)

	SetupVanityUnequip()
	SetupVanityToggle()

	local DrinkButton = AdvancedFrame:WaitForChild("Drink") :: TextButton
	SetupDrinkAll(DrinkButton)

	SellFrame.Sell.MouseButton1Click:Connect(EnterSellMode)
	SellFrame.Cancel.MouseButton1Click:Connect(ExitSellMode)
	AdvancedFrame.Confirm.MouseButton1Click:Connect(ConfirmSell)

	StorageFrame.Storage.MouseButton1Click:Connect(OpenStorage)
	StorageFrame.Cancel.MouseButton1Click:Connect(CloseStorage)

	SearchBox:GetPropertyChangedSignal("Text"):Connect(ApplySearchFilter)
end

return Inventory
