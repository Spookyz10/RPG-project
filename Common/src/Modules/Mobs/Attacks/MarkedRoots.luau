local Players = game:GetService("Players")
return function(ctx)
	local targets = {}
	for _, player in Players:GetPlayers() do
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root and ctx.Alive(char) then
			local distance = (root.Position - ctx.Root.Position).Magnitude
			if distance <= 55 then
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
		ctx.Indicator("Circle", cf, Vector3.new(12, 0.15, 12), 1.6)
	end
	if #positions == 0 or not ctx.Pause(1.6) then
		return
	end
	local seen = {}
	for _, cf in positions do
		ctx.VFX("ElderRoots", cf, 0.8)
		ctx.Hit(cf, Vector3.new(12, 14, 12), 6, 1.2, nil, false, seen)
	end
end
