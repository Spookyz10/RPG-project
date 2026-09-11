local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer
local Access = require(ReplicatedStorage.Shared.AdminAccess)
if not Access[Player.UserId] then
	Player:WaitForChild("PlayerGui"):WaitForChild("Main").Enabled = false
	return
end

local UI = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("UI")
local Bootstrap = require(UI.Bootstrap)
local Windows = require(UI.WindowManager)
local Theme = require(UI.Theme)
local Items = require(ReplicatedStorage.Shared.ItemsData)
local Remotes = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local gui = Bootstrap.Ensure()
gui.Main.Enabled = true
local body = gui.Main.Admin.Body.Content
local template = Bootstrap.GetTemplates().AdminItemTemplate
local selected
local selectedButton
local target = Player
gui.Buttons.Main.Drawer.Items.Admin.Visible = true
gui.Main.AdminLauncher.Visible = true
gui.Main.AdminLauncher.Activated:Connect(function() Windows.Open("Main", true) end)
local function refreshTarget()
	body.Target.Text = target.DisplayName .. " (@" .. target.Name .. ") • click to change"
end
refreshTarget()
body.Target.Activated:Connect(function()
	local list = Players:GetPlayers()
	table.sort(list, function(a,b) return a.Name < b.Name end)
	target = list[((table.find(list, target) or 0) % #list) + 1]
	refreshTarget()
end)
Players.PlayerRemoving:Connect(function(leaving) if target == leaving then target = Player; refreshTarget() end end)

for itemId, info in Items do
	local button = template:Clone()
	button.Name = itemId
	button.Text = info.Data.Name
	button.Visible = true
	button.Parent = body.ItemList
	button.Activated:Connect(function()
		if selectedButton then selectedButton.BackgroundColor3 = Theme.Soft end
		selected = itemId
		body.Selected.Text = "Selected: " .. info.Data.Name
		selectedButton = button
		button.BackgroundColor3 = Theme.Sky
	end)
end

body.Search:GetPropertyChangedSignal("Text"):Connect(function()
	for _, button in body.ItemList:GetChildren() do
		if button:IsA("GuiButton") then button.Visible = string.find(string.lower(button.Text), string.lower(body.Search.Text), 1, true) ~= nil end
	end
end)
for _, method in {"GiveItem", "GiveGold", "UpdateLevel", "Heal", "GoTo", "Bring"} do
	body[method].Activated:Connect(function()
		if method == "GiveItem" and not selected then body.Status.Text = "Select an item first."; return end
		body.Status.Text = "Sending action for " .. target.Name .. "..."
		Remotes.SendServerEvent("Admin", method, target, tonumber(body.Value.Text), selected)
	end)
end
