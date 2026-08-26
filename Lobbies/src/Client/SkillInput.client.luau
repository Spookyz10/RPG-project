local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local SlotKeybinds = {
	[Enum.KeyCode.Q] = "Q",
	[Enum.KeyCode.E] = "E",
	[Enum.KeyCode.R] = "R",
}

local function getSlotButtons(slot: string): { GuiButton }
	local HUD = UIConstants.PlayerGui:WaitForChild("HUD")
	local buttons = {}

	local PCSlots = HUD:FindFirstChild("PCSlots")
	local MobileSlots = HUD:FindFirstChild("MobileSlots")

	if PCSlots then
		local button = PCSlots:FindFirstChild(slot)
		if button then
			table.insert(buttons, button)
		end
	end

	if MobileSlots then
		local button = MobileSlots:FindFirstChild(slot)
		if button then
			table.insert(buttons, button)
		end
	end

	return buttons
end

local function UseSkill(slot: string)
	RemoteManager.SendServerEvent("UseSkill", slot)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	local slot = SlotKeybinds[input.KeyCode]
	if not slot then
		return
	end

	UseSkill(slot)
end)

local function ConnectSlotButtons(slot: string)
	for _, button in getSlotButtons(slot) do
		button.MouseButton1Click:Connect(function()
			UseSkill(slot)
		end)
	end
end

for _, slot in SlotKeybinds do
	ConnectSlotButtons(slot)
end
