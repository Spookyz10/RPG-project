local RunService = game:GetService("RunService")
return function(ctx)
	local cf = ctx.Root.CFrame
	local distance, speed = 26, 30
	ctx.Indicator("Square", cf * CFrame.new(0, 0, -16), Vector3.new(8, 0.15, 32), 1.3)
	if not ctx.Pause(1.3) then
		return
	end
	ctx.VFX("AntlerRush", cf, 1.1, true, "AntlerRush")
	local seen, traveled = {}, 0
	while ctx.Active() and traveled < distance do
		local dt = RunService.Heartbeat:Wait()
		if not ctx.Active() then
			return
		end
		local step = math.min(dt * speed, distance - traveled)
		if
			workspace:Blockcast(ctx.Root.CFrame, Vector3.new(5, 4, 4), cf.LookVector * (step + 3), ctx.RaycastParams)
		then
			break
		end
		ctx.Hit(
			ctx.Root.CFrame * CFrame.new(0, 0, -step / 2 - 2),
			Vector3.new(8, 10, step + 6),
			nil,
			1.4,
			35,
			false,
			seen
		)
		traveled += step
		ctx.Root.CFrame = cf + cf.LookVector * traveled
	end
	-- Recovery leaves a punish window even after the charge meets a tree.
	ctx.Pause(0.9)
end
