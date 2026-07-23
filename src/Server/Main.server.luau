local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local AttackManager = require(ServerStorage.Modules.AttackManager)
local PlayerClass = require(ReplicatedStorage.Shared.PlayerClass)
local _MobHandler = require(ServerStorage.Modules.MobHandler)

local Remotes = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Server")
local AttackRemote = Remotes:FindFirstChild("Attack") :: RemoteEvent

AttackRemote.OnServerEvent:Connect(function(Player: Player)
	local class = PlayerClass.getPlayerInfo(Player)
	AttackManager:Swing(class)
end)
