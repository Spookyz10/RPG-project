local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local DeathScreen = {}
local aliveToken = 0

function DeathScreen.Init()
	local screen = UIConstants.PlayerGui:WaitForChild("DeathScreen")
	screen.Enabled = false
	screen.Veil.Panel.RespawnNow.Activated:Connect(function()
		RemoteManager.SendServerEvent("RespawnNow")
	end)
	local function bind(character)
		aliveToken += 1
		local token = aliveToken
		screen.Enabled = false
		local humanoid = character:WaitForChild("Humanoid") :: Humanoid
		humanoid.Died:Connect(function()
			if token ~= aliveToken then return end
			screen.Enabled = true
			for remaining = 6, 1, -1 do
				if token ~= aliveToken or not screen.Enabled then return end
				screen.Veil.Panel.Timer.Text = "You will respawn in " .. remaining .. " second" .. (remaining == 1 and "" or "s")
				task.wait(1)
			end
		end)
	end
	Players.LocalPlayer.CharacterAdded:Connect(bind)
	if Players.LocalPlayer.Character then bind(Players.LocalPlayer.Character) end
end

return DeathScreen
