local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

return function(ctx)
	local root, indicator, pause, hit = ctx.Root, ctx.Indicator, ctx.Pause, ctx.Hit
	local choices = {}
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local part = character and character:FindFirstChild("HumanoidRootPart")
		if part and ctx.Alive(character) then table.insert(choices, part) end
	end
	local target = choices[math.random(1, math.max(1, #choices))]
	if not target then return end
	local landing = ctx.Ground(CFrame.new(target.Position))
	indicator("Circle", landing, Vector3.new(14, 0.15, 14), 3)
	ctx.VFX("DireBearJumpWarning", landing, 3)
	local started = os.clock()
	while ctx.Active() and os.clock() - started < 3 do
		local delta = target.Position - root.Position
		if delta.Magnitude > 0.1 then root.CFrame = CFrame.lookAt(root.Position, Vector3.new(target.Position.X, root.Position.Y, target.Position.Z)) end
		RunService.Heartbeat:Wait()
	end
	if not ctx.Active() then return end
	root.CFrame = landing * CFrame.new(0, 1.5, 0)
	ctx.VFX("DireBearJumpImpact", landing, 1)
	hit(landing, Vector3.new(14, 10, 14), 7, 2, 80, false, {})
end
