local RunService = game:GetService("RunService")
return function(ctx)
	local root, active = ctx.Root, ctx.Active
	local indicator, pause, hit = ctx.Indicator, ctx.Pause, ctx.Hit
	local cf = root.CFrame
	indicator("Circle", cf, Vector3.new(20, 0.15, 20), 0.8)
	if pause(0.8) then
		local seen, started = {}, os.clock()
		while active() and os.clock() - started < 2 do
			root.CFrame = cf * CFrame.Angles(0, (os.clock() - started) * math.pi * 4, 0)
			hit(cf, Vector3.new(20, 8, 20), 10, 1.25, 65, false, seen)
			RunService.Heartbeat:Wait()
		end
	end
end
