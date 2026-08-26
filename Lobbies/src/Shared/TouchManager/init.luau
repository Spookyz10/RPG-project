local Players = game:GetService("Players")

local TouchManager = {}

local Zones = {}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		Zones[module.Name] = require(module)
	end
end

local Player = Players.LocalPlayer
local MinRange = 0
local MaxRange = 10
local CHECK_INTERVAL = 0.1

local ActiveZones = {} :: { [BasePart]: boolean }
local Running = false

function TouchManager.Init()
	if Running then
		return
	end
	Running = true

	local TouchZones = workspace:WaitForChild("Touchies")

	task.spawn(function()
		while Running do
			local Character = Player.Character
			local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")

			if RootPart then
				for _, zone in TouchZones:GetChildren() do
					if not zone:IsA("BasePart") then
						continue
					end

					local Module = Zones[zone.Name]
					if not Module then
						continue
					end

					local DistanceSquared = (RootPart.Position - zone.Position).Magnitude ^ 2

					local Inside = DistanceSquared >= MinRange ^ 2 and DistanceSquared <= MaxRange ^ 2
					local WasActive = ActiveZones[zone]

					if Inside and not WasActive then
						ActiveZones[zone] = true
						if Module.touchStarted then
							Module.touchStarted()
						end
					elseif not Inside and WasActive then
						ActiveZones[zone] = nil
						if Module.touchEnded then
							Module.touchEnded()
						end
					end
				end
			end

			task.wait(CHECK_INTERVAL)
		end
	end)
end

return TouchManager
