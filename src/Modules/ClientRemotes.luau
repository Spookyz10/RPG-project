local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientRemotes = {}

function ClientRemotes.SendClientEvent(remoteName: string, params: {}, info: {})
	local remote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Client"):FindFirstChild(remoteName)
	if not remote then
		return
	end

	if params.All then
		remote:FireAllClients(info)
	else
		remote:FireClient(params.Player, info)
	end
end

return ClientRemotes
