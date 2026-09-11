local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Modules = game:GetService("ServerStorage").Modules
local Manager = require(Modules.StatusEffectManager)
local Events = require(Modules.EventBus)
local Remote = require(RS.Shared.Utils.RemoteManager)
local CollectionService = game:GetService("CollectionService")
local statusKeys = {Poison = "Poison", Venom = "Venom", Fury = "Fury", ["Lure Jab"] = "LureJab", Safeguard = "Safeguard"}
local function impact(name, target)
 local root = target and target:FindFirstChild("HumanoidRootPart")
 if root then Remote.SendClientEvent("CombatVFX", {All = true}, "Impacts", name, root.CFrame, target) end
end
Events:Subscribe("DamageDealt", function(ctx)
 if ctx.Damage <= 0 then return end
 if ctx.TriggeredPassives.Maul then impact("Maul", ctx.Victim) end
 if ctx.TriggeredPassives.Regrowth then impact("Regrowth", ctx.Caster) end
end)
Events:Subscribe("HealDealt", function(ctx)
 if ctx.Amount > 0 then impact("Regrowth", ctx.Victim) end
end)

Events:Subscribe("StatusDamageDealt", function(target, amount, damageType, source)
	local mobs = workspace:FindFirstChild("Mobs")
	if not mobs or not target:IsDescendantOf(mobs) or Players:GetPlayerFromCharacter(target) then return end
	local player
	if typeof(source) == "Instance" then
		if source:IsA("Player") then player = source
		elseif source:IsA("Model") then player = Players:GetPlayerFromCharacter(source) end
	end
	Remote.SendClientEvent("Damage", { All = true }, target, amount, {
		Type = damageType, CasterUserId = player and player.UserId,
	})
end)

Events:Subscribe("StatusEffectChanged", function(target, id, entry)
 local key = statusKeys[id]
 if key then
  target:SetAttribute("VFX_" .. key, entry.Duration and workspace:GetServerTimeNow() + math.max(0, entry.ExpiresAt - os.clock()) or -1)
  CollectionService:AddTag(target, "CombatVFXStatus")
 end
	Remote.SendClientEvent("BuffVFX", { All = true }, id, target, "Start",
		entry.Duration and math.max(0, entry.ExpiresAt - os.clock()) or nil, entry.Stacks)
end)
Events:Subscribe("StatusEffectRemoved", function(target, id)
 local key = statusKeys[id]
 if key then
  target:SetAttribute("VFX_" .. key, nil)
  local remaining = false
  for _, other in statusKeys do
   if target:GetAttribute("VFX_" .. other) ~= nil then remaining = true; break end
  end
  if not remaining then CollectionService:RemoveTag(target, "CombatVFXStatus") end
 end
	Remote.SendClientEvent("BuffVFX", { All = true }, id, target, "End")
end)

local function bind(player)
	player.CharacterRemoving:Connect(function(character) Manager:ClearEntity(character) end)
end
Players.PlayerAdded:Connect(bind)
for _, player in Players:GetPlayers() do bind(player) end
game:GetService("RunService").Heartbeat:Connect(function() Manager:Step(os.clock()) end)
