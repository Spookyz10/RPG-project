local Players = game:GetService("Players")
local RemoteManager = require(game:GetService("ReplicatedStorage").Shared.Utils.RemoteManager)
local cooldown = {}
local connections = {}
local pendingTransitions = {}

local function teleportPending(player)
	local pending = pendingTransitions[player]
	if not pending then return end
	pendingTransitions[player] = nil
	local character, target = pending.Character, pending.Target
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not character or not target or not character.Parent or not target.Parent or not humanoid or humanoid.Health <= 0 then return end
	character:PivotTo(target.CFrame + Vector3.new(0, 3, 0))
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero end
end

local readyRemote = RemoteManager.GetRemote("ZoneTransitionReady", "Server")
if readyRemote and readyRemote:IsA("RemoteEvent") then
	readyRemote.OnServerEvent:Connect(teleportPending)
end

local function bind(part)
	if not part:IsA("BasePart") or connections[part] then return end
	connections[part] = part.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorOfClass("Model")
		local player = character and Players:GetPlayerFromCharacter(character)
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not player or not humanoid or humanoid.Health <= 0 or (cooldown[player] or 0) > os.clock() then return end
		local destinations = workspace:FindFirstChild("ZoneTeleportes") or workspace:FindFirstChild("ZoneTeleporters")
		local name = part:GetAttribute("Destination")
		local target = typeof(name) == "string" and destinations and destinations:FindFirstChild(name)
		if not target or not target:IsA("BasePart") then return end
		cooldown[player] = os.clock() + 2
		pendingTransitions[player] = { Character = character, Target = target }
		RemoteManager.SendClientEvent("ZoneTransition", { Player = player }, name)
		task.delay(1.5, function()
			teleportPending(player)
		end)
	end)
	part.Destroying:Once(function() connections[part]:Disconnect(); connections[part] = nil end)
end
local function bindFolder(folder)
	if folder.Name ~= "ZonePortals" then return end
	for _, part in folder:GetDescendants() do bind(part) end
	folder.DescendantAdded:Connect(bind)
end
for _, folder in workspace:GetChildren() do bindFolder(folder) end
workspace.ChildAdded:Connect(bindFolder)
Players.PlayerRemoving:Connect(function(player)
	cooldown[player] = nil
	pendingTransitions[player] = nil
end)
