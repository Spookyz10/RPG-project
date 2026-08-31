local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local ALLOWED_USER_ID = 531376199

if Player.UserId ~= ALLOWED_USER_ID then
	return
end

local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)

local PlayerGui = Player:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("Main")

local SelectedItem: string? = nil
local ItemButtons: { [string]: TextButton } = {}

local Frame = Instance.new("Frame")
Frame.Name = "Admin"
Frame.Size = UDim2.fromScale(0.3, 0.55)
Frame.Position = UDim2.fromScale(0.35, 0.225)
Frame.AnchorPoint = Vector2.new(0, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Visible = false
Frame.Parent = Main

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0.08, 0)
Title.Position = UDim2.fromScale(0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Item Spawner"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "Close"
CloseButton.Size = UDim2.fromScale(0.08, 0.06)
CloseButton.Position = UDim2.fromScale(0.9, 0.01)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Frame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ItemList"
ScrollFrame.Size = UDim2.new(1, 0, 0.78, 0)
ScrollFrame.Position = UDim2.fromScale(0, 0.1)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.fromScale(0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.Parent = Frame

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 4)
ListLayout.Parent = ScrollFrame

local SpawnButton = Instance.new("TextButton")
SpawnButton.Name = "Spawn"
SpawnButton.Size = UDim2.new(1, 0, 0.1, 0)
SpawnButton.Position = UDim2.fromScale(0, 0.9)
SpawnButton.BackgroundColor3 = Color3.fromRGB(40, 150, 70)
SpawnButton.Text = "Spawn"
SpawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnButton.TextScaled = true
SpawnButton.Font = Enum.Font.GothamBold
SpawnButton.Parent = Frame

local SpawnCorner = Instance.new("UICorner")
SpawnCorner.CornerRadius = UDim.new(0, 6)
SpawnCorner.Parent = SpawnButton

local function SelectItem(itemName: string, button: TextButton)
	if SelectedItem and ItemButtons[SelectedItem] then
		ItemButtons[SelectedItem].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end

	SelectedItem = itemName
	button.BackgroundColor3 = Color3.fromRGB(70, 110, 200)
end

for itemName in ItemsData do
	local Button = Instance.new("TextButton")
	Button.Name = itemName
	Button.Size = UDim2.new(1, 0, 0.09, 0)
	Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Button.Text = itemName
	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button.TextScaled = true
	Button.Font = Enum.Font.Gotham
	Button.Parent = ScrollFrame

	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0, 6)
	ButtonCorner.Parent = Button

	Button.MouseButton1Click:Connect(function()
		SelectItem(itemName, Button)
	end)

	ItemButtons[itemName] = Button
end

CloseButton.MouseButton1Click:Connect(function()
	Frame.Visible = false
end)

SpawnButton.MouseButton1Click:Connect(function()
	if not SelectedItem then
		return
	end

	RemoteManager.SendServerEvent("SpawnItem", SelectedItem)
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then
		return
	end

	if input.KeyCode == Enum.KeyCode.F8 then
		Frame.Visible = not Frame.Visible
	end
end)
