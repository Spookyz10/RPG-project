local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local ClientInvManager = require(ReplicatedStorage.Shared.UI.ClientInvManager)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local UI = {}

local ItemFrames: { [string]: { Frame: ImageButton, Disconnectors: { () -> () } } } = {}

function UI.Init()
	local Data = UIConstants.Data
	local Character = UIConstants.Character

	local InventoryFrame = UIConstants.Main.Inventory
	local ItemContainer = InventoryFrame.InventoryContainer.Container

	local EquipmentContainer = InventoryFrame.InventoryContainer.Player.Equipment
	local Stats = InventoryFrame.InventoryContainer.Player.Stats
	local ItemTemplate = ReplicatedStorage.Assets.UI.ItemTemplate.Inventory

	local Top = InventoryFrame.InventoryContainer.Top

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

		local Frame = ItemTemplate:Clone()
		Frame.Name = UUID
		Frame.Parent = ItemContainer

		local ItemData = ItemsData[KeyData.Name] :: Types.Item

		if not ItemData then
			print("No item data for item: ", KeyData.Name, ItemData)
			return
		end

		UpdateItemFrame(Frame, ItemData, KeyData)

		local Disconnectors = {}

		local HoverConnection = Frame.MouseEnter:Connect(function()
			ClientInvManager:Hover(Frame, KeyData)
		end)
		table.insert(Disconnectors, function()
			HoverConnection:Disconnect()
		end)

		local ClickConnection = Frame.MouseButton1Click:Connect(function()
			ClientInvManager:ShowInfo(KeyData, UUID)
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
						ClientInvManager:Hover(EquipmentSlot, KeyData)
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
end

return UI
