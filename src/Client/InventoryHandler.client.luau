local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientInvManager = require(ReplicatedStorage.Shared.UI.ClientInvManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Data = require(ReplicatedStorage.Shared.Data).client
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local InventoryFrame = PlayerGui.Inventory
local ItemContainer = InventoryFrame.InventoryContainer.Container

local ItemTemplate = ReplicatedStorage.Assets.UI.ItemTemplate.Inventory

local ItemFrames: { [string]: { Frame: ImageButton, Disconnectors: { () -> () } } } = {}

local function UpdateItemFrame(Frame: ImageButton, ItemData: Types.Item)
	Frame.Icon.Image = ItemData.Data.Icon
end

local function CreateItemFrame(UUID: string, ItemData: any)
	if ItemFrames[UUID] then
		return
	end

	local Frame = ItemTemplate:Clone()
	Frame.Name = UUID
	Frame.Parent = ItemContainer

	UpdateItemFrame(Frame, ItemData)

	local Disconnectors = {}

	local HoverConnection = Frame.MouseEnter:Connect(function()
		ClientInvManager:Hover(Frame, UUID)
	end)
	table.insert(Disconnectors, function()
		HoverConnection:Disconnect()
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
