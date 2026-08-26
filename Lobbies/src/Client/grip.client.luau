local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local ALLOWED_USER_ID = 531376199

if Player.UserId ~= ALLOWED_USER_ID then
	return
end

local Data = require(ReplicatedStorage.Shared.Data).client

local WeaponsFolder = ReplicatedStorage.Resources.Weapons
local GRIP_ATTACHMENT_NAME = "GripPoint"

local PlayerGui = Player:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("Main")

local FINE_ROT_STEP = 1
local COARSE_ROT_STEP = 15
local FINE_POS_STEP = 0.05
local COARSE_POS_STEP = 0.25

local Tuning = false
local PreviewModel: Model? = nil
local HiddenParts: { BasePart } = {}
local RenderConnection: RBXScriptConnection? = nil

local RotX, RotY, RotZ = 60, -200, 90
local PosX, PosY, PosZ = 0, 0, 0

local function getHand(character: Model): BasePart?
	return (character:FindFirstChild("RightHand") :: BasePart?) or (character:FindFirstChild("Right Arm") :: BasePart?)
end

local function findWeaponTemplate(weaponName: string): Model?
	for _, descendant in WeaponsFolder:GetDescendants() do
		if descendant:IsA("Model") and descendant.Name == weaponName then
			return descendant
		end
	end
	return nil
end

local function getEquippedWeaponName(): string?
	local UUID = Data.Equipment.Weapon()
	if not UUID or UUID == "" then
		return nil
	end

	local ItemEntry = Data.Inventory[UUID]()
	if not ItemEntry then
		return nil
	end

	return ItemEntry.Name
end

local function buildOutputLine(): string
	return string.format(
		"CFrame.new(%.2f, %.2f, %.2f) * CFrame.Angles(math.rad(%d), math.rad(%d), math.rad(%d))",
		PosX,
		PosY,
		PosZ,
		RotX,
		RotY,
		RotZ
	)
end

local Frame = Instance.new("Frame")
Frame.Name = "GripTuner"
Frame.Size = UDim2.fromOffset(300, 340)
Frame.Position = UDim2.fromScale(0.02, 0.2)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Visible = false
Frame.Parent = Main

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 26)
Title.BackgroundTransparency = 1
Title.Text = "Grip Tuner (F8)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = Frame

local Output = Instance.new("TextBox")
Output.Size = UDim2.new(1, -16, 0, 50)
Output.Position = UDim2.fromOffset(8, 30)
Output.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Output.TextColor3 = Color3.fromRGB(120, 220, 120)
Output.TextWrapped = true
Output.ClearTextOnFocus = false
Output.Font = Enum.Font.Code
Output.TextSize = 12
Output.Text = buildOutputLine()
Output.Parent = Frame

local OutputCorner = Instance.new("UICorner")
OutputCorner.CornerRadius = UDim.new(0, 6)
OutputCorner.Parent = Output

local ListFrame = Instance.new("Frame")
ListFrame.Size = UDim2.new(1, -16, 1, -140)
ListFrame.Position = UDim2.fromOffset(8, 86)
ListFrame.BackgroundTransparency = 1
ListFrame.Parent = Frame

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 4)
ListLayout.Parent = ListFrame

local ValueLabels: { [string]: TextLabel } = {}

local function updateOutput()
	Output.Text = buildOutputLine()

	if ValueLabels.RotX then
		ValueLabels.RotX.Text = "Rot X: " .. RotX
	end
	if ValueLabels.RotY then
		ValueLabels.RotY.Text = "Rot Y: " .. RotY
	end
	if ValueLabels.RotZ then
		ValueLabels.RotZ.Text = "Rot Z: " .. RotZ
	end
	if ValueLabels.PosX then
		ValueLabels.PosX.Text = "Pos X: " .. string.format("%.2f", PosX)
	end
	if ValueLabels.PosY then
		ValueLabels.PosY.Text = "Pos Y: " .. string.format("%.2f", PosY)
	end
	if ValueLabels.PosZ then
		ValueLabels.PosZ.Text = "Pos Z: " .. string.format("%.2f", PosZ)
	end

	print("[GripTuner] " .. buildOutputLine())
end

local function getStep(isRotation: boolean): number
	local Coarse = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
	if isRotation then
		return Coarse and COARSE_ROT_STEP or FINE_ROT_STEP
	end
	return Coarse and COARSE_POS_STEP or FINE_POS_STEP
end

