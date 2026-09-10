local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Modules = game:GetService("ServerStorage").Modules
local Manager = require(Modules.StatusEffectManager)
local Events = require(Modules.EventBus)
local Remote = require(RS.Shared.Utils.RemoteManager)

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
	Remote.SendClientEvent("BuffVFX", { All = true }, id, target, "Start",
		entry.Duration and math.max(0, entry.ExpiresAt - os.clock()) or nil, entry.Stacks)
end)
Events:Subscribe("StatusEffectRemoved", function(target, id)
	Remote.SendClientEvent("BuffVFX", { All = true }, id, target, "End")
end)

local function bind(player)
	player.CharacterRemoving:Connect(function(character) Manager:ClearEntity(character) end)
end
Players.PlayerAdded:Connect(bind)
for _, player in Players:GetPlayers() do bind(player) end
game:GetService("RunService").Heartbeat:Connect(function() Manager:Step(os.clock()) end)
