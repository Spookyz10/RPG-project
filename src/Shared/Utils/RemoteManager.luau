local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local RemoteManager = {}

local Remotes = {
	Attack = "Server",
	UseSkill = "Server",
	EquipItem = "Server",
	UnequipItem = "Server",
	EquipSkill = "Server",
	ShopBuy = "Server",
	AcceptQuest = "Server",
	AbandonQuest = "Server",

	SkillVFX = "Client",
	Damage = "Client",
	SkillCooldown = "Client",
	LeaderboardUpdate = "Client",
	Indicator = "Client",
}

local RemoteFunctions = {
	GetPlayerInfo = "Server",
}

local function getRemote(remoteName: string, folder: string): Instance
	for _, remote: Instance in ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild(folder):GetDescendants() do
		if remote.Name == remoteName then
			return remote
		end
	end
	return nil
end

function RemoteManager.SendClientEvent(remoteName: string, params: {}, ...: any)
	local remote = getRemote(remoteName, "Client")
	if not remote then
		return
	end

	if params.All then
		remote:FireAllClients(...)
	else
		remote:FireClient(params.Player, ...)
	end
end

function RemoteManager.SendServerEvent(remoteName: string, ...: any)
	local remote = getRemote(remoteName, "Server")
	if not remote then
		return
	end

	remote:FireServer(...)
end

function RemoteManager.InvokeServerFunction(remoteName: string, ...: any)
	local remote = getRemote(remoteName, "Server")
	if not remote then
		return nil
	end

	return remote:InvokeServer(...)
end

function RemoteManager.GetRemote(remoteName: string, folder: string): Instance
	return getRemote(remoteName, folder)
end

function RemoteManager.ListenToAll(Listener: { [string]: any })
	for remoteName, folder in Remotes do
		if folder ~= "Server" then
			continue
		end

		local remote = getRemote(remoteName, folder)
		if not remote then
			continue
		end

		remote.OnServerEvent:Connect(function(Player: Player, ...)
			local ListenerModule = Listener[remoteName]
			if not ListenerModule then
				return
			end

			ListenerModule:Activate(Player, ...)
		end)
	end
end

function RemoteManager.ListenToAllFunctions(Listener: { [string]: any })
	for remoteName, folder in RemoteFunctions do
		if folder ~= "Server" then
			continue
		end

		local remote = getRemote(remoteName, folder)
		if not remote then
			continue
		end

		remote.OnServerInvoke = function(Player: Player, ...)
			local ListenerModule = Listener[remoteName]
			if not ListenerModule then
				return nil
			end

			return ListenerModule:Invoke(Player, ...)
		end
	end
end

function RemoteManager.ListenToAllClient(Listener: { [string]: any })
	for remoteName, folder in Remotes do
		if folder ~= "Client" then
			continue
		end

		local remote = getRemote(remoteName, folder)
		if not remote then
			continue
		end

		remote.OnClientEvent:Connect(function(...)
			local ListenerModule = Listener[remoteName]
			if not ListenerModule then
				return
			end

			ListenerModule:Activate(...)
		end)
	end
end

if RunService:IsServer() then
	for remote: string, goal: string in Remotes do
		local newRemote = Instance.new("RemoteEvent")
		newRemote.Parent = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild(goal)
		newRemote.Name = remote
	end

	for remote: string, goal: string in RemoteFunctions do
		local newRemote = Instance.new("RemoteFunction")
		newRemote.Parent = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild(goal)
		newRemote.Name = remote
	end
end

return RemoteManager
