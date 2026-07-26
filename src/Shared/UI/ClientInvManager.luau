local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local UIFunctions = require(script.Parent.UIFunctions)
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Inventory = PlayerGui:WaitForChild("Main").Inventory
local FloatingItem = Inventory.InventoryContainer:FindFirstChild("FloatingDisplay") :: Frame
local InfoFrame = Inventory:FindFirstChild("InfoFrame") :: Frame
local Mouse = LocalPlayer:GetMouse()

local ClientInvManager = {}

local CurrentSession = 0
local ActiveConnections = {}
local MouseOffset = Vector2.new(20, 0)
local Container = FloatingItem.Parent :: GuiObject

local function GetHoverPosition(): UDim2
	local RelativeX = (Mouse.X - Container.AbsolutePosition.X) / Container.AbsoluteSize.X
	local RelativeY = (Mouse.Y - Container.AbsolutePosition.Y) / Container.AbsoluteSize.Y

	return UDim2.new(RelativeX, MouseOffset.X, RelativeY, MouseOffset.Y)
end

local function StopHover()
	for _, Connection in ipairs(ActiveConnections) do
		Connection:Disconnect()
	end
	table.clear(ActiveConnections)

	if FloatingItem then
		FloatingItem.Visible = false
	end
end

local function UpdateStatsFrame(StatsInfo: Instance, ItemData: Types.Item, InventoryEntry: Types.ItemData)
	for _, label in StatsInfo:GetChildren() do
		if label:IsA("TextLabel") then
			label.Visible = false
		end
	end

	if ItemData.Kind == "Equipment" then
		for stat, amount in ItemData.Stats do
			local Label = StatsInfo:FindFirstChild(stat) :: TextLabel

			if Label and amount > 0 then
				Label.Visible = true
				Label.Text = stat .. ": " .. amount
			end
		end
	end
end

function ClientInvManager:Hover(Button: ImageButton, InventoryEntry: Types.ItemData)
	if not FloatingItem then
		return
	end

	if not InventoryEntry then
		print("No inventory entry")
		return
	end

	local ItemData = ItemsData[InventoryEntry.Name] :: Types.Item

	if not ItemData then
		print("No item data for item: ", InventoryEntry.Name, ItemData)
		return
	end

	StopHover()
	CurrentSession += 1
	local Session = CurrentSession

	FloatingItem.Visible = true
	FloatingItem.Position = GetHoverPosition()
	FloatingItem.ImageContainer.Icon.Image = ItemData.Data.Icon

	UIFunctions:ApplyRarityGradient(FloatingItem.ImageContainer.Rarity, ItemData.Data.Rarity)
	UIFunctions:ApplyRarityGradient(FloatingItem.ItemName, ItemData.Data.Rarity)
	UIFunctions:ApplyRarityGradient(FloatingItem.Rarity, ItemData.Data.Rarity)

	FloatingItem.ItemName.Text = ItemData.Data.Name
	FloatingItem.Level.Text = "Level: " .. ItemData.Data.Level
	FloatingItem.Rarity.Text = ItemData.Data.Rarity

	UpdateStatsFrame(FloatingItem.Stats.Info, ItemData, InventoryEntry)

	local RenderConnection = RunService.RenderStepped:Connect(function()
		if Session ~= CurrentSession then
			return
		end
		FloatingItem.Position = GetHoverPosition()
	end)

	local LeaveConnection
	LeaveConnection = Button.MouseLeave:Connect(function()
		if Session ~= CurrentSession then
			return
		end
		CurrentSession += 1
		StopHover()
	end)

	local DestroyingConnection
	DestroyingConnection = Button.Destroying:Connect(function()
		if Session ~= CurrentSession then
			return
		end
		CurrentSession += 1
		StopHover()
	end)

	table.insert(ActiveConnections, RenderConnection)
	table.insert(ActiveConnections, LeaveConnection)
	table.insert(ActiveConnections, DestroyingConnection)
end

function ClientInvManager:ShowInfo(InventoryEntry: Types.ItemData, UUID: string)
	if not InfoFrame then
		return
	end

	if not InventoryEntry then
		print("No inventory entry")
		return
	end

	local ItemData = ItemsData[InventoryEntry.Name] :: Types.Item

	if not ItemData then
		print("No item data for item: ", InventoryEntry.Name, ItemData)
		return
	end

	InfoFrame.Visible = true
	InfoFrame.ImageContainer.Icon.Image = ItemData.Data.Icon

	UIFunctions:ApplyRarityGradient(InfoFrame.ImageContainer.Rarity, ItemData.Data.Rarity)
	UIFunctions:ApplyRarityGradient(InfoFrame.ItemName, ItemData.Data.Rarity)
	UIFunctions:ApplyRarityGradient(InfoFrame.Rarity, ItemData.Data.Rarity)

	InfoFrame.ItemName.Text = ItemData.Data.Name
	InfoFrame.Level.Text = "Level: " .. ItemData.Data.Level
	InfoFrame.Rarity.Text = ItemData.Data.Rarity
	InfoFrame.Description.Text = ItemData.Data.Description
	InfoFrame.Action.ActionName.Text = ItemData.Data.ActionName

	InfoFrame.Action.MouseButton1Clicked:Connect(function()
		if ItemData.Action then
			ItemData:Action(UUID)
		end
	end)

	UpdateStatsFrame(InfoFrame.Stats.Info, ItemData, InventoryEntry)
end

return ClientInvManager
