local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local TouchManager = {}

local Zones = {}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		Zones[module.Name] = require(module)
	end
end

function TouchManager.Init()
	task.spawn(function()
		RunService.RenderStepped:Connect(function()
			local Character = Players.LocalPlayer.Character

			if not Character then
				return
			end

			local RootPart = Character:FindFirstChild("HumanoidRootPart")

			if not RootPart then
				return
			end

			for _, zonePart: BasePart in workspace.Touchies:GetChildren() do
				if zonePart:IsA("BasePart") then
					local distance = (RootPart.Position - zonePart.Position).Magnitude
					if Zones[zonePart.Name] then
						if distance < 10 then
							Zones[zonePart.Name].touchStarted()
						else
							Zones[zonePart.Name].touchEnded()
						end
					end
				end
			end
		end)
	end)
end

return TouchManager
