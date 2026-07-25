local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIFunctions = require(script.Parent.UIFunctions)
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Data = require(ReplicatedStorage.Shared.Data).client

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Inventory = PlayerGui:WaitForChild("Main").Inventory
local FloatingItem = Inventory.InventoryContainer:FindFirstChild("FloatingDisplay") :: Frame
local Mouse = LocalPlayer:GetMouse()

local ClientInvManager = {}

local CurrentSession = 0
local ActiveConnections = {}
local MouseOffset = Vector2.new(20, 0)

local function StopHover()
	for _, Connection in ipairs(ActiveConnections) do
		Connection:Disconnect()
	end
	table.clear(ActiveConnections)

	if FloatingItem then
		FloatingItem.Visible = false
	end
end

function ClientInvManager:Hover(Button: ImageButton, UUID: string)
	if not FloatingItem then
		return
	end

	local InventoryEntry = Data.Inventory[UUID]()

	if not InventoryEntry then
		return
	end

	local ItemData = ItemsData[InventoryEntry.Name] :: Types.Item
	if not ItemData then
		return
	end

	StopHover()

	CurrentSession += 1
	local Session = CurrentSession

	FloatingItem.Visible = true
	FloatingItem.Position = UDim2.fromOffset(Mouse.X + MouseOffset.X, Mouse.Y + MouseOffset.Y)
	FloatingItem.ImageContainer.Icon.Image = ItemData.Data.Icon
	UIFunctions:ApplyRarityGradient(FloatingItem.ImageContainer.Rarity, ItemData.Data.Rarity)
	UIFunctions:ApplyRarityGradient(FloatingItem.ItemName, ItemData.Data.Rarity)
	UIFunctions:ApplyRarityGradient(FloatingItem.Rarity, ItemData.Data.Rarity)
	FloatingItem.ItemName.Text = ItemData.Data.Name
	FloatingItem.Level.Text = "Level: " .. ItemData.Data.Level

	for _, label in FloatingItem.Stats:GetChildren() do
		if label:IsA("TextLabel") then
			label.Visible = false
		end
	end

	if ItemData.Kind == "Equipment" then
		for stat, amount in ItemData.Stats do
			local Label = FloatingItem.Stats:FindFirstChild(stat) :: TextLabel
			if Label and amount > 0 then
				Label.Visible = true
				Label.Text = stat .. ": " .. amount
			end
		end
	end

	local RenderConnection = RunService.RenderStepped:Connect(function()
		if Session ~= CurrentSession then
			return
		end

		FloatingItem.Position = UDim2.fromOffset(Mouse.X + MouseOffset.X, Mouse.Y + MouseOffset.Y)
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

return ClientInvManager
