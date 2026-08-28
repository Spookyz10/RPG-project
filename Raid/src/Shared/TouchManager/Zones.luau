local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local ZoneFrame = PlayerGui:WaitForChild("ZoneSelector"):WaitForChild("Main")

local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Touch: Types.Touch = {}

function Touch.touchStarted()
	ZoneFrame.Visible = true
end

function Touch.touchEnded()
	ZoneFrame.Visible = false
end

return Touch
