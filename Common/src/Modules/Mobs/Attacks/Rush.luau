local RunService = game:GetService("RunService")
return function(ctx)
	local root, active, exclude = ctx.Root, ctx.Active, ctx.RaycastParams
	local indicator, pause, hit = ctx.Indicator, ctx.Pause, ctx.Hit
	local cf = root.CFrame
	local previous = ctx.Mob:GetAttribute("RushIndicatorStyle")
	local style = if previous == "Line" then "Square" else "Line"
	ctx.Mob:SetAttribute("RushIndicatorStyle", style)
	indicator(style, cf * CFrame.new(0, 0, -18), Vector3.new(7, 0.15, 36), 1.1)
	if pause(1.1) then
		ctx.VFX("Rush", root.CFrame, 0.95, true, "Rush")
		local seen, traveled = {}, 0
		while active() and traveled < 32 do
			local dt = RunService.Heartbeat:Wait()
			if not active() then break end
			local step = math.min(dt * 38, 32 - traveled)
			if workspace:Blockcast(root.CFrame, Vector3.new(6, 5, 4), cf.LookVector * (step + 3), exclude) then break end
			hit(root.CFrame * CFrame.new(0, 0, -step / 2 - 2), Vector3.new(7, 8, step + 6), nil, 1.6, 45, false, seen)
			traveled += step
			root.CFrame = cf + cf.LookVector * traveled
		end
	end
end
