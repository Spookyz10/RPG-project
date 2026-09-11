local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Damage = require(script.Parent.Parent.DamageHandler)
local StatusEffects = require(script.Parent.Parent.StatusEffectManager)
local Behavior = require(script.Parent.BehaviorManager)
local BodyQuery = require(script.Parent.Parent.BodyQuery)
local Context = {}
local function alive(model)
 local hum = model and model:FindFirstChildOfClass("Humanoid")
 return model and model.Parent and hum and hum.Health > 0
end
function Context.new(mob, cfg, session)
 local root = mob:FindFirstChild("HumanoidRootPart")
	local function active() return alive(mob) and Behavior.Active[mob] == session end
	local function pause(seconds)
		local finish = os.clock() + seconds
		repeat RunService.Heartbeat:Wait() until not active() or os.clock() >= finish
		return active()
	end
	local exclude = RaycastParams.new()
	exclude.FilterType = Enum.RaycastFilterType.Exclude
	local excluded = { mob }
	for _, player in Players:GetPlayers() do
		if player.Character then table.insert(excluded, player.Character) end
	end
	exclude.FilterDescendantsInstances = excluded
	local function ground(cf)
		local result = workspace:Raycast(cf.Position + Vector3.new(0, 3, 0), Vector3.new(0, -60, 0), exclude)
		return CFrame.new(result and result.Position + Vector3.new(0, 0.08, 0) or cf.Position) * cf.Rotation
	end
	local function refreshFilter()
		local list = { mob }
		for _, player in Players:GetPlayers() do
			if player.Character then table.insert(list, player.Character) end
		end
		exclude.FilterDescendantsInstances = list
	end
	local function indicator(shape, cf, size, duration)
		Remote.SendClientEvent("Indicator", { All = true }, shape,
			{ Main = Color3.fromRGB(220, 55, 45), Display = Color3.fromRGB(255, 170, 60) },
			ground(cf), duration, size)
	end
	local function hit(cf, size, radius, multiplier, knockback, status, seen)
		if not active() then return end
		for char in BodyQuery.PlayersInVolume(cf, size, radius) do
			local part = char:FindFirstChild("HumanoidRootPart")
			if not part or not alive(char) or seen[char] or char:FindFirstChildOfClass("ForceField") then continue end
			-- Walls block damage, including cave walls and obstacles along a rush.
			if workspace:Raycast(root.Position, part.Position - root.Position, exclude) then continue end
			seen[char] = true
			local dealt = Damage:dealDamage(mob, char, multiplier)
			if dealt > 0 and alive(char) then
				if status then StatusEffects:Apply(char, status, { Source = mob }) end
				if knockback then
					local delta = (part.Position - root.Position) * Vector3.new(1, 0, 1)
					local direction = delta.Magnitude > 0.01 and delta.Unit or root.CFrame.LookVector
					part:ApplyImpulse((direction * knockback + Vector3.new(0, 12, 0)) * part.AssemblyMass)
				end
			end
		end
	end
	local function vfx(name, cf, duration, follow, attack)
  if name == "Melee" then name = mob.Name .. "Melee" end
  Remote.SendClientEvent("CombatVFX", { All = true }, "Attacks", name, cf, mob, duration, follow, attack)
 end
 local function circle(radius, windup, multiplier, knockback, effect)
		local cf = root.CFrame
		indicator("Circle", cf, Vector3.new(radius * 2, 0.15, radius * 2), windup)
		if pause(windup) then
   if effect then vfx(effect, ground(cf)) end
   hit(cf, Vector3.new(radius * 2, 16, radius * 2), radius, multiplier, knockback, false, {})
  end
	end
 return { Mob = mob, Root = root, Config = cfg, Active = active, Pause = pause,
 Ground = ground, Indicator = indicator, Hit = hit, Circle = circle, VFX = vfx,
 RefreshFilter = refreshFilter, RaycastParams = exclude, Alive = alive }
end
return Context