local function createRow(axisName: string, isRotation: boolean, layoutOrder: number)
	local Row = Instance.new("Frame")
	Row.Size = UDim2.new(1, 0, 0, 28)
	Row.BackgroundTransparency = 1
	Row.LayoutOrder = layoutOrder
	Row.Parent = ListFrame

	local RowLayout = Instance.new("UIListLayout")
	RowLayout.FillDirection = Enum.FillDirection.Horizontal
	RowLayout.SortOrder = Enum.SortOrder.LayoutOrder
	RowLayout.Padding = UDim.new(0, 4)
	RowLayout.Parent = Row

	local Minus = Instance.new("TextButton")
	Minus.Size = UDim2.fromOffset(28, 26)
	Minus.Text = "-"
	Minus.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	Minus.TextColor3 = Color3.fromRGB(255, 255, 255)
	Minus.Font = Enum.Font.GothamBold
	Minus.TextScaled = true
	Minus.LayoutOrder = 1
	Minus.Parent = Row

	local ValueLabel = Instance.new("TextLabel")
	ValueLabel.Size = UDim2.fromOffset(150, 26)
	ValueLabel.BackgroundTransparency = 1
	ValueLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	ValueLabel.Font = Enum.Font.Gotham
	ValueLabel.TextScaled = true
	ValueLabel.LayoutOrder = 2
	ValueLabel.Parent = Row
	ValueLabels[axisName] = ValueLabel

	local Plus = Instance.new("TextButton")
	Plus.Size = UDim2.fromOffset(28, 26)
	Plus.Text = "+"
	Plus.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	Plus.TextColor3 = Color3.fromRGB(255, 255, 255)
	Plus.Font = Enum.Font.GothamBold
	Plus.TextScaled = true
	Plus.LayoutOrder = 3
	Plus.Parent = Row

	local function adjust(direction: number)
		local Step = getStep(isRotation) * direction

		if axisName == "RotX" then
			RotX += Step
		elseif axisName == "RotY" then
			RotY += Step
		elseif axisName == "RotZ" then
			RotZ += Step
		elseif axisName == "PosX" then
			PosX += Step
		elseif axisName == "PosY" then
			PosY += Step
		elseif axisName == "PosZ" then
			PosZ += Step
		end

		updateOutput()
	end

	Minus.MouseButton1Click:Connect(function()
		adjust(-1)
	end)

	Plus.MouseButton1Click:Connect(function()
		adjust(1)
	end)
end

createRow("RotX", true, 1)
createRow("RotY", true, 2)
createRow("RotZ", true, 3)
createRow("PosX", false, 4)
createRow("PosY", false, 5)
createRow("PosZ", false, 6)

local ResetButton = Instance.new("TextButton")
ResetButton.Size = UDim2.new(1, 0, 0, 26)
ResetButton.Position = UDim2.new(0, 0, 1, -26)
ResetButton.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
ResetButton.Text = "Reset"
ResetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetButton.Font = Enum.Font.GothamBold
ResetButton.TextScaled = true
ResetButton.Parent = Frame

local ResetCorner = Instance.new("UICorner")
ResetCorner.CornerRadius = UDim.new(0, 6)
ResetCorner.Parent = ResetButton

ResetButton.MouseButton1Click:Connect(function()
	RotX, RotY, RotZ = 60, -200, 90
	PosX, PosY, PosZ = 0, 0, 0
	updateOutput()
end)

updateOutput()

local function stopTuning()
	if RenderConnection then
		RenderConnection:Disconnect()
		RenderConnection = nil
	end

	if PreviewModel then
		PreviewModel:Destroy()
		PreviewModel = nil
	end

	for _, part in HiddenParts do
		part.LocalTransparencyModifier = 0
	end
	table.clear(HiddenParts)

	Frame.Visible = false
	Tuning = false
end

local function startTuning()
	local Character = Player.Character
	if not Character then
		return
	end

	local Hand = getHand(Character)
	if not Hand then
		return
	end

	local WeaponName = getEquippedWeaponName()
	if not WeaponName then
		return
	end

	local Template = findWeaponTemplate(WeaponName)
	if not Template then
		return
	end

	for _, existing in Character:GetChildren() do
		if existing:IsA("Model") and existing.Name == WeaponName and existing:FindFirstChild("Handle") then
			for _, part in existing:GetDescendants() do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = 1
					table.insert(HiddenParts, part)
				end
			end
		end
	end

	PreviewModel = Template:Clone()
	local Handle = PreviewModel:FindFirstChild("Handle") :: BasePart
	PreviewModel.PrimaryPart = Handle
	PreviewModel.Parent = workspace

	for _, descendant in PreviewModel:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.Anchored = false
			descendant.Massless = true
		end
	end

	local GripAttachment = Handle:FindFirstChild(GRIP_ATTACHMENT_NAME) :: Attachment?

	RenderConnection = RunService.RenderStepped:Connect(function()
		if not Hand.Parent or not PreviewModel then
			return
		end

		local Offset = CFrame.new(PosX, PosY, PosZ) * CFrame.Angles(math.rad(RotX), math.rad(RotY), math.rad(RotZ))

		if GripAttachment then
			PreviewModel:PivotTo(Hand.CFrame * GripAttachment.CFrame:Inverse() * Offset)
		else
			PreviewModel:PivotTo(Hand.CFrame * Offset)
		end
	end)

	Frame.Visible = true
	Tuning = true
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then
		return
	end

	if input.KeyCode == Enum.KeyCode.F8 then
		if Tuning then
			stopTuning()
		else
			startTuning()
		end
	end
end)

Player.CharacterRemoving:Connect(function()
	if Tuning then
		stopTuning()
	end
end)
