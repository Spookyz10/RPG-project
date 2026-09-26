local Players = game:GetService("Players")
return function(ctx, spec)
	spec = spec or {}
	local radius = spec.Radius or 6
	local windup = spec.Windup or 1.6
	for _ = 1, spec.Waves or 1 do
		if not ctx.Active() then return end
		local targets = {}
		for _, player in Players:GetPlayers() do
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root and ctx.Alive(char) then
				local distance = (root.Position - ctx.Root.Position).Magnitude
				if distance <= (spec.Range or 55) then
					table.insert(targets, { Distance = distance, Position = root.Position, ID = player.UserId })
				end
			end
		end
		table.sort(targets, function(a, b)
			return a.Distance == b.Distance and a.ID < b.ID or a.Distance < b.Distance
		end)
		local positions = {}
		for i = 1, math.min(3, #targets) do
			local cf = ctx.Ground(CFrame.new(targets[i].Position))
			table.insert(positions, cf)
			ctx.Indicator("Circle", cf, Vector3.new(radius * 2, 0.15, radius * 2), windup)
		end
		if #positions == 0 or not ctx.Pause(windup) then
			return
		end
		local seen = {}
		for _, cf in positions do
			ctx.VFX("ElderRoots", cf, 0.8)
			ctx.Hit(cf, Vector3.new(radius * 2, 14, radius * 2), radius, spec.Multiplier or 1.2, nil, false, seen)
		end
	end
end
