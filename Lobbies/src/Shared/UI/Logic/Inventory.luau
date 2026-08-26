local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Inventory = {}

local Container: Instance = nil
local Template: TextButton = nil
local ItemLimit: TextLabel = nil
local EquippedContainer: Instance = nil

local Entries: { [string]: TextButton } = {}

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
end

local function CreateEntry(UUID: string, ItemData: Types.ItemData)
	if Entries[UUID] or not Template then
		return
	end

	local Button = Template:Clone()
	Button.Name = UUID
	Button.Parent = Container

	UpdateEntry(Button, ItemData)

	Button.MouseButton1Click:Connect(function() end)

	Entries[UUID] = Button

	UIConstants.Data.Inventory[UUID].Amount.Changed(function()
		local CurrentData = UIConstants.Data.Inventory[UUID]()
		if CurrentData then
			UpdateEntry(Button, CurrentData)
		end
	end)
end

local function RemoveEntry(UUID: string)
	local Button = Entries[UUID]
	if Button then
		Button:Destroy()
		Entries[UUID] = nil
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
		print("noooo")
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

function Inventory.Init()
	Container = UIConstants.PlayerGui:WaitForChild("Inventory"):WaitForChild("Main"):WaitForChild("Container")
	Template = ReplicatedStorage.Resources.UI.Templates:WaitForChild("InvTemplate") :: TextButton
	ItemLimit = UIConstants.PlayerGui:WaitForChild("Inventory"):WaitForChild("Main"):WaitForChild("ItemLimit")
	EquippedContainer = UIConstants.PlayerGui:WaitForChild("Inventory"):WaitForChild("Main"):WaitForChild("Equipped")

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
	end)
end

return Inventory
