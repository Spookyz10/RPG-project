local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIFunctions = require(script.Parent.UIFunctions)
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Inventory = PlayerGui:WaitForChild("Main").Inventory
local InfoFrame = Inventory:FindFirstChild("InfoFrame") :: Frame

local ItemDisplay = {}

local function UpdateStatsFrame(StatsInfo: Instance, ItemData: Types.Item, _InventoryEntry: Types.ItemData)
	if ItemData.Kind == "Equipment" then
		UIFunctions:UpdateStatsContainer(StatsInfo, ItemData.Stats)
	end
end

function ItemDisplay:Hover(Button: ImageButton, InventoryEntry: Types.ItemData)
	if not InventoryEntry then
		print("No inventory entry")
		return
	end

	local ItemData = ItemsData[InventoryEntry.Name] :: Types.Item

	if not ItemData then
		print("No item data for item: ", InventoryEntry.Name, ItemData)
		return
	end

	UIFunctions:Hover(Button, function(FloatingItem: Frame)
		FloatingItem.ImageContainer.Visible = true
		FloatingItem.ItemName.Visible = true
		FloatingItem.Level.Visible = true
		FloatingItem.Rarity.Visible = true

		FloatingItem.ImageContainer.Icon.Image = ItemData.Data.Icon

		UIFunctions:ApplyRarityGradient(FloatingItem.ImageContainer.Rarity, ItemData.Data.Rarity)
		UIFunctions:ApplyRarityGradient(FloatingItem.ItemName, ItemData.Data.Rarity)
		UIFunctions:ApplyRarityGradient(FloatingItem.Rarity, ItemData.Data.Rarity)

		FloatingItem.ItemName.Text = ItemData.Data.Name
		FloatingItem.Level.Text = "Level: " .. ItemData.Data.Level
		FloatingItem.Rarity.Text = ItemData.Data.Rarity

		if ItemData.Kind == "Equipment" then
			FloatingItem.Stats.Visible = true
			UIFunctions:UpdateStatsContainer(FloatingItem.Stats.Info, ItemData.Stats)
		end

		-- exemplo: mostrar Upgrades/Enchants só quando existirem
		if InventoryEntry.Upgrades and InventoryEntry.Upgrades > 0 and FloatingItem:FindFirstChild("Upgrades") then
			FloatingItem.Upgrades.Visible = true
			FloatingItem.Upgrades.Text = "+" .. InventoryEntry.Upgrades
		end
	end)
end

function ItemDisplay:ShowInfo(InventoryEntry: Types.ItemData, UUID: string)
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
	local Action = InfoFrame.Action :: ImageButton

	Action.MouseButton1Click:Connect(function()
		if ItemData.Action then
			ItemData:Action(UUID)
		end
	end)

	UpdateStatsFrame(InfoFrame.Stats.Info, ItemData, InventoryEntry)
end

return ItemDisplay
