local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local MobHandler = require(ServerStorage.Modules.MobHandler)
local ServerRemoteListener = require(ServerStorage.Modules.ServerRemoteListener)

RemoteManager.ListenToAll(ServerRemoteListener)

MobHandler:InitializeSpawns()
