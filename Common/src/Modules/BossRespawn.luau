local RS = game:GetService("ReplicatedStorage")
local BossRespawn = {}

function BossRespawn.Start(origin: BasePart, duration: number)
	local deadline = workspace:GetServerTimeNow() + duration
	origin:SetAttribute("RespawnAt", deadline)
	local folder = workspace:FindFirstChild("BossRespawns")
	local marker = folder and folder:FindFirstChild(origin.Name, true)
	local templates = RS:FindFirstChild("RPGUITemplates")
	local template = templates and templates:FindFirstChild("BossRespawn")
	local gui
	if marker and marker:IsA("BasePart") and template then
		gui = template:Clone()
		gui.Adornee = marker
		gui.Parent = marker
	end
	task.spawn(function()
		while origin.Parent and workspace:GetServerTimeNow() < deadline do
			if gui then gui.Countdown.Text = origin.Name .. "\nRespawns in " .. math.ceil(deadline - workspace:GetServerTimeNow()) .. "s" end
			task.wait(0.1)
		end
		if gui then gui:Destroy() end
	end)
end

return BossRespawn
