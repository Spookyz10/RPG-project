local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shops = require(ReplicatedStorage.Shared.Shops)
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local Skills = require(ReplicatedStorage.Shared.Skills)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local ItemDisplay = require(ReplicatedStorage.Shared.UI.ItemDisplay)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local UI = {}

local CurrentShopName: string? = nil
local BounceTween: Tween? = nil
local ItemFrames: { ImageButton } = {}

local function GetItemVisual(itemName: string, itemType: string): (string, string?)
	if itemType == "Skill" then
		local SkillInfo = Skills[itemName] :: Types.SkillData
		if SkillInfo then
			return SkillInfo.Icon, nil
		end
		return "", nil
	end

	local ItemInfo = ItemsData[itemName] :: Types.Item
	if ItemInfo then
		return ItemInfo.Data.Icon, ItemInfo.Data.Rarity
	end

	return "", nil
end

local function ClearItemFrames()
	for _, Frame in ItemFrames do
		Frame:Destroy()
	end
	table.clear(ItemFrames)
end

local function CreateCostEntries(CostFrame: Instance, Cost: { [string]: number })
	for _, child in CostFrame:GetChildren() do
		if child:IsA("Frame") or child:IsA("ImageButton") or child:IsA("ImageLabel") then
			child:Destroy()
		end
	end

	local Templates = ReplicatedStorage.Assets.UI.Templates

	for currency, amount in Cost do
		local CostEntry = Templates.Cost:Clone()
		CostEntry.Name = currency
		CostEntry.Value.Text = tostring(amount)
		CostEntry.Parent = CostFrame
	end
end

local function CreateItemFrame(itemName: string, itemInfo: { Cost: { [string]: number }, itemType: string })
	local ShopFrame = UIConstants.Main.Shop
	local Templates = ReplicatedStorage.Assets.UI.Templates
	local Container = ShopFrame.Container

	local Icon, Rarity = GetItemVisual(itemName, itemInfo.itemType)

	local Frame = Templates.Shop:Clone()
	Frame.Name = itemName
	Frame.ItemName.Text = itemName
	Frame.ImageContainer.Icon.Image = Icon
	UIFunctions:ApplyRarityGradient(Frame.ImageContainer.Rarity, Rarity)

	CreateCostEntries(Frame.Cost, itemInfo.Cost)

	Frame.MouseEnter:Connect(function()
		ItemDisplay:HoverShopItem(Frame, itemName, itemInfo.itemType)
	end)

	Frame.Action.MouseButton1Click:Connect(function()
		if CurrentShopName then
			RemoteManager.SendServerEvent("ShopBuy", CurrentShopName, itemName)
		end
	end)

	Frame.Parent = Container

	table.insert(ItemFrames, Frame)
end

function UI.Open(shopName: string)
	local ShopInfo = Shops[shopName] :: Types.Shop
	if not ShopInfo then
		return
	end

	local ShopFrame = UIConstants.Main.Shop

	CurrentShopName = shopName
	ClearItemFrames()

	for itemName, itemInfo in ShopInfo do
		CreateItemFrame(itemName, itemInfo)
	end

	ShopFrame.Visible = true

	if BounceTween then
		BounceTween:Cancel()
		BounceTween = nil
	end

	ShopFrame.Position = UDim2.fromScale(0.5, 1.6)

	BounceTween = TweenService:Create(
		ShopFrame,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Position = UDim2.fromScale(0.5, 0.5) }
	)
	BounceTween:Play()
end

function UI.Close()
	local ShopFrame = UIConstants.Main:FindFirstChild("Shop")
	if not ShopFrame then
		return
	end

	if BounceTween then
		BounceTween:Cancel()
		BounceTween = nil
	end

	BounceTween = TweenService:Create(
		ShopFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Position = UDim2.fromScale(0.5, 1.6) }
	)

	BounceTween:Play()
	BounceTween.Completed:Wait()

	ShopFrame.Visible = false
	CurrentShopName = nil
	ClearItemFrames()
end

function UI.Init()
	local ShopFrame = UIConstants.Main:FindFirstChild("Shop")
	if not ShopFrame then
		return
	end

	ShopFrame.Close.MouseButton1Click:Connect(function()
		UI.Close()
	end)

	ShopFrame.Visible = false
end

return UI
