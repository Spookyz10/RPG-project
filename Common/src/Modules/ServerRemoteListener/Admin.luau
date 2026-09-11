local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server

local Access = require(ReplicatedStorage.Shared.AdminAccess)
local Players = game:GetService("Players")
local Remotes = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local cooldowns = {}
local function integer(value, maximum)
	return typeof(value) == "number" and value == value and value >= 1 and value <= maximum and value % 1 == 0
end

local Remote = {}

local Methods = {}

function Methods.GiveItem(_caller, target, amount, item)
	local items = require(ReplicatedStorage.Shared.ItemsData)
	if not integer(amount, 100) or typeof(item) ~= "string" or not items[item] then return "Select an item and quantity from 1 to 100." end
	local status, _, added = require(game:GetService("ServerStorage").Modules.InventoryManager):AddItem(target, item, amount)
	return status .. " • Received: " .. tostring(added or 0)
end
function Methods.Heal(_caller, target)
	local hum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return "Player needs a living character." end
	hum.Health = hum.MaxHealth
	return "Healed " .. target.Name
end
local function teleport(moving, destination)
	local a, b = moving.Character, destination.Character
	local ah = a and a:FindFirstChildOfClass("Humanoid")
	local bh = b and b:FindFirstChildOfClass("Humanoid")
	if not ah or not bh or ah.Health <= 0 or bh.Health <= 0 then return "Both players need living characters." end
	a:PivotTo(b:GetPivot() * CFrame.new(4, 1, 0))
	local root = a:FindFirstChild("HumanoidRootPart")
	if root then root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero end
	return "Teleported " .. moving.Name .. " to " .. destination.Name
end
function Methods.GoTo(caller, target) return teleport(caller, target) end
function Methods.Bring(caller, target) return teleport(target, caller) end

function Methods.UpdateLevel(_caller: Player, target: Player, level: number)
	if typeof(target) ~= "Instance" or not target:IsA("Player") then
		return
	end

	local max = require(ReplicatedStorage.Shared.getCappedInfo).Level
	if not integer(level, max) then return "Enter a level from 1 to " .. max end
	local data = Data.Service:waitForData(target)
	if not data then return "Player data unavailable." end
	data.Level(level)
	return "Level set to " .. level .. " for " .. target.Name
end

function Methods.GiveGold(_caller: Player, target: Player, amount: number)
	if typeof(target) ~= "Instance" or not target:IsA("Player") then
		return
	end

	if not integer(amount, 10000000) then
		return "Enter a gold amount from 1 to 10000000."
	end

	local PlayerData = Data.Service:waitForData(target)
	if not PlayerData then
		return
	end

	PlayerData.Currencies.Gold(function(current)
		return current + amount
	end)
	return "Added " .. amount .. " gold to " .. target.Name
end

function Remote:Activate(player: Player, method: string, target, ...: any)
	if not Access[player.UserId] then
		return
	end

	if typeof(method) ~= "string" then
		return
	end

	local Handler = Methods[method]
	if not Handler then
		return
	end

	if typeof(target) ~= "Instance" or not target:IsA("Player") or target.Parent ~= Players then
		Remotes.SendClientEvent("AdminResult", {Player = player}, "Target is no longer connected."); return
	end
	if (cooldowns[player] or 0) > os.clock() then
		Remotes.SendClientEvent("AdminResult", {Player = player}, "Please wait a moment."); return
	end
	cooldowns[player] = os.clock() + 0.3
	local ok, message = pcall(Handler, player, target, ...)
	Remotes.SendClientEvent("AdminResult", {Player = player}, ok and (message or "Player data unavailable.") or "Action failed. Check server output.")
	if not ok then warn("Admin action failed: " .. tostring(message)) end
end

Players.PlayerRemoving:Connect(function(player) cooldowns[player] = nil end)

return Remote
