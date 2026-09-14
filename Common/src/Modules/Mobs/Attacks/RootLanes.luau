return function(ctx)
	local basis = ctx.Root.CFrame
	local lanes = { basis * CFrame.new(-6, 0, -14), basis * CFrame.new(6, 0, -14) }
	-- Alternating halves leave a safe side; first lane becomes safe before the second hits.
	for i, cf in lanes do
		ctx.Indicator("Square", cf, Vector3.new(10, 0.15, 28), 1.1 + (i - 1) * 0.7)
	end
	if not ctx.Pause(1.1) then
		return
	end
	for i, cf in lanes do
		if not ctx.Active() then
			return
		end
		ctx.VFX("SentinelRoots", ctx.Ground(cf), 0.65)
		ctx.Hit(cf, Vector3.new(10, 12, 28), nil, 0.8, nil, false, {})
		if i == 1 and not ctx.Pause(0.7) then
			return
		end
	end
end
