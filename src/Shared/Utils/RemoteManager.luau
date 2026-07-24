local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local RemoteManager = {}

local Remotes = {
	Attack = "Server",
	UseSkill = "Server",
	SkillVFX = "Client",
}

local function getRemote(remoteName: string, folder: string): RemoteEvent
	for _, remote: RemoteEvent in ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild(folder):GetDescendants() do
		if remote.Name == remoteName then
			return remote
		end
	end
	return nil
end

function RemoteManager.SendClientEvent(remoteName: string, params: {}, info: {}?)
	local remote = getRemote(remoteName, "Client")
	if not remote then
		return
	end

	if params.All then
		remote:FireAllClients(info)
	else
		remote:FireClient(params.Player, info)
	end
end

function RemoteManager.SendServerEvent(remoteName: string, info: {}?)
	local remote = getRemote(remoteName, "Server")
	if not remote then
		return
	end

	remote:FireServer(info)
end

function RemoteManager.GetRemote(remoteName: string, folder: string): RemoteEvent
	return getRemote(remoteName, folder)
end

if RunService:IsServer() then
	for remote: string, goal: string in Remotes do
		local newRemote = Instance.new("RemoteEvent")
		newRemote.Parent = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild(goal)
		newRemote.Name = remote
	end
end

return RemoteManager
