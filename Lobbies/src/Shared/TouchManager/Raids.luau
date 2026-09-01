local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Frame = PlayerGui:WaitForChild("RaidsGUI"):WaitForChild("Main")

local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Touch: Types.Touch = {}

function Touch.touchStarted()
	Frame.Visible = true
end

function Touch.touchEnded()
	Frame.Visible = false
end

return Touch
