local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local ALLOWED_USER_ID = 531376199
if Player.UserId ~= ALLOWED_USER_ID then return end

local UI = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("UI")
local Bootstrap = require(UI.Bootstrap)
local Windows = require(UI.WindowManager)
local Theme = require(UI.Theme)
local Items = require(ReplicatedStorage.Shared.ItemsData)
local Remotes = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local gui = Bootstrap.Ensure()
local body = gui.Main.Admin.Body.Content
local template = Bootstrap.GetTemplates().AdminItemTemplate
local selected
local selectedButton
gui.Buttons.Main.Drawer.Items.Admin.Visible = true

for itemId, info in Items do
	local button = template:Clone()
	button.Name = itemId
	button.Text = info.Data.Name
	button.Parent = body.ItemList
	button.Activated:Connect(function()
		if selectedButton then selectedButton.BackgroundColor3 = Theme.Soft end
		selected = itemId
		selectedButton = button
		button.BackgroundColor3 = Theme.Sky
	end)
end

body.Spawn.Activated:Connect(function()
	if selected then Remotes.SendServerEvent("SpawnItem", selected) end
end)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.F8 then Windows.Open("Main", true) end
end)
