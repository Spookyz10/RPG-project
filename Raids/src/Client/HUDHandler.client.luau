local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).client
local Logic = require(ReplicatedStorage.Shared.UI.Logic)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)

local Player = Players.LocalPlayer
local Humanoid = nil :: Humanoid?
local HumanoidConnections: { RBXScriptConnection } = {}

local function UpdateHP()
	if not Humanoid then
		return
	end
	Logic["Bars"].UpdateBar(Humanoid.Health, Humanoid.MaxHealth, "HP")
end

local function DisconnectHumanoidSignals()
	for _, connection in HumanoidConnections do
		connection:Disconnect()
	end
	HumanoidConnections = {}
end

local function BindHumanoid(character: Model)
	local newHumanoid = character:WaitForChild("Humanoid") :: Humanoid

	DisconnectHumanoidSignals()
	Humanoid = newHumanoid

	table.insert(HumanoidConnections, Humanoid.HealthChanged:Connect(UpdateHP))
	table.insert(HumanoidConnections, Humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(UpdateHP))

	UpdateHP()
end

Data.XP.Changed(function(NewXp)
	Logic["Bars"].UpdateBar(NewXp, Functions:GetXPNeeded(Data.Level()), "XP")
end)

if Player.Character then
	BindHumanoid(Player.Character)
end

Player.CharacterAdded:Connect(BindHumanoid)

Logic["Bars"].UpdateBar(Data.XP(), Functions:GetXPNeeded(Data.Level()), "XP")
