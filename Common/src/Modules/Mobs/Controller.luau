local Players = game:GetService("Players")
local Behavior = require(script.Parent.BehaviorManager)
local CombatContext = require(script.Parent.CombatContext)
local Pursuit = require(script.Parent.Pursuit)
local Facing = require(script.Parent.Facing)
local Controller = {}
function Controller:Start(mob, definition)
 if Behavior.Active[mob] then return end
 local root = mob:FindFirstChild("HumanoidRootPart")
 local hum = mob:FindFirstChildOfClass("Humanoid")
 if not root or not hum or hum.Health <= 0 then return end
 local cfg = definition.Config
 local session = {}
 Behavior.Active[mob] = session
 local ctx = CombatContext.new(mob, cfg, session)
 local pursuit = Pursuit.new(mob, cfg)
 local facing = Facing.new(root, cfg)
 local spawn = mob:FindFirstChild("SpawnOrigin")
 local origin = spawn and spawn.Value and spawn.Value.Position or root.Position
 local regions = workspace:FindFirstChild("ZoneRegions")
 local arena = cfg.ArenaRegion and regions and regions:FindFirstChild(cfg.ArenaRegion)
 local function inside(position)
  if not arena then return true end
  local p = arena.CFrame:PointToObjectSpace(position)
  local half = arena.Size / 2
  return math.abs(p.X) <= half.X and math.abs(p.Y) <= half.Y and math.abs(p.Z) <= half.Z
 end
 local function attack(spec)
  if spec.FreeRotation then facing:Release() end
  mob:SetAttribute("Attack", spec.Name)
  spec.Execute(ctx, spec)
  mob:SetAttribute("Attack", nil)
 end
	local nextBasic, nextSkill = 0, os.clock() + 2
	local bossIndex = mob:GetAttribute("SkillSequence") or 0
	local ok, err = xpcall(function()
		while ctx.Active() do
			ctx.RefreshFilter()
			local target, distance = nil, arena and math.huge or cfg.AggroRange or 50
			for _, player in Players:GetPlayers() do
				local char = player.Character
				local part = char and char:FindFirstChild("HumanoidRootPart")
				if part and ctx.Alive(char) and inside(part.Position) then
					local d = (part.Position - root.Position).Magnitude
					if d < distance then target, distance = part, d end
				end
			end
			if not target or (arena and not inside(root.Position)) or (not arena and (root.Position - origin).Magnitude > (cfg.LeashDistance or 65)) then
				Behavior:Reset(mob)
				break
			end
			facing:Release()
			local inMeleeRange = pursuit:Update(target)
			ctx.MeleeReach = pursuit.MeleeReach
			local skill = #definition.Skills > 0 and distance <= cfg.SkillRange and os.clock() >= nextSkill
			if skill or inMeleeRange then
				pursuit:Stop()
				hum.AutoRotate = false
				local aligned = facing:Towards(target.Position)
				-- Telegraph only after turning: its locked direction must match the attack.
				if not aligned then
					ctx.Pause(0.05)
					continue
				end
				if skill then
					bossIndex = bossIndex % #definition.Skills + 1
					mob:SetAttribute("SkillSequence", bossIndex)
					attack(definition.Skills[bossIndex])
					nextSkill = os.clock() + cfg.SkillCooldown
					nextBasic = math.min(nextBasic, os.clock() + 0.15)
				elseif os.clock() >= nextBasic then
					nextBasic = os.clock() + cfg.BasicCooldown
					attack(definition.Basic)
				end
			end
			ctx.Pause(0.1)
		end
	end, debug.traceback)
	facing:Destroy()
	if Behavior.Active[mob] == session then Behavior.Active[mob] = nil end
	if mob.Parent and not Behavior.Active[mob] then
		mob:SetAttribute("Attack", nil)
		hum.AutoRotate = true
		hum.WalkSpeed = cfg.Speed
	end
	if not ok then warn(err) end
end

return Controller
