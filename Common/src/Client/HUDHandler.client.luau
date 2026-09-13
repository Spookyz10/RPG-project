local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).client
local Logic = require(ReplicatedStorage.Shared.UI.Logic)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Abbreviation = require(ReplicatedStorage.Shared.Utils.Abbreviation)

local Player = Players.LocalPlayer
local Humanoid = nil :: Humanoid?
local HumanoidConnections: { RBXScriptConnection } = {}

local function UpdateHP(isInitial: boolean?)
	if not Humanoid then
		return
	end
	Logic["Bars"].UpdateBar(Humanoid.Health, Humanoid.MaxHealth, "HP", isInitial)
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

	table.insert(HumanoidConnections, Humanoid.HealthChanged:Connect(function()
		UpdateHP()
	end))
	for _, effect in require(ReplicatedStorage.Shared.StatusEffects) do
		if effect.Attribute and effect.HealthBar then
			table.insert(HumanoidConnections, character:GetAttributeChangedSignal(effect.Attribute):Connect(UpdateHP))
		end
	end
	table.insert(HumanoidConnections, Humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(UpdateHP))

	UpdateHP(true)
end

Data.XP.Changed(function(NewXp)
	Logic["Bars"].UpdateBar(NewXp, Functions:GetXPNeeded(Data.Level()), "XP")
end)

if Player.Character then
	BindHumanoid(Player.Character)
end

Player.CharacterAdded:Connect(BindHumanoid)

Logic["Bars"].UpdateBar(Data.XP(), Functions:GetXPNeeded(Data.Level()), "XP", true)

local function UpdateLevel(newLevel, previousLevel)
	local HUD = Player.PlayerGui.HUD.Main
	HUD.PlayerName.Text = Player.DisplayName
	HUD.Level.Text = "Lv. " .. Abbreviation:Number(Data.Level())
	Logic.Bars.UpdateBar(Data.XP(), Functions:GetXPNeeded(Data.Level()), "XP")
	if typeof(newLevel) == "number" and typeof(previousLevel) == "number" and newLevel > previousLevel then
		Logic.Bars.PlayLevelUp()
	end
end

Data.Level.Changed(UpdateLevel)
UpdateLevel()
