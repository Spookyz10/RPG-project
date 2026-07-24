local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local AttackManager = require(ServerStorage.Modules.AttackManager)
local PlayerClass = require(ReplicatedStorage.Shared.PlayerClass)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local _MobHandler = require(ServerStorage.Modules.MobHandler)

RemoteManager.GetRemote("Attack", "Server").OnServerEvent:Connect(function(Player: Player)
	local class = PlayerClass.getPlayerInfo(Player)
	AttackManager:Swing(class)
end)
