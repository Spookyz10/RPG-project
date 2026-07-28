local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).client
local PlayerClass = require(ReplicatedStorage.Shared.PlayerClass)
local Logic = require(ReplicatedStorage.Shared.UI.Logic)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Player = Players.LocalPlayer

local Class = PlayerClass.getPlayerInfo(Player) :: Types.Entity
print(Class)

Class.OnHPChanged:Connect(function(newHp, _)
	Logic["Bars"].UpdateBar(newHp, Class.MaxHP, "HP")
end)

Class.OnMaxHPChanged:Connect(function(newHp, _)
	Logic["Bars"].UpdateBar(Class.HP, newHp, "HP")
end)

Data.XP.Changed(function(NewXp)
	Logic["Bars"].UpdateBar(NewXp, Functions:GetXPNeeded(Data.Level()), "XP")
end)

Logic["Bars"].UpdateBar(Class.HP, Class.MaxHP, "HP")
Logic["Bars"].UpdateBar(Data.XP(), Functions:GetXPNeeded(Data.Level()), "XP")
