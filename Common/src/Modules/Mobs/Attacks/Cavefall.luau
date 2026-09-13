local RunService = game:GetService("RunService")

return function(ctx)
	local root, ground, indicator, pause, hit = ctx.Root, ctx.Ground, ctx.Indicator, ctx.Pause, ctx.Hit
	local ends = os.clock() + 4
	while ctx.Active() and os.clock() < ends do
		local angle, radius = math.random() * math.pi * 2, math.random(5, 22)
		local point = root.Position + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local landing = ground(CFrame.new(point))
		indicator("Circle", landing, Vector3.new(7, 0.15, 7), 0.8)
		ctx.VFX("CavefallWarning", landing, 0.8)
		if not pause(0.8) then return end
		ctx.VFX("CavefallImpact", landing, 0.8)
		hit(landing, Vector3.new(7, 10, 7), 3.5, 1.35, 35, false, {})
		if not pause(0.18) then return end
	end
end
