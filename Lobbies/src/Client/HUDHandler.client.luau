local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).client
local Logic = require(ReplicatedStorage.Shared.UI.Logic)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)

local Player = Players.LocalPlayer
local Humanoid = nil :: Humanoid

local function UpdateHP()
	local HP = Humanoid.Health
	local MaxHP = Humanoid.MaxHealth
	Logic["Bars"].UpdateBar(HP, MaxHP, "HP")
end

Player:GetAttributeChangedSignal("HP"):Connect(UpdateHP)
Player:GetAttributeChangedSignal("MaxHP"):Connect(UpdateHP)

Data.XP.Changed(function(NewXp)
	Logic["Bars"].UpdateBar(NewXp, Functions:GetXPNeeded(Data.Level()), "XP")
end)

if Player.Character then
	if Player.Character:FindFirstChild("Humanoid") then
		Humanoid = Player.Character:FindFirstChild("Humanoid")
	end
end

Player.CharacterAdded:Connect(function()
	local hum = Player.Character:WaitForChild("Humanoid")
	Humanoid = hum
end)

UpdateHP()
Logic["Bars"].UpdateBar(Data.XP(), Functions:GetXPNeeded(Data.Level()), "XP")
