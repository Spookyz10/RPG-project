local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local ClientRemoteListener = require(ReplicatedStorage.Shared.ClientRemoteListener)

local TouchFunctions = require(ReplicatedStorage.Shared.Touched)


RemoteManager.ListenToAllClient(ClientRemoteListener)
