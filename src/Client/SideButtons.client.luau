local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local SideButtons = PlayerGui:WaitForChild("HUD").SideButtons

local function TeleportHome()
	local Character = Player.Character
	if not Character then
		return
	end

	local ZoneTPs = workspace:FindFirstChild("ZoneTPs")
	local LobbyTP = ZoneTPs and ZoneTPs:FindFirstChild("Lobby")

	if not LobbyTP then
		return
	end

	Character:PivotTo(LobbyTP.CFrame)
end

for _, Button: ImageButton in SideButtons:GetChildren() do
	if Button:IsA("ImageButton") then
		Button.MouseButton1Click:Connect(function()
			if Button.Name == "Home" then
				TeleportHome()
			else
				UIFunctions:OpenUI(Button.Name)
			end
		end)
	end
end
