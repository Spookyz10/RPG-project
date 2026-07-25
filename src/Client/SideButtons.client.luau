local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local SideButtons = PlayerGui:WaitForChild("HUD").SideButtons

for _, Button: ImageButton in SideButtons:GetChildren() do
	if Button:IsA("ImageButton") then
		Button.MouseButton1Click:Connect(function()
			UIFunctions:OpenUI(Button.Name)
		end)
	end
end
