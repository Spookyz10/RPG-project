-- Each stage shares a hit set: overlapping volumes never multiply its damage.
return function(ctx, spec)
	local basis = ctx.Ground(ctx.Root.CFrame)
	local stages = {}
	if spec.Pattern == "Fan" then
		for wave = 1, 2 do
			local zones = {}
			for lane = -2, 2 do
				local cf = basis * CFrame.Angles(0, math.rad(lane * 30 + (wave == 2 and 15 or 0)), 0)
				table.insert(zones, { CF = cf * CFrame.new(0, 0, -36), Size = Vector3.new(9, 16, 72) })
			end
			table.insert(stages, zones)
		end
	elseif spec.Pattern == "Rupture" then
		for wave = 1, 2 do
			local zones = {}
			for spoke = 0, 7 do
				local angle = spoke * math.pi / 4 + (wave - 1) * math.pi / 8
				local offset = Vector3.new(math.sin(angle), 0, math.cos(angle)) * (wave == 1 and 22 or 38)
				table.insert(zones, { CF = basis + offset, Size = Vector3.new(22, 16, 22), Radius = 11 })
			end
			table.insert(stages, zones)
		end
	else
		for wave = 1, 4 do
			table.insert(stages, {{ CF = basis * CFrame.new(0, 0, -wave * 18), Size = Vector3.new(44, 16, 18) }})
		end
	end
	for _, zones in stages do
		if not ctx.Active() then return end
		for _, zone in zones do
			zone.CF = ctx.Ground(zone.CF)
			ctx.Indicator(zone.Radius and "Circle" or "Square", zone.CF,
				Vector3.new(zone.Size.X, 0.15, zone.Size.Z), spec.Windup)
		end
		if not ctx.Pause(spec.Windup) then return end
		local seen = {}
		for _, zone in zones do
			ctx.VFX(spec.Name, zone.CF, 0.65)
			ctx.Hit(zone.CF, zone.Size, zone.Radius, spec.Multiplier, nil, false, seen)
		end
		if not ctx.Pause(0.12) then return end
	end
end
