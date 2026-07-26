local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player  = Players.LocalPlayer
local PlayerGui = Player:FindFirstChild("PlayerGui")
local ZonesUI = PlayerGui:WaitForChild("Zones").Main

local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Touch : Types.Touch = {}

function Touch.touchStarted()
    ZonesUI.Visible = true
end

function Touch.touchEnded()
    ZonesUI.Visible = false
end

return Touch