local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local ClientInvManager = require(ReplicatedStorage.Shared.UI.ClientInvManager)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Data = require(ReplicatedStorage.Shared.Data).client

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local InventoryFrame = PlayerGui:WaitForChild("Main").Inventory
local ItemContainer = InventoryFrame.InventoryContainer.Container
local ItemTemplate = ReplicatedStorage.Assets.UI.ItemTemplate.Inventory

local ItemFrames: { [string]: { Frame: ImageButton, Disconnectors: { () -> () } } } = {}

local function UpdateItemFrame(Button: ImageButton, ItemData: Types.Item)
	if Button then
		Button.Icon.Image = ItemData.Data.Icon
		UIFunctions:ApplyRarityGradient(Button.Rarity, ItemData.Data.Rarity)
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

	UpdateItemFrame(Frame, ItemData)

	local Disconnectors = {}

	local HoverConnection = Frame.MouseEnter:Connect(function()
		ClientInvManager:Hover(Frame, KeyData)
	end)
	table.insert(Disconnectors, function()
		HoverConnection:Disconnect()
	end)

	local ClickConnection = Frame.MouseButton1Click:Connect(function()
		ClientInvManager:ShowInfo(KeyData)
	end)
	table.insert(Disconnectors, function()
		ClickConnection:Disconnect()
	end)

	local ChangedDisconnect = Data.Inventory[UUID].Changed(function(NewItemData)
		UpdateItemFrame(Frame, NewItemData)
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

	for _, Disconnect in ipairs(Entry.Disconnectors) do
		Disconnect()
	end

	Entry.Frame:Destroy()
	ItemFrames[UUID] = nil
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
