local Players = game:GetService("Players")
return function(ctx)
	local root, alive = ctx.Root, ctx.Alive
	local ground, indicator, pause, hit = ctx.Ground, ctx.Indicator, ctx.Pause, ctx.Hit
	local positions = {}
	for _, player in Players:GetPlayers() do
		local char = player.Character
		local part = char and char:FindFirstChild("HumanoidRootPart")
		if part and alive(char) and (part.Position - root.Position).Magnitude <= 30 then
			local cf = ground(CFrame.new(part.Position))
			table.insert(positions, cf + Vector3.new(0, 3, 0))
			indicator("Circle", cf, Vector3.new(6, 0.15, 6), 1.2)
		end
	end
	if pause(1.2) then
		local seen = {}
		for _, cf in positions do hit(cf, Vector3.new(6, 8, 6), 3, 1.2, nil, "Poison", seen) end
	end
end
