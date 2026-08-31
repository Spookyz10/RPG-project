local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local LightingManager = require(ReplicatedStorage.Shared.LightingManager)
local MusicManager = require(ReplicatedStorage.Shared.MusicManager)

local Buttons = {}

local UIList = {
	Inventory = UIConstants.PlayerGui:WaitForChild("Inventory").Main,
	Skills = UIConstants.PlayerGui:WaitForChild("SkillSelector").Frame,
	Pets = UIConstants.PlayerGui:WaitForChild("PetUI").BuyOrSee,
}

local CurrentOpen: Instance? = nil

local function SetVisible(ui: Instance, value: boolean)
	if ui:IsA("ScreenGui") then
		ui.Enabled = value
	elseif ui:IsA("GuiObject") then
		ui.Visible = value
	end
end

local function GoHome()
	local Character = UIConstants.Player.Character
	if not Character then
		return
	end

	local Teleporter = workspace:FindFirstChild("ZoneTeleporters")
	local TargetPart = Teleporter and Teleporter:FindFirstChild("Lobby")
	if not TargetPart then
		return
	end

	Character:PivotTo(TargetPart.CFrame + Vector3.new(0, 3, 0))

	LightingManager:ResetToDefault()
	MusicManager:PlayLobby()
end

local function SetupHomeButton(ButtonsMain: Instance)
	local HomeFrame = ButtonsMain:FindFirstChild("Home")
	if not HomeFrame then
		return
	end

	local Button = HomeFrame:FindFirstChildOfClass("TextButton")
	if not Button then
		return
	end

	Button.MouseButton1Click:Connect(GoHome)
end

local function UpdateInventoryAmountLabel(ButtonsMain: Instance)
	local InventoryFrame = ButtonsMain:FindFirstChild("Inventory")
	if not InventoryFrame then
		return
	end

	local Inner = InventoryFrame:FindFirstChild("Inventory")
	if not Inner then
		return
	end

	local AmountLabel = Inner:FindFirstChild("Amount") :: TextLabel?
	if not AmountLabel then
		return
	end

	local function Refresh()
		local Current = UIConstants.Data.CurrentInventorySpace()
		local Max = UIConstants.Data.MaxInventorySpace()

		AmountLabel.Text = Current .. "/" .. Max

		if Current >= Max then
			AmountLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
		else
			AmountLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
		end
	end

	UIConstants.Data.CurrentInventorySpace.Changed(Refresh)
	UIConstants.Data.MaxInventorySpace.Changed(Refresh)

	Refresh()
end

local function SetupHoverLabel(ButtonFrame: Instance)
	local Label = ButtonFrame:FindFirstChild("Label")
	if not Label or not (Label:IsA("GuiObject")) then
		return
	end

	Label.Visible = false

	ButtonFrame.MouseEnter:Connect(function()
		Label.Visible = true
	end)

	ButtonFrame.MouseLeave:Connect(function()
		Label.Visible = false
	end)
end

function Buttons.Init()
	local ButtonsMain = UIConstants.PlayerGui:WaitForChild("Buttons"):WaitForChild("Main")

	for name, ui in UIList do
		local ButtonFrame = ButtonsMain:FindFirstChild(name)
		if not ButtonFrame then
			continue
		end

		local Button = ButtonFrame:FindFirstChildOfClass("TextButton")
		if not Button then
			continue
		end

		Button.MouseButton1Click:Connect(function()
			if CurrentOpen == ui then
				SetVisible(ui, false)
				CurrentOpen = nil
				return
			end

			if CurrentOpen then
				SetVisible(CurrentOpen, false)
			end

			SetVisible(ui, true)
			CurrentOpen = ui
		end)

		SetupHoverLabel(ButtonFrame)
	end

	SetupHomeButton(ButtonsMain)
	UpdateInventoryAmountLabel(ButtonsMain)
end

return Buttons
