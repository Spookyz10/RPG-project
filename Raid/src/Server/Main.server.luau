local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local ServerRemoteListener = require(ServerStorage.Modules.ServerRemoteListener)

RemoteManager.ListenToAll(ServerRemoteListener)
RemoteManager.ListenToAllFunctions(ServerRemoteListener)
