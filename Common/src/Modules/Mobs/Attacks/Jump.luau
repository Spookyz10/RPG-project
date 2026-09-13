local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local WARNING_DURATION = 3
local JUMP_DURATION = 0.65

return function(ctx)
	local root, indicator, hit = ctx.Root, ctx.Indicator, ctx.Hit
	local choices = {}
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local part = character and character:FindFirstChild("HumanoidRootPart")
		if part and ctx.Alive(character) then table.insert(choices, part) end
	end
	local target = choices[math.random(1, math.max(1, #choices))]
	if not target then return end
	local landing = ctx.Ground(CFrame.new(target.Position))
	local startGround = ctx.Ground(CFrame.new(root.Position))
	local standingHeight = math.max(root.Size.Y * 0.5, root.Position.Y - startGround.Position.Y)
	local landingPosition = landing.Position + Vector3.new(0, standingHeight, 0)
	local finishesAt = os.clock() + WARNING_DURATION
	local jumpsAt = finishesAt - JUMP_DURATION

	local function faceLanding()
		local position = root.Position
		local lookAt = Vector3.new(landingPosition.X, position.Y, landingPosition.Z)
		if (lookAt - position).Magnitude > 0.1 then
			root.CFrame = CFrame.lookAt(position, lookAt)
		end
	end

	indicator("Circle", landing, Vector3.new(22, 0.15, 22), WARNING_DURATION)
	while ctx.Active() and os.clock() < jumpsAt do
		faceLanding()
		local velocity = root.AssemblyLinearVelocity
		root.AssemblyLinearVelocity = Vector3.new(0, velocity.Y, 0)
		root.AssemblyAngularVelocity = Vector3.zero
		RunService.Heartbeat:Wait()
	end
	if not ctx.Active() then return end

	faceLanding()
	local jumpStart = root.Position
	local horizontal = (landingPosition - jumpStart) * Vector3.new(1, 0, 1)
	local jumpDirection = horizontal.Magnitude > 0.01 and horizontal.Unit or root.CFrame.LookVector
	local arcHeight = math.max(12, horizontal.Magnitude * 0.18)
	local humanoid = ctx.Mob:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end

	-- Use a server-driven arc rather than a launch velocity. Physics collisions
	-- can otherwise stop the bear mid-air, leaving the final correction looking
	-- like a teleport when the indicator finishes.
	while ctx.Active() do
		local progress = math.clamp((os.clock() - jumpsAt) / JUMP_DURATION, 0, 1)
		local position = jumpStart:Lerp(landingPosition, progress)
		position += Vector3.new(0, arcHeight * 4 * progress * (1 - progress), 0)
		root.CFrame = CFrame.lookAt(position, position + jumpDirection)
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		if progress >= 1 then break end
		RunService.Heartbeat:Wait()
	end
	if not ctx.Active() then return end

	root.CFrame = CFrame.lookAt(landingPosition, landingPosition + jumpDirection)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	ctx.VFX("DireBearJumpImpact", landing, 1)
	-- Ground impacts must match the warning even when cave geometry blocks the
	-- boss's line of sight to a player standing in the marked area.
	hit(landing, Vector3.new(22, 14, 22), 11, 2, 80, false, {}, true)
end
