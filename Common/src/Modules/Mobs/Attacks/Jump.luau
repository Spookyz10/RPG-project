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

	indicator("Circle", landing, Vector3.new(14, 0.15, 14), WARNING_DURATION)
	ctx.VFX("DireBearJumpWarning", landing, WARNING_DURATION)
	while ctx.Active() and os.clock() < jumpsAt do
		faceLanding()
		local velocity = root.AssemblyLinearVelocity
		root.AssemblyLinearVelocity = Vector3.new(0, velocity.Y, 0)
		root.AssemblyAngularVelocity = Vector3.zero
		RunService.Heartbeat:Wait()
	end
	if not ctx.Active() then return end

	faceLanding()
	local flightTime = math.max(finishesAt - os.clock(), 0.1)
	local displacement = landingPosition - root.Position
	local gravity = workspace.Gravity
	local humanoid = ctx.Mob:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
	root.AssemblyLinearVelocity = Vector3.new(
		displacement.X / flightTime,
		(displacement.Y + 0.5 * gravity * flightTime * flightTime) / flightTime,
		displacement.Z / flightTime
	)

	while ctx.Active() and os.clock() < finishesAt do
		RunService.Heartbeat:Wait()
	end
	if not ctx.Active() then return end

	local landingDirection = root.CFrame.LookVector * Vector3.new(1, 0, 1)
	root.CFrame = if landingDirection.Magnitude > 0.01
		then CFrame.lookAt(landingPosition, landingPosition + landingDirection.Unit)
		else CFrame.new(landingPosition)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	ctx.VFX("DireBearJumpImpact", landing, 1)
	hit(landing, Vector3.new(14, 10, 14), 7, 2, 80, false, {})
end
