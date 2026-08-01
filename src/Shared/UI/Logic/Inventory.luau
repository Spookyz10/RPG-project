local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local ItemDisplay = require(ReplicatedStorage.Shared.UI.ItemDisplay)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local UI = {}

local ItemFrames: { [string]: { Frame: ImageButton, Disconnectors: { () -> () } } } = {}

local SellMode = false
local SelectedItems: { [string]: { Clone: GuiObject, Amount: number } } = {}

local PendingSellUUID: string? = nil
local PendingSellButton: GuiObject? = nil

function UI.Init()
	local Data = UIConstants.Data
	local Character = UIConstants.Character

	local InventoryFrame = UIConstants.Main.Inventory
	local ItemContainer = InventoryFrame.InventoryContainer.Container

	local EquipmentContainer = InventoryFrame.InventoryContainer.Player.Equipment
	local Stats = InventoryFrame.InventoryContainer.Player.Stats
	local Templates = ReplicatedStorage.Assets.UI.Templates.Inventory

	local Top = InventoryFrame.InventoryContainer.Top
	local SellButton = InventoryFrame.InventoryContainer.Sell :: GuiButton
	local ConfirmButton = InventoryFrame.InventoryContainer.Confirm :: GuiButton
	local CancelButton = InventoryFrame.InventoryContainer.Cancel :: GuiButton

	local SellMultiple = UIConstants.Main.SellMultiple
	local SellMultipleItemContainer = SellMultiple.ItemContainer

	local function ClearSelection()
		for _, Entry in SelectedItems do
			if Entry.Clone then
				Entry.Clone:Destroy()
			end
		end
		table.clear(SelectedItems)
	end

	local function DeselectItem(UUID: string)
		local Entry = SelectedItems[UUID]
		if not Entry then
			return
		end

		if Entry.Clone then
			Entry.Clone:Destroy()
		end

		SelectedItems[UUID] = nil
	end

	local function SelectItem(UUID: string, Button: GuiObject, Amount: number)
		if SelectedItems[UUID] then
			return
		end

		local Clone = Templates.Selected:Clone()
		Clone.Parent = Button

		SelectedItems[UUID] = { Clone = Clone, Amount = Amount }
	end

	local function CloseSellMultiple()
		SellMultiple.Visible = false
		PendingSellUUID = nil
		PendingSellButton = nil
	end

	local function OpenSellMultiple(UUID: string, Button: GuiObject, KeyData: any, ItemInfo: Types.Item)
		PendingSellUUID = UUID
		PendingSellButton = Button

		SellMultipleItemContainer.Icon.Image = ItemInfo.Data.Icon
		UIFunctions:ApplyRarityGradient(SellMultipleItemContainer.Rarity, ItemInfo.Data.Rarity)

		SellMultiple.ItemName.Text = ItemInfo.Data.Name
		SellMultiple.AmountLabel.Text = "You have " .. KeyData.Amount .. " " .. ItemInfo.Data.Name .. " in this stack."
		SellMultiple.Amount.Text = tostring(KeyData.Amount)

		SellMultiple.Visible = true
	end

	local function OnItemClicked(UUID: string, Button: ImageButton)
		if not SellMode then
			return
		end

		if SelectedItems[UUID] then
			DeselectItem(UUID)
			return
		end

		local KeyData = Data.Inventory[UUID]()
		if not KeyData then
			return
		end

		local ItemInfo = ItemsData[KeyData.Name] :: Types.Item
		if not ItemInfo then
			return
		end

		if ItemInfo.Data.Stackable and KeyData.Amount > 1 then
			OpenSellMultiple(UUID, Button, KeyData, ItemInfo)
		else
			SelectItem(UUID, Button, KeyData.Amount)
		end
	end

	local function SetSellMode(enabled: boolean)
		SellMode = enabled
		SellButton.Visible = not enabled
		ConfirmButton.Visible = enabled
		CancelButton.Visible = enabled
	end

	SellMultiple.Amount:GetPropertyChangedSignal("Text"):Connect(function()
		if not PendingSellUUID then
			return
		end

		local KeyData = Data.Inventory[PendingSellUUID]()
		if not KeyData then
			return
		end

		local Amount = tonumber(SellMultiple.Amount.Text)
		if not Amount then
			return
		end

		local Clamped = math.clamp(math.floor(Amount), 1, KeyData.Amount)
		if Clamped ~= Amount then
			SellMultiple.Amount.Text = tostring(Clamped)
		end
	end)

	SellMultiple.Cancel.MouseButton1Click:Connect(function()
		CloseSellMultiple()
	end)

	SellMultiple.Confirm.MouseButton1Click:Connect(function()
		if not PendingSellUUID or not PendingSellButton then
			CloseSellMultiple()
			return
		end

		local KeyData = Data.Inventory[PendingSellUUID]()
		if not KeyData then
			CloseSellMultiple()
			return
		end

		local Amount = tonumber(SellMultiple.Amount.Text)
		if not Amount then
			return
		end

		Amount = math.clamp(math.floor(Amount), 1, KeyData.Amount)

		SelectItem(PendingSellUUID, PendingSellButton, Amount)
		CloseSellMultiple()
	end)

	SellButton.MouseButton1Click:Connect(function()
		SetSellMode(true)
	end)

	ConfirmButton.MouseButton1Click:Connect(function()
		local SellList = {}
		for UUID, Entry in SelectedItems do
			SellList[UUID] = Entry.Amount
		end

		if next(SellList) then
			RemoteManager.SendServerEvent("SellItems", SellList)
		end

		ClearSelection()
		CloseSellMultiple()
		SetSellMode(false)
	end)

	CancelButton.MouseButton1Click:Connect(function()
		ClearSelection()
		CloseSellMultiple()
		SetSellMode(false)
	end)

	local function UpdateItemFrame(Button: ImageButton, ItemData: Types.Item, KeyData: any)
		if Button then
			Button.Icon.Image = ItemData.Data.Icon
			UIFunctions:ApplyRarityGradient(Button.Rarity, ItemData.Data.Rarity)
			Button.Visible = not KeyData.Equipped
		end
	end

	local function CreateItemFrame(UUID: string, KeyData: any)
		if ItemFrames[UUID] then
			return
		end

		local Frame = Templates:Clone()
		Frame.Name = UUID
		Frame.Parent = ItemContainer

		local ItemData = ItemsData[KeyData.Name] :: Types.Item

		if not ItemData then
			return
		end

		UpdateItemFrame(Frame, ItemData, KeyData)

		local Disconnectors = {}

		local HoverConnection = Frame.MouseEnter:Connect(function()
			ItemDisplay:Hover(Frame, KeyData)
		end)
		table.insert(Disconnectors, function()
			HoverConnection:Disconnect()
		end)

		local ClickConnection = Frame.MouseButton1Click:Connect(function()
			if SellMode then
				OnItemClicked(UUID, Frame)
			else
				ItemDisplay:ShowInfo(KeyData, UUID)
			end
		end)
		table.insert(Disconnectors, function()
			ClickConnection:Disconnect()
		end)

		local ChangedDisconnect = Data.Inventory[UUID].Changed(function(NewItemData)
			UpdateItemFrame(Frame, ItemData, NewItemData)
		end)
		table.insert(Disconnectors, ChangedDisconnect)

		ItemFrames[UUID] = {
			Frame = Frame,
			Disconnectors = Disconnectors,
		}
	end

	local function RemoveItemFrame(UUID: string)
		local Entry = ItemFrames[UUID]

		if not Entry then
			return
		end

		for _, Disconnect in Entry.Disconnectors do
			Disconnect()
		end

		Entry.Frame:Destroy()
		ItemFrames[UUID] = nil
		SelectedItems[UUID] = nil

		if PendingSellUUID == UUID then
			CloseSellMultiple()
		end
	end

	local function UpdateEquipment()
		for slot, item in Data.Equipment() do
			local InventoryKey = Data.Inventory[item]()
			local EquipmentSlot = EquipmentContainer:FindFirstChild(slot)
			if InventoryKey then
				local ItemInfo = ItemsData[InventoryKey.Name] :: Types.Item

				if ItemInfo then
					UIFunctions:ApplyRarityGradient(EquipmentSlot.ClipFrame.Rarity, ItemInfo.Data.Rarity)
					EquipmentSlot.Icon.Image = ItemInfo.Data.Icon
				end
			else
				if EquipmentSlot.ClipFrame.Rarity:FindFirstChildOfClass("UIGradient") then
					EquipmentSlot.ClipFrame.Rarity:FindFirstChildOfClass("UIGradient"):Destroy()
				end
				EquipmentSlot.Icon.Image = ""
			end
		end
	end

	local function SetupEquipmentSlots()
		for _, EquipmentSlot in EquipmentContainer:GetChildren() do
			if not EquipmentSlot:IsA("ImageButton") then
				continue
			end

			local SlotName = EquipmentSlot.Name

			EquipmentSlot.MouseEnter:Connect(function()
				local UUID = Data.Equipment[SlotName]()
				if UUID and UUID ~= "" then
					local KeyData = Data.Inventory[UUID]()
					if KeyData then
						ItemDisplay:Hover(EquipmentSlot, KeyData)
					end
				end
			end)

			EquipmentSlot.MouseButton1Click:Connect(function()
				local UUID = Data.Equipment[SlotName]()
				RemoteManager.SendServerEvent("UnequipItem", UUID)
			end)
		end
	end

	for UUID, ItemData in Data.Inventory() do
		CreateItemFrame(UUID, ItemData)
	end

	Data.Inventory.OnKeyAdded(function(UUID, ItemData)
		CreateItemFrame(UUID, ItemData)
	end)

	Data.Inventory.OnKeyRemoved(function(UUID)
		RemoveItemFrame(UUID)
	end)

	Data.Equipment.Changed(function()
		UIFunctions:UpdateStatsContainer(Stats.Info, Functions:GetTotalStats(Character, Data()))
		UpdateEquipment()
	end)

	Data.ExtraStats.Changed(function()
		UIFunctions:UpdateStatsContainer(Stats.Info, Functions:GetTotalStats(Character, Data()))
	end)

	UpdateEquipment()
	SetupEquipmentSlots()
	UIFunctions:UpdateStatsContainer(Stats.Info, Functions:GetTotalStats(Character, Data()))

	Data.CurrentInventorySpace.Changed(function(current)
		Top.Space.Text = current .. "/" .. Data.MaxInventorySpace()
	end)

	Data.MaxInventorySpace.Changed(function(current)
		Top.Space.Text = Data.CurrentInventorySpace() .. "/" .. current
	end)

	Top.Space.Text = Data.CurrentInventorySpace() .. "/" .. Data.MaxInventorySpace()

	SellMultiple.Visible = false
	ConfirmButton.Visible = false
	CancelButton.Visible = false
end

return UI
