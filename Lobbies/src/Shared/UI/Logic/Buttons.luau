local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local Buttons = {}

local UIList = {
	Inventory = UIConstants.PlayerGui:WaitForChild("Inventory").Main,
}

local CurrentOpen: Instance? = nil

local function SetVisible(ui: Instance, value: boolean)
	if ui:IsA("ScreenGui") then
		ui.Enabled = value
	elseif ui:IsA("GuiObject") then
		ui.Visible = value
	end
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
	end
end

return Buttons
