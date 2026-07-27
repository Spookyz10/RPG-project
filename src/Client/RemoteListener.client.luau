local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local ClientRemoteListener = require(ReplicatedStorage.Shared.ClientRemoteListener)

RemoteManager.ListenToAllClient(ClientRemoteListener)
