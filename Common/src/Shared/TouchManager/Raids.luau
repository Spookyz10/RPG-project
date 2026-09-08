local UI = game:GetService("ReplicatedStorage").Shared.UI
local Bootstrap = require(UI.Bootstrap)
local Windows = require(UI.WindowManager)
local Touch = {}

function Touch.touchStarted()
    local gui = Bootstrap.Ensure()
    if not gui:GetAttribute("UIBlocking") then Windows.Open("RaidsGUI") end
end

function Touch.touchEnded()
    Windows.CloseScreen("RaidsGUI")
end

return Touch
