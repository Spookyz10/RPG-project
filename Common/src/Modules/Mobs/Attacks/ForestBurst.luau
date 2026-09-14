return function(ctx, spec)
	local cf = ctx.Ground(ctx.Root.CFrame)
	local radius = spec.Radius or 7
	local windup = spec.Windup or 1.2
	local pulses = spec.Pulses or 1
	local gap = 0.8
	-- Both circles are announced up front and stay at the original position.
	for i = 1, pulses do
		local r = radius + (i - 1) * 3
		ctx.Indicator("Circle", cf, Vector3.new(r * 2, 0.15, r * 2), windup + (i - 1) * gap)
	end
	if not ctx.Pause(windup) then
		return
	end
	local seen = {}
	for i = 1, pulses do
		if not ctx.Active() then
			return
		end
		local r = radius + (i - 1) * 3
		ctx.VFX(i == 2 and "SporeEcho" or spec.Effect, cf, 0.7)
		ctx.Hit(cf, Vector3.new(r * 2, 12, r * 2), r, spec.Multiplier or 1.2, spec.Knockback, false, seen)
		if i < pulses and not ctx.Pause(gap) then
			return
		end
	end
end
