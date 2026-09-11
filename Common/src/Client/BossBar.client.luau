local player = game:GetService("Players").LocalPlayer
local mobs = workspace:WaitForChild("Mobs")
local gui = player:WaitForChild("PlayerGui"):WaitForChild("BossBar", 30)
if not gui then warn("Run the BossBar Edit generator before Play."); return end
local panel = gui.Main
while gui.Parent do
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local nearest, distance = nil, 160
	if root then
		for _, mob in mobs:GetChildren() do
			local hum = mob:FindFirstChildOfClass("Humanoid")
			local body = mob:FindFirstChild("HumanoidRootPart")
			if (mob.Name == "Dire Bear" or mob:GetAttribute("IsBoss")) and hum and hum.Health > 0 and body then
				local d = (root.Position - body.Position).Magnitude
				if d < distance then nearest = mob; distance = d end
			end
		end
	end
	panel.Visible = nearest ~= nil
	if nearest then
		local hum = nearest:FindFirstChildOfClass("Humanoid")
		panel.Title.Text = nearest.Name .. "  •  Lv. " .. tostring(nearest:GetAttribute("Level") or 15)
		panel.Track.Fill.Size = UDim2.fromScale(math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1), 1)
		panel.Health.Text = math.ceil(hum.Health) .. " / " .. math.ceil(hum.MaxHealth)
	end
	task.wait(0.05)
end
