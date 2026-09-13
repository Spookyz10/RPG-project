local RunService = game:GetService("RunService")

local WARNING_DURATION = 0.82
local WAVE_DURATION = 4.2
local STRIKE_INTERVAL = 0.16
local STRIKE_DIAMETER = 14

local function cavePoint(root: BasePart): Vector3
	local floor = workspace:FindFirstChild("CaveFloor")
	if floor and floor:IsA("BasePart") then
		local inset = 0.92
		local x = (math.random() - 0.5) * floor.Size.X * inset
		local z = (math.random() - 0.5) * floor.Size.Z * inset
		return floor.CFrame:PointToWorldSpace(Vector3.new(x, floor.Size.Y * 0.5 + 8, z))
	end
	local angle, radius = math.random() * math.pi * 2, math.random(5, 28)
	return root.Position + Vector3.new(math.cos(angle) * radius, 8, math.sin(angle) * radius)
end

return function(ctx)
	local root, ground, indicator, pause, hit = ctx.Root, ctx.Ground, ctx.Indicator, ctx.Pause, ctx.Hit
	local ends = os.clock() + WAVE_DURATION
	while ctx.Active() and os.clock() < ends do
		local landing = ground(CFrame.new(cavePoint(root)))
		indicator("Circle", landing, Vector3.new(STRIKE_DIAMETER, 0.15, STRIKE_DIAMETER), WARNING_DURATION)
		task.spawn(function()
			if not pause(WARNING_DURATION) then return end
			ctx.VFX("CavefallImpact", landing, 0.8)
			hit(landing, Vector3.new(STRIKE_DIAMETER, 12, STRIKE_DIAMETER), STRIKE_DIAMETER * 0.5, 1.15, 42, false, {}, true)
		end)
		if not pause(STRIKE_INTERVAL) then return end
	end
	if ctx.Active() then
		local finish = os.clock() + WARNING_DURATION
		repeat RunService.Heartbeat:Wait() until not ctx.Active() or os.clock() >= finish
	end
end
