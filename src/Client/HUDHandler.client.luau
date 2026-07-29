local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).client
local Logic = require(ReplicatedStorage.Shared.UI.Logic)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)

local Player = Players.LocalPlayer

local function UpdateHP()
	local HP = Player:GetAttribute("HP") or 0
	local MaxHP = Player:GetAttribute("MaxHP") or 1
	Logic["Bars"].UpdateBar(HP, MaxHP, "HP")
end

Player:GetAttributeChangedSignal("HP"):Connect(UpdateHP)
Player:GetAttributeChangedSignal("MaxHP"):Connect(UpdateHP)

Data.XP.Changed(function(NewXp)
	Logic["Bars"].UpdateBar(NewXp, Functions:GetXPNeeded(Data.Level()), "XP")
end)

UpdateHP()
Logic["Bars"].UpdateBar(Data.XP(), Functions:GetXPNeeded(Data.Level()), "XP")
